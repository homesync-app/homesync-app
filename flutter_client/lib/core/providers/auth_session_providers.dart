import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/admin_providers.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';

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

  return Stream.multi((controller) {
    AppAuthState? lastEmitted;

    void emit() {
      final firebaseUser = fa.FirebaseAuth.instance.currentUser;
      final appUserId = AppIdentityService.instance.currentUserId;
      final next = AppAuthState(
        isAuthenticated: firebaseUser != null && appUserId != null,
        source: 'firebase',
      );

      if (lastEmitted != null &&
          lastEmitted!.isAuthenticated == next.isAuthenticated &&
          lastEmitted!.source == next.source) {
        return;
      }

      lastEmitted = next;
      controller.add(next);
    }

    final authSub =
        fa.FirebaseAuth.instance.authStateChanges().listen((_) => emit());
    AppIdentityService.instance.addListener(emit);

    emit();

    controller.onCancel = () {
      authSub.cancel();
      AppIdentityService.instance.removeListener(emit);
    };
  });
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

Future<void> _syncSessionContextFromAuth(AppAuthState authState) async {
  if (!authState.isAuthenticated) {
    await AppIdentityService.instance.refresh();
    await _applySessionDiagnostics(null);
    return;
  }

  final nextUserId = await AppIdentityService.instance.refresh();
  await _applySessionDiagnostics(nextUserId);
}

final authBootstrapProvider = FutureProvider<void>((ref) async {
  await AppIdentityService.instance.initialize();

  ref.listen<AsyncValue<AppAuthState>>(authStateProvider, (previous, next) {
    next.whenData((authState) {
      unawaited(_syncSessionContextFromAuth(authState));
    });
  });

  final initialAuthState = await ref.read(authStateProvider.future).catchError(
        (_) => const AppAuthState(
          isAuthenticated: false,
          source: 'bootstrap_error',
        ),
      );

  await _syncSessionContextFromAuth(initialAuthState);
});
