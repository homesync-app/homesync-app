import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
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

  @override
  // In Firebase Third-Party Auth mode there is no Supabase session; return null.
  User? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges {
    return fa.FirebaseAuth.instance.authStateChanges().map((firebaseUser) {
      return AuthState(
        firebaseUser != null
            ? AuthChangeEvent.signedIn
            : AuthChangeEvent.signedOut,
        null, // no Supabase session in Third-Party Auth mode
      );
    });
  }

  @override
  Future<Either<Failure, void>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return executeWithHandling(
      () async {
        await _firebaseAuthService.signUpWithEmail(
          email: email,
          password: password,
          fullName: fullName,
        );
      },
      context: 'SupabaseAuthRepository.signUpWithEmail',
      isOnline: _isOnline,
    );
  }

  @override
  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return executeWithHandling(
      () async {
        await _firebaseAuthService.signInWithEmail(
          email: email,
          password: password,
        );
      },
      context: 'SupabaseAuthRepository.signInWithEmail',
      isOnline: _isOnline,
    );
  }

  @override
  Future<Either<Failure, bool>> signInWithGoogle() async {
    log.i('SupabaseAuthRepository: starting signInWithGoogle');
    return executeWithHandling(
      () async {
        log.i('SupabaseAuthRepository: using Firebase Auth flow');
        final success = await _firebaseAuthService.signInWithGoogle();
        log.i(
          'SupabaseAuthRepository: Firebase Google sign-in returned: $success',
        );
        return success;
      },
      context: 'SupabaseAuthRepository.signInWithGoogle',
      isOnline: _isOnline,
    );
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return executeWithHandling(
      () async {
        await _firebaseAuthService.signOut();
      },
      context: 'SupabaseAuthRepository.signOut',
      isOnline: _isOnline,
    );
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    return executeWithHandling(
      () async {
        await _firebaseAuthService.resetPassword(email);
      },
      context: 'SupabaseAuthRepository.resetPassword',
      isOnline: _isOnline,
    );
  }

  @override
  Future<Either<Failure, UserModel?>> getUserProfile(String userId) async {
    return executeWithHandling(
      () async {
        final data = await _client
            .from('users')
            .select('id, full_name, email, avatar_url, mercadopago_alias')
            .eq('id', userId)
            .maybeSingle();

        if (data == null) return null;
        return UserModel.fromJson(data);
      },
      context: 'SupabaseAuthRepository.getUserProfile',
      isOnline: _isOnline,
    );
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    return executeWithHandling(
      () async {
        if (fullName == null && avatarUrl == null) return;

        // Use the SECURITY DEFINER RPC so the update bypasses RLS and
        // resolves the caller via current_app_user_id() (works with Firebase JWTs).
        await _client.rpc(
          'update_own_profile',
          params: {
            'p_full_name': fullName,
            'p_avatar_url': avatarUrl,
          },
        );
      },
      context: 'SupabaseAuthRepository.updateProfile',
      isOnline: _isOnline,
    );
  }
}
