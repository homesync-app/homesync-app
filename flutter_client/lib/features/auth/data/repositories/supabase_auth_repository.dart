import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
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
class SupabaseAuthRepository implements AuthRepository {
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
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    await _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _authService.signIn(email: email, password: password);
  }

  @override
  Future<bool> signInWithGoogle() => _authService.signInWithGoogle();

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> resetPassword(String email) =>
      _authService.resetPasswordForEmail(email);

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    final data = await _client
        .from('users')
        .select('id, full_name, email, avatar_url, mercadopago_alias')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(data);
  }
}
