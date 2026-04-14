import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/domain/models/user_model.dart';
import 'package:homesync_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
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
    final analytics = ref.read(analyticsServiceProvider);
    final isAdminTestingLogin =
        AppEnvironment.adminTestingPasswordLoginEnabled &&
            email.trim().toLowerCase() ==
                AppEnvironment.adminTestingUsername.toLowerCase() &&
            password == AppEnvironment.adminTestingPassword;

    if (isAdminTestingLogin) {
      log.i('Admin Testing login detected');
      state = const AsyncValue.loading();
      try {
        await analytics.trackAuthStarted(method: 'admin_testing');
        if (AppEnvironment.adminTestingAutoAdminSessionEnabled) {
          await ref.read(qaSessionServiceProvider).signInAsAdminPreviewSession(
                email: AppEnvironment.adminTestingBaseEmail,
                password: AppEnvironment.adminTestingBasePassword,
              );
        } else {
          ref.read(adminProvider.notifier).adminLogin();
        }
        state = const AsyncValue.data(
          AuthState(AuthChangeEvent.signedIn, null),
        );
        await analytics.trackAuthSucceeded(method: 'admin_testing');
      } catch (error, stackTrace) {
        log.e(
          'Admin testing login error: $error',
          error: error,
          stackTrace: stackTrace,
        );
        await analytics.trackAuthFailed(
          method: 'admin_testing',
          reason: error.toString(),
        );
        state = AsyncValue.error(error, stackTrace);
      }
      return;
    }

    state = const AsyncValue.loading();
    await analytics.trackAuthStarted(method: 'email');
    final result =
        await _repository.signInWithEmail(email: email, password: password);

    await result.fold(
      (failure) async {
        log.setCustomKey('auth_flow', 'email_sign_in');
        log.setCustomKey('auth_email', email);
        log.e('Login error: ${failure.message}');
        await analytics.trackAuthFailed(
          method: 'email',
          reason: failure.message,
        );
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) async {
        // The stream will automatically update the state
        log.i('Login successful for $email');
        await analytics.trackAuthSucceeded(method: 'email');
      },
    );
  }

  Future<void> signUpWithEmail(
      String email, String password, String? fullName) async {
    final analytics = ref.read(analyticsServiceProvider);
    state = const AsyncValue.loading();
    await analytics.trackAuthStarted(method: 'email', isSignUp: true);
    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
    );

    await result.fold(
      (failure) async {
        log.setCustomKey('auth_flow', 'email_sign_up');
        log.setCustomKey('auth_email', email);
        log.e('Registration error: ${failure.message}');
        await analytics.trackAuthFailed(
          method: 'email',
          reason: failure.message,
          isSignUp: true,
        );
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) async {
        log.i('Registration successful for $email');
        await analytics.trackAuthSucceeded(method: 'email', isSignUp: true);
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    final analytics = ref.read(analyticsServiceProvider);
    state = const AsyncValue.loading();
    await analytics.trackAuthStarted(method: 'google');
    final result = await _repository.signInWithGoogle();

    return result.fold(
      (failure) async {
        log.setCustomKey('auth_flow', 'google_sign_in');
        log.e('Google Sign-In error: ${failure.message}');
        await analytics.trackAuthFailed(
          method: 'google',
          reason: failure.message,
        );
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (success) async {
        if (success) {
          log.i('Google Sign-In successful');
          await analytics.trackAuthSucceeded(method: 'google');
        } else {
          // Case where user cancelled or something went wrong without a hard failure
          await analytics.trackAuthFailed(
            method: 'google',
            reason: 'cancelled_or_incomplete',
          );
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
      if (ref.read(adminProvider).useRealQaSession) {
        state = const AsyncValue.loading();
        final result = await _repository.signOut();

        result.fold(
          (failure) {
            log.setCustomKey('auth_flow', 'qa_real_sign_out');
            log.e('QA real sign out error: ${failure.message}');
            state = AsyncValue.error(failure.message, StackTrace.current);
          },
          (_) {
            ref.read(adminProvider.notifier).endRealQaSession();
            state = const AsyncValue.data(
              AuthState(AuthChangeEvent.signedOut, null),
            );
            log.i('QA real session closed');
          },
        );
        return;
      }

      if (ref.read(adminProvider).useAdminPreviewBaseSession) {
        state = const AsyncValue.loading();
        final result = await _repository.signOut();

        result.fold(
          (failure) {
            log.setCustomKey('auth_flow', 'qa_admin_preview_sign_out');
            log.e('QA admin preview sign out error: ${failure.message}');
            state = AsyncValue.error(failure.message, StackTrace.current);
          },
          (_) {
            ref.read(adminProvider.notifier).clearAdminSession();
            state = const AsyncValue.data(
              AuthState(AuthChangeEvent.signedOut, null),
            );
            log.i('Admin testing session closed');
          },
        );
        return;
      }

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
      (_) {
        ref.invalidate(authStateProvider);
        ref.invalidate(householdIdProvider);
        ref.invalidate(userProfileProvider);
        ref.invalidate(currentHouseholdProvider);
        ref.invalidate(householdMembersProvider);
        log.i('Sign out successful');
      },
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

  final authState = ref.watch(authStateProvider).valueOrNull;
  return authState?.isAuthenticated ?? false;
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
