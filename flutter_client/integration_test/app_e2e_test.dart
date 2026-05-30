// End-to-end UI flow against a LIVE Supabase backend: login → home → store.
//
// Run with real throwaway credentials:
//   flutter test integration_test/app_e2e_test.dart \
//     --dart-define=E2E_EMAIL=... --dart-define=E2E_PASSWORD=...
//
// Skipped (not falsely passed) when credentials are absent. When present, the
// navigation assertions are strict: landing on Home and opening the Store are
// REQUIRED. The reward redemption step is genuinely conditional on inventory,
// so it stays guarded — but it asserts a concrete outcome when it does run.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/main.dart' as app;
import 'package:integration_test/integration_test.dart';

import 'helpers/test_credentials.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: login, reach home, open store, attempt redeem',
      (tester) async {
    if (!TestCredentials.ensureConfigured()) return;

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Log in if we're on the login screen.
    final loginTitle = find.text('Bienvenido de vuelta');
    if (loginTitle.evaluate().isNotEmpty) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        TestCredentials.email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        TestCredentials.password,
      );
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // STRICT: we must be on the home/dashboard.
    expect(
      find.text('Inicio'),
      findsWidgets,
      reason: 'Did not navigate to the home screen after login.',
    );

    // STRICT: the store tab must exist and open.
    final storeTab = find.text('Tienda');
    expect(storeTab, findsWidgets, reason: 'Store tab not found.');
    await tester.tap(storeTab.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(
      find.text('Recompensas del Hogar'),
      findsWidgets,
      reason: 'Store screen did not load its rewards header.',
    );

    // Reward redemption depends on real inventory/balance, so it stays
    // conditional — but when a reward IS redeemable we assert a concrete result
    // (confirm dialog → snackbar), instead of just checking the app didn't die.
    final redeem = find.text('Canjear');
    if (redeem.evaluate().isNotEmpty) {
      await tester.tap(redeem.first);
      await tester.pumpAndSettle();

      expect(
        find.text('Confirmar canje'),
        findsWidgets,
        reason: 'Redeem tap did not surface the confirmation dialog.',
      );
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Either a success or an insufficient-funds message — both are a real
      // backend response surfaced as a SnackBar.
      expect(
        find.byType(SnackBar),
        findsOneWidget,
        reason: 'Expected a confirmation/error SnackBar from the backend.',
      );
    }
  });
}
