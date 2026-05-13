import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:homesync_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:homesync_client/features/auth/presentation/screens/login_screen.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository implements AuthRepository {
  bool didCallSignIn = false;
  bool shouldFail = false;
  String? lastEmailed;

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges =>
      Stream.value(const AuthState(AuthChangeEvent.initialSession, null));

  @override
  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    lastEmailed = email;
    didCallSignIn = true;
    if (shouldFail) {
      return const Left(
        AuthFailure('Credenciales invalidas o cuenta no existente'),
      );
    }
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePrefs {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _pumpLoginScreen(
  WidgetTester tester, {
  required FakeAuthRepository fakeRepo,
  required FakePrefs fakePrefs,
  bool withScaffold = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(useMaterial3: true),
        home: withScaffold
            ? Scaffold(body: LoginScreen(prefs: fakePrefs))
            : LoginScreen(prefs: fakePrefs),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  HttpOverrides.global = MockHttpOverrides();

  testWidgets('LoginScreen renders the current login experience',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeRepo = FakeAuthRepository();
    final fakePrefs = FakePrefs();

    await _pumpLoginScreen(
      tester,
      fakeRepo: fakeRepo,
      fakePrefs: fakePrefs,
    );

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.textContaining('HomeSync'), findsOneWidget);
    expect(find.textContaining('Ingres'), findsWidgets);
    expect(find.textContaining('Sos nuevo en HomeSync'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('LoginScreen validates required and malformed inputs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeRepo = FakeAuthRepository();
    final fakePrefs = FakePrefs();

    await _pumpLoginScreen(
      tester,
      fakeRepo: fakeRepo,
      fakePrefs: fakePrefs,
    );

    await tester.ensureVisible(find.text('Ingresar'));
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Requerido'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'correoInvalido');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(fakeRepo.didCallSignIn, isFalse);
  });

  testWidgets('LoginScreen submits credentials and surfaces auth failures',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final fakeRepo = FakeAuthRepository()..shouldFail = true;
    final fakePrefs = FakePrefs();

    await _pumpLoginScreen(
      tester,
      fakeRepo: fakeRepo,
      fakePrefs: fakePrefs,
      withScaffold: true,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.ensureVisible(find.text('Ingresar'));
    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(fakeRepo.didCallSignIn, isTrue);
    expect(fakeRepo.lastEmailed, 'test@test.com');
    expect(
      find.textContaining('Credenciales'),
      findsOneWidget,
    );
  });
}
