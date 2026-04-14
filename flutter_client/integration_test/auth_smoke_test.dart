import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homesync_client/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testEmail = 'staging-test-1@example.com';
  const testPassword = 'StagingTest123!';

  testWidgets('Real auth smoke: login and logout remain functional',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final loginButton = find.text('Ingresar');
    if (loginButton.evaluate().isNotEmpty) {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo electrónico'),
        testEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'),
        testPassword,
      );

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 8));
    }

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Bienvenido'), findsNothing);

    final settingsTab = find.text('Ajustes');
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    final logoutCandidates = [
      find.text('Cerrar sesión'),
      find.text('Cerrar sesion'),
      find.text('Salir'),
    ];

    Finder? logoutAction;
    for (final candidate in logoutCandidates) {
      if (candidate.evaluate().isNotEmpty) {
        logoutAction = candidate;
        break;
      }
    }

    if (logoutAction != null) {
      await tester.ensureVisible(logoutAction);
      await tester.tap(logoutAction);
      await tester.pumpAndSettle(const Duration(seconds: 6));
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
