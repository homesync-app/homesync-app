import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/firebase_auth_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/repository_error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(
    supabaseClient: ref.read(supabaseClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
  return SupabaseAuthRepository(
    client: client,
    firebaseAuthService: firebaseAuthService,
    ref: ref,
  );
});

class SupabaseAuthRepository
    with RepositoryErrorHandler
    implements AuthRepository {
  final SupabaseClient _client;
  final FirebaseAuthService _firebaseAuthService;
  final Ref _ref;

  SupabaseAuthRepository({
    required SupabaseClient client,
    required FirebaseAuthService firebaseAuthService,
    required Ref ref,
  })  : _client = client,
        _firebaseAuthService = firebaseAuthService,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  Future<String?> _resolveCurrentUserId() async {
    final authUserId = _client.auth.currentUser?.id;
    if (authUserId != null && authUserId.isNotEmpty) {
      return authUserId;
    }

    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }

    return null;
  }

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges {
    if (AppEnvironment.usesFirebaseJwtForSupabase) {
      final seededState = AuthState(
        _client.auth.currentSession == null
            ? AuthChangeEvent.signedOut
            : AuthChangeEvent.signedIn,
        _client.auth.currentSession,
      );

      return Stream<AuthState>.multi((controller) {
        controller.add(seededState);
        final firebaseSubscription =
            _firebaseAuthService.authStateChanges.listen(
          (fa.User? user) {
            controller.add(
              AuthState(
                user == null
                    ? AuthChangeEvent.signedOut
                    : AuthChangeEvent.signedIn,
                _client.auth.currentSession,
              ),
            );
          },
          onError: controller.addError,
        );

        final supabaseSubscription = _client.auth.onAuthStateChange.listen(
          controller.add,
          onError: controller.addError,
        );

        controller.onCancel = () async {
          await firebaseSubscription.cancel();
          await supabaseSubscription.cancel();
        };
      });
    }

    return _client.auth.onAuthStateChange;
  }

  @override
  Future<Either<Failure, void>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return executeWithHandling(() async {
      if (AppEnvironment.usesFirebaseJwtForSupabase) {
        await _firebaseAuthService.signUpWithEmail(
          email: email,
          password: password,
        );
        return;
      }

      await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : {},
      );
    }, context: 'SupabaseAuthRepository.signUpWithEmail', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return executeWithHandling(() async {
      if (AppEnvironment.usesFirebaseJwtForSupabase) {
        await _firebaseAuthService.signInWithEmail(
          email: email,
          password: password,
        );
        return;
      }

      await _client.auth.signInWithPassword(email: email, password: password);
    }, context: 'SupabaseAuthRepository.signInWithEmail', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, bool>> signInWithGoogle() async {
    log.i('SupabaseAuthRepository: starting signInWithGoogle');
    return executeWithHandling(() async {
      if (kIsWeb && !AppEnvironment.usesFirebaseJwtForSupabase) {
        log.i('SupabaseAuthRepository: using Supabase OAuth on web');
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
        return true;
      }

      log.i('SupabaseAuthRepository: using Firebase Auth flow');
      final success = await _firebaseAuthService.signInWithGoogle();
      log.i(
          'SupabaseAuthRepository: Firebase Google sign-in returned: $success');
      return success;
    }, context: 'SupabaseAuthRepository.signInWithGoogle', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return executeWithHandling(() async {
      if (AppEnvironment.usesFirebaseJwtForSupabase) {
        await _firebaseAuthService.signOut();
        return;
      }

      await _client.auth.signOut();
    }, context: 'SupabaseAuthRepository.signOut', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    return executeWithHandling(() async {
      if (AppEnvironment.usesFirebaseJwtForSupabase) {
        await _firebaseAuthService.resetPassword(email);
        return;
      }

      await _client.auth.resetPasswordForEmail(email);
    }, context: 'SupabaseAuthRepository.resetPassword', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, UserModel?>> getUserProfile(String userId) async {
    return executeWithHandling(() async {
      final data = await _client
          .from('users')
          .select('id, full_name, email, avatar_url, mercadopago_alias')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserModel.fromJson(data);
    }, context: 'SupabaseAuthRepository.getUserProfile', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    return executeWithHandling(() async {
      final userId = await _resolveCurrentUserId();
      if (userId == null) {
        throw const AuthFailure(
          'No hay una identidad activa para actualizar el perfil',
        );
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) return;

      await _client.from('users').update(updates).eq('id', userId);
    }, context: 'SupabaseAuthRepository.updateProfile', isOnline: _isOnline);
  }
}
