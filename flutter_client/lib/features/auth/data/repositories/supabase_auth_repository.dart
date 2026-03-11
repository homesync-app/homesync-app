import 'package:homesync_client/core/services/logger_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../../../../core/services/repository_error_handler.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:homesync_client/core/services/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
  return SupabaseAuthRepository(
    client: client, 
    firebaseAuthService: firebaseAuthService,
    ref: ref
  );
});

/// Supabase implementation of AuthRepository, powered by Firebase Auth for identity.
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
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<Either<Failure, void>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return executeWithHandling(() async {
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
      await _client.auth.signInWithPassword(email: email, password: password);
    }, context: 'SupabaseAuthRepository.signInWithEmail', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, bool>> signInWithGoogle() async {
    log.i('SupabaseAuthRepository: Iniciando signInWithGoogle...');
    return executeWithHandling(() async {
      if (kIsWeb) {
        log.i('SupabaseAuthRepository: Usando Supabase OAuth para Web');
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? Uri.base.origin : null,
        );
        return true; 
      } else {
        log.i('SupabaseAuthRepository: Usando Firebase Auth para Mobile');
        final success = await _firebaseAuthService.signInWithGoogle();
        log.i('SupabaseAuthRepository: _firebaseAuthService.signInWithGoogle retornó: $success');
        return success;
      }
    }, context: 'SupabaseAuthRepository.signInWithGoogle', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return executeWithHandling(() async {
      await _client.auth.signOut();
      await _firebaseAuthService.signOut();
    }, context: 'SupabaseAuthRepository.signOut', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    return executeWithHandling(() async {
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
}
