import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repositories
// Note: authRepositoryProvider is already defined in supabase_auth_repository.dart,
// but we re-export it here or just use it directly.

// Use Cases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.read(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.read(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.read(authRepositoryProvider));
});

// Auth State Streams
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return repo.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return repo.currentUser;
});
