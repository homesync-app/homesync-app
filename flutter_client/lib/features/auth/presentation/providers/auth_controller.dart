import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/domain/models/user_model.dart';
import 'package:homesync_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_controller.g.dart';

@riverpod
User? currentUser(Ref ref) {
  return ref.watch(authRepositoryProvider).currentUser;
}

/// Controller that manages the authentication state and actions.
/// It wraps the AuthRepository and provides a unified interface for the UI.
@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<AuthState> build() {
    final repository = ref.watch(authRepositoryProvider);
    return repository.authStateChanges;
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> signInWithEmail(String email, String password) async {
    final isAdminTestingLogin = AppEnvironment.enableAdminTesting &&
        email.trim().toLowerCase() ==
            AppEnvironment.adminTestingUsername.toLowerCase() &&
        password == AppEnvironment.adminTestingPassword;

    if (isAdminTestingLogin) {
      log.i('Admin Testing login detected');
      ref.read(adminProvider.notifier).adminLogin();
      state = const AsyncValue.data(
        AuthState(AuthChangeEvent.signedIn, null),
      );
      return;
    }

    state = const AsyncValue.loading();
    final result =
        await _repository.signInWithEmail(email: email, password: password);

    result.fold(
      (failure) {
        log.setCustomKey('auth_flow', 'email_sign_in');
        log.setCustomKey('auth_email', email);
        log.e('Login error: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        // The stream will automatically update the state
        log.i('Login successful for $email');
      },
    );
  }

  Future<void> signUpWithEmail(
      String email, String password, String? fullName) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );

    result.fold(
      (failure) {
        log.setCustomKey('auth_flow', 'email_sign_up');
        log.setCustomKey('auth_email', email);
        log.e('Registration error: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        log.i('Registration successful for $email');
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithGoogle();

    return result.fold(
      (failure) {
        log.setCustomKey('auth_flow', 'google_sign_in');
        log.e('Google Sign-In error: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (success) {
        if (success) {
          log.i('Google Sign-In successful');
        } else {
          // Case where user cancelled or something went wrong without a hard failure
          state = const AsyncValue.data(
              AuthState(AuthChangeEvent.initialSession, null));
        }
        return success;
      },
    );
  }

  Future<void> signOut() async {
    if (AppEnvironment.enableAdminTesting &&
        ref.read(adminProvider).isAdminUser) {
      ref.read(adminProvider.notifier).clearAdminSession();
      state = const AsyncValue.data(
        AuthState(AuthChangeEvent.signedOut, null),
      );
      log.i('Admin testing session closed');
      return;
    }

    state = const AsyncValue.loading();
    final result = await _repository.signOut();

    result.fold(
      (failure) {
        log.setCustomKey('auth_flow', 'sign_out');
        log.e('Sign out error: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) => log.i('Sign out successful'),
    );
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    final result = await _repository.resetPassword(email);

    result.fold(
      (failure) {
        log.setCustomKey('auth_flow', 'reset_password');
        log.setCustomKey('auth_email', email);
        log.e('Reset password error: ${failure.message}');
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) {
        log.i('Reset password email sent to $email');
        state = const AsyncValue.data(
          AuthState(AuthChangeEvent.initialSession, null),
        );
      },
    );
  }
}

/// Provides the current authenticated user from Supabase.
/// Provides whether the user is currently authenticated.
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final isAdmin =
      AppEnvironment.enableAdminTesting && ref.watch(adminProvider).isAdminUser;
  if (isAdmin) return true;

  final authState = ref.watch(authControllerProvider).value;
  if (authState == null) return false;

  return authState.event == AuthChangeEvent.signedIn ||
      authState.event == AuthChangeEvent.tokenRefreshed ||
      authState.event == AuthChangeEvent.userUpdated;
}

/// Provides the user profile from the database, updated when the user changes.
@riverpod
Future<UserModel?> currentUserProfile(CurrentUserProfileRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null || userId.isEmpty) return null;

  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.getUserProfile(userId);

  return result.fold(
    (failure) {
      log.e('Error loading user profile: ${failure.message}');
      return null;
    },
    (profile) => profile,
  );
}
