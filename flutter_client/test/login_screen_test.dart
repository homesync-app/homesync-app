import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/auth/presentation/screens/login_screen.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';

import 'package:homesync_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:io';

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

class FakeAuthRepository implements AuthRepository {
  bool didCallSignIn = false;
  bool shouldFail = false;
  String? lastEmailed;

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    lastEmailed = email;
    didCallSignIn = true;
    if (shouldFail) {
      throw const AuthException('Invalid login credentials');
    }
  }

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePrefs {
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Para evitar errores de carga de imágenes de red en los tests
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MockHttpOverrides();

  testWidgets('Test de Interfaz Visual - LoginScreen Renderiza Correctamente', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000); 
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    
    final fakeRepo = FakeAuthRepository();
    final fakePrefs = FakePrefs();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: LoginScreen(prefs: fakePrefs),
      ),
    ));

    await tester.pumpAndSettle();

    // Verificamos que cargan los textos esperados
    expect(find.text('Inicio de Sesión'), findsAtLeastNWidgets(1));
    expect(find.text('HomeSync'), findsAtLeastNWidgets(1));
    expect(find.text('¿Eres nuevo?'), findsOneWidget);
    
    // Verificamos inputs
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email y Password
  });

  testWidgets('Test de Validaciones - LoginScreen requiere inputs válidos', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    
    final fakeRepo = FakeAuthRepository();
    final fakePrefs = FakePrefs();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: LoginScreen(prefs: fakePrefs),
      ),
    ));

    await tester.pumpAndSettle();

    // Tocamos el botón de iniciar sesión sin datos
    await tester.ensureVisible(find.text('Entrar al Hogar'));
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
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    
    final fakeRepo = FakeAuthRepository();
    final fakePrefs = FakePrefs();

    fakeRepo.shouldFail = true; // Simularemos una falla de login del Server para ver el SnackBar

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: LoginScreen(prefs: fakePrefs),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Ingresamos datos correctos estructuralmente pero fallarán desde el "backend simulado"
    await tester.enterText(find.widgetWithText(TextFormField, 'Correo electrónico'), 'test@test.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), '123456');

    // Nos aseguramos que el botón sea visible y lo tocamos
    await tester.ensureVisible(find.text('Entrar al Hogar'));
    await tester.tap(find.text('Entrar al Hogar'));
    await tester.pump(); // Inicia proceso
    await tester.pump(const Duration(milliseconds: 500)); // Espera un poco de la animación
    await tester.pumpAndSettle(); // Termina animaciones

    // Verificamos que sí se interceptó el botón
    expect(fakeRepo.didCallSignIn, isTrue);
    expect(fakeRepo.lastEmailed, 'test@test.com');
    
    // Verificamos que la falla generó el SnackBar rojo en pantalla al usuario
    expect(find.text('Credenciales inválidas o cuenta no existente'), findsOneWidget);
  });
}
