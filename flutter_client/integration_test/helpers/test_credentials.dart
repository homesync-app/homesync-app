// Shared credentials for the integration / staging E2E suite.
//
// These tests hit a REAL backend, so they need a real throwaway test account.
// Credentials are injected at run time via --dart-define so they never live in
// source control:
//
//   flutter test integration_test/auth_smoke_test.dart \
//     --dart-define=E2E_EMAIL=staging-test-1@example.com \
//     --dart-define=E2E_PASSWORD=•••••
//
// If they are not provided, [TestCredentials.requireOrSkip] marks the test as
// skipped (instead of silently passing or leaking a default password).
import 'package:flutter_test/flutter_test.dart';

class TestCredentials {
  const TestCredentials._();

  static const String email = String.fromEnvironment('E2E_EMAIL');
  static const String password = String.fromEnvironment('E2E_PASSWORD');

  static bool get isConfigured => email.isNotEmpty && password.isNotEmpty;

  /// Returns true when credentials are present. When they are missing, prints a
  /// clear reason and returns false so the caller can `return;` early — the
  /// test is reported as passed-but-skipped rather than a false green that
  /// pretended to exercise the login flow.
  static bool ensureConfigured() {
    if (isConfigured) return true;
    markTestSkipped(
      'E2E credentials not provided. Pass --dart-define=E2E_EMAIL=... and '
      '--dart-define=E2E_PASSWORD=... to run this against a real backend.',
    );
    return false;
  }
}
