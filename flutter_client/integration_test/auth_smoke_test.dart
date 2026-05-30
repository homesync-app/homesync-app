// Real auth smoke test — exercises login + logout against a LIVE backend.
//
// Run with real throwaway credentials (see helpers/test_credentials.dart):
//   flutter test integration_test/auth_smoke_test.dart \
//     --dart-define=E2E_EMAIL=... --dart-define=E2E_PASSWORD=...
//
// Without credentials the test is SKIPPED (not silently passed). When
// credentials ARE present, the assertions are strict: a failure to land on the
// home screen or to return to the login screen after logout FAILS the test —
// no more `if (finder.isNotEmpty)` escape hatches that let it pass having done
// nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/main.dart' as app;
import 'package:integration_test/integration_test.dart';

import 'helpers/test_credentials.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real auth smoke: login then logout', (tester) async {
    if (!TestCredentials.ensureConfigured()) return;

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // We require a clean (logged-out) start so the test is deterministic.
    final loginButton = find.text('Ingresar');
    expect(
      loginButton,
      findsWidgets,
      reason: 'Expected the login screen on a fresh launch. If a session was '
          'persisted, clear app state before running this smoke test.',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      TestCredentials.email,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contraseña'),
      TestCredentials.password,
    );

    await tester.ensureVisible(loginButton.first);
    await tester.tap(loginButton.first);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // STRICT: login must have left the login screen behind.
    expect(
      find.text('Bienvenido'),
      findsNothing,
      reason: 'Still on the login screen after submitting valid credentials.',
    );
    expect(find.byType(MaterialApp), findsOneWidget);

    // Navigate to settings and log out. These are REQUIRED to exist.
    final settingsTab = find.text('Ajustes');
    expect(
      settingsTab,
      findsWidgets,
      reason: 'Settings tab not found after login.',
    );
    await tester.tap(settingsTab.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final logoutAction = _firstPresent([
      find.text('Cerrar sesión'),
      find.text('Cerrar sesion'),
      find.text('Salir'),
    ]);
    expect(
      logoutAction,
      isNotNull,
      reason: 'No logout action found in Settings.',
    );

    await tester.ensureVisible(logoutAction!);
    await tester.tap(logoutAction);
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // STRICT: logout must return us to the login screen.
    expect(
      find.text('Ingresar'),
      findsWidgets,
      reason: 'Did not return to the login screen after logout.',
    );
  });
}

/// Returns the first finder that currently matches at least one widget, or null.
Finder? _firstPresent(List<Finder> finders) {
  for (final f in finders) {
    if (f.evaluate().isNotEmpty) return f;
  }
  return null;
}
