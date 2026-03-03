import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/repository_error_handler.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  final authService = ref.read(authServiceProvider);
  return SupabaseAuthRepository(client: client, authService: authService);
});

/// Supabase implementation of AuthRepository.
class SupabaseAuthRepository with RepositoryErrorHandler implements AuthRepository {
  final SupabaseClient _client;
  final SupabaseAuthService _authService;

  SupabaseAuthRepository({
    required SupabaseClient client,
    required SupabaseAuthService authService,
  })  : _client = client,
        _authService = authService;

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
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    }, context: 'SupabaseAuthRepository.signUpWithEmail');
  }

  @override
  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return executeWithHandling(() async {
      await _authService.signIn(email: email, password: password);
    }, context: 'SupabaseAuthRepository.signInWithEmail');
  }

  @override
  Future<Either<Failure, bool>> signInWithGoogle() async {
    return executeWithHandling(() async {
      return await _authService.signInWithGoogle();
    }, context: 'SupabaseAuthRepository.signInWithGoogle');
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return executeWithHandling(() async {
      await _authService.signOut();
    }, context: 'SupabaseAuthRepository.signOut');
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    return executeWithHandling(() async {
      await _authService.resetPasswordForEmail(email);
    }, context: 'SupabaseAuthRepository.resetPassword');
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
    }, context: 'SupabaseAuthRepository.getUserProfile');
  }
}
