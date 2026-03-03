import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/auth/presentation/screens/login_screen.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

// Fakes simplificados para simular el comportamiento de los servicios
class FakeAuthService implements SupabaseAuthService {
  bool didCallSignIn = false;
  bool shouldFail = false;
  String? lastEmailed;

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    lastEmailed = email;
    didCallSignIn = true;
    if (shouldFail) {
      throw const AuthException('Invalid login credentials');
    }
    return AuthResponse(
      session: null,
      user: const User(
        id: '123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '',
      ),
    );
  }

  // Ignoramos el resto de los métodos exigidos por defecto para hacer esto un Mock funcional
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRpcService implements SupabaseRpcService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePrefs {
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Test de Interfaz Visual - LoginScreen Renderiza Correctamente', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    
    final fakeAuth = FakeAuthService();
    final fakeRpc = FakeRpcService();
    final fakePrefs = FakePrefs();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuth),
        rpcServiceProvider.overrideWithValue(fakeRpc),
      ],
      child: MaterialApp(
        home: LoginScreen(prefs: fakePrefs),
      ),
    ));

    // Verificamos que cargan los textos esperados
    expect(find.text('Inicio de Sesión'), findsOneWidget);
    // Cambiado los matches porque la UI original tenía textos diferentes
    expect(find.text('HomeSync'), findsOneWidget);
    expect(find.text('¿Eres nuevo?'), findsOneWidget);
    
    // Verificamos inputs
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email y Password
  });

  testWidgets('Test de Validaciones - LoginScreen requiere inputs válidos', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    
    final fakeAuth = FakeAuthService();
    final fakeRpc = FakeRpcService();
    final fakePrefs = FakePrefs();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuth),
        rpcServiceProvider.overrideWithValue(fakeRpc),
      ],
      child: MaterialApp(
        home: LoginScreen(prefs: fakePrefs),
      ),
    ));

    // Hacemos scroll
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Tocamos el botón de iniciar sesión sin datos
    await tester.tap(find.text('Entrar al Hogar'));
    await tester.pumpAndSettle();

    // Deben aparecer los mensajes de error del form
    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);

    // Intentamos un correo no válido
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'correoInvalido');
    await tester.tap(find.text('Entrar al Hogar'));
    await tester.pumpAndSettle();

    expect(find.text('Correo inválido'), findsOneWidget);
  });

  testWidgets('Test de Interacción Front-to-Back - LoginScreen llama a AuthService', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    
    final fakeAuth = FakeAuthService();
    final fakeRpc = FakeRpcService();
    final fakePrefs = FakePrefs();

    fakeAuth.shouldFail = true; // Simularemos una falla de login del Server para ver el SnackBar

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuth),
        rpcServiceProvider.overrideWithValue(fakeRpc),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: LoginScreen(prefs: fakePrefs),
        ),
      ),
    ));

    // Ingresamos datos correctos estructuralmente pero fallarán desde el "backend simulado"
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'test@test.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), '123456');

    // Hacemos scroll para asegurarnos de que el botón esté visible en la pantalla de test
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar al Hogar'));
    await tester.pumpAndSettle(); // Esperamos animación del loading

    // Verificamos que sí se interceptó el botón
    expect(fakeAuth.didCallSignIn, isTrue);
    expect(fakeAuth.lastEmailed, 'test@test.com');
    
    // Verificamos que la falla generó el SnackBar rojo en pantalla al usuario
    expect(find.text('Credenciales inválidas o cuenta no existente'), findsOneWidget);
  });
}
