import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Abstract contract for authentication.
/// The domain layer only depends on this interface, never on Supabase directly.
abstract class AuthRepository {
  /// Returns current authenticated user, or null if not logged in.
  User? get currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges;

  Future<Either<Failure, void>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  });

  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, UserModel?>> getUserProfile(String userId);
}
