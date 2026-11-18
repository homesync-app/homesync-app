import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/auth_session_providers.dart';
import 'package:homesync_client/features/auth/presentation/widgets/auth_session_route.dart';

void main() {
  Widget app(Stream<AppAuthState> sessions) => ProviderScope(
        overrides: [authStateProvider.overrideWith((ref) => sessions)],
        child: MaterialApp(
          initialRoute: '/__login__',
          home: const Text('underlying home'),
          routes: {
            '/__login__': (_) => AuthSessionRoute(
                  authenticatedBuilder: (_) => const Text('authenticated home'),
                  signedOutBuilder: (_) => const Text('login form'),
                  loadingBuilder: (_) => const Text('loading session'),
                ),
          },
        ),
      );

  testWidgets('restored login URL shows home for an already valid session',
      (tester) async {
    await tester.pumpWidget(
      app(
        Stream.value(
          const AppAuthState(isAuthenticated: true, source: 'firebase'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('authenticated home'), findsOneWidget);
    expect(find.text('login form'), findsNothing);
  });

  testWidgets('login route follows sign-in and sign-out without a new push',
      (tester) async {
    final sessions = StreamController<AppAuthState>();
    addTearDown(sessions.close);
    await tester.pumpWidget(app(sessions.stream));
    expect(find.text('loading session'), findsOneWidget);
    sessions
        .add(const AppAuthState(isAuthenticated: false, source: 'firebase'));
    await tester.pumpAndSettle();
    expect(find.text('login form'), findsOneWidget);
    sessions.add(const AppAuthState(isAuthenticated: true, source: 'firebase'));
    await tester.pumpAndSettle();
    expect(find.text('authenticated home'), findsOneWidget);
    expect(find.text('login form'), findsNothing);
    sessions
        .add(const AppAuthState(isAuthenticated: false, source: 'firebase'));
    await tester.pumpAndSettle();
    expect(find.text('login form'), findsOneWidget);
    expect(find.text('authenticated home'), findsNothing);
  });
}
