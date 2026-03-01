import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Abstract contract for authentication.
/// The domain layer only depends on this interface, never on Supabase directly.
abstract class AuthRepository {
  /// Returns current authenticated user, or null if not logged in.
  User? get currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  });

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<bool> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<UserModel?> getUserProfile(String userId);
}
