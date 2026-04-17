import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  // Inicializamos el motor de pruebas de integración (El "Autómata")
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Esta prueba simula a un usuario humano interactuando enteramente con la UI y llamando al Backend Supabase real
  testWidgets(
      'Flujo E2E: Iniciar sesión, ver tareas e intentar canjear recompensa',
      (WidgetTester tester) async {
    // 1. ARRANCAR LA APLICACIÓN COMPLETA
    app.main();

    // Damos tiempo extra para que inicialice Supabase y los Providers
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Si detectamos que la pantalla de Login está presente, hacemos el ciclo de inicio
    final loginTitleFinder = find.text('Bienvenido de vuelta');
    if (loginTitleFinder.evaluate().isNotEmpty) {
      // Ingresar Credenciales (Debe usarse una cuenta real existente de testeo en Supabase)
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Correo electrónico'),
          'tu_pareja@gmail.com',);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Contraseña'), '123456',);

      // Tocar en Login
      await tester.tap(find.text('Iniciar sesión'));

      // Esperar a que el login se complete via Internet (Simula la espera del humano)
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // 2. VERIFICACIÓN: LLEGAMOS AL HOME / DASHBOARD ("Inicio")
    expect(find.text('Inicio'), findsWidgets,
        reason: 'Deberíamos haber navegado al HomeScreen principal',);

    // 3. CAMBIAR A LA PESTAÑA TIENDA (Navegación Táctil a "Tienda" en la BottomNavigationBar)
    await tester.tap(find.text('Tienda'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verificamos que cargó la Tienda de Recompensas y leemos los Coins
    expect(find.text('Recompensas del Hogar'), findsWidgets);

    // 4. INTERACTUAR CON UN PREMIO DE LA TIENDA
    // Simulamos que el autómata busca el botón de canjeo de un premio específico
    final canjearFinder = find
        .text('Canjear')
        .first; // Busca el primer botón de canjear disponible
    if (canjearFinder.evaluate().isNotEmpty) {
      // Toca para canjear
      await tester.tap(canjearFinder);
      await tester.pumpAndSettle();

      // Debería aparecer un Diálogo de Confirmación pidiendo aprobar la compra o denegarla (x fondos)
      expect(find.text('Confirmar canje'), findsWidgets);

      // Aprobar canje en el popup
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle(
          const Duration(seconds: 4),); // Espera petición al servidor

      // Verificar que el backend o app reaccionaron y arrojaron el mensaje visual
      // Nota: Si no hay saldo saldrá mensaje de error de saldo en su lugar
      final snackBarText = find.byType(SnackBar);
      expect(snackBarText, findsOneWidget,
          reason:
              'Se esperaba un mensaje Toast (SnackBar) de confirmación/error de Supabase',);
    }
  });
}
