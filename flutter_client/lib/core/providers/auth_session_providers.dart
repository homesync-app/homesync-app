import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/admin_providers.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/firebase_auth_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppAuthState {
  const AppAuthState({
    required this.isAuthenticated,
    required this.source,
  });

  final bool isAuthenticated;
  final String source;
}

final authStateProvider = StreamProvider<AppAuthState>((ref) {
  final admin = ref.watch(adminProvider);
  if (isAdminPreviewActive(admin)) {
    return Stream.value(
      const AppAuthState(
        isAuthenticated: true,
        source: 'admin_testing',
      ),
    );
  }

  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges.map(
    (state) => AppAuthState(
      isAuthenticated: state.session != null ||
          state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.tokenRefreshed ||
          state.event == AuthChangeEvent.userUpdated,
      source: AppEnvironment.usesFirebaseJwtForSupabase
          ? 'firebase'
          : 'supabase',
    ),
  );
});

Future<void> _applySessionDiagnostics(String? userId) async {
  final resolvedUserId = userId ?? '';
  log.setUserId(resolvedUserId);
  log.setCustomKey('user_id', resolvedUserId);

  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setUserIdentifier(resolvedUserId);
    await FirebaseCrashlytics.instance.setCustomKey('user_id', resolvedUserId);
  }
}

Future<void> _syncSessionContextFromAuth(
  AppAuthState authState,
  FirebaseAuthService firebaseAuthService,
) async {
  if (AppEnvironment.usesFirebaseJwtForSupabase && authState.isAuthenticated) {
    await firebaseAuthService.syncSupabaseSessionIfNeeded();
  }

  if (!authState.isAuthenticated) {
    await AppIdentityService.instance.refresh();
    await _applySessionDiagnostics(null);
    return;
  }

  final nextUserId = await AppIdentityService.instance.refresh();
  await _applySessionDiagnostics(nextUserId);
}

final authBootstrapProvider = FutureProvider<void>((ref) async {
  final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
  await AppIdentityService.instance.initialize();

  ref.listen<AsyncValue<AppAuthState>>(authStateProvider, (previous, next) {
    next.whenData((authState) {
      unawaited(_syncSessionContextFromAuth(authState, firebaseAuthService));
    });
  });

  final initialAuthState = await ref.read(authStateProvider.future).catchError(
        (_) => const AppAuthState(
          isAuthenticated: false,
          source: 'bootstrap_error',
        ),
      );

  await _syncSessionContextFromAuth(initialAuthState, firebaseAuthService);
});
