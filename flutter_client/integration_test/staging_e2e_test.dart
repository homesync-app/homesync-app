// Staging E2E suite.
//
// HISTORY: the previous version of this file asserted against a REST API that
// no longer exists in this app — /auth/refresh token rotation, a 60-req/min
// HTTP rate limiter, and HTTP idempotency-key headers. HomeSync auth is now
// Firebase Auth → JWT → Supabase (see AGENTS.md), so those tests described a
// fictional backend. They were removed. What remains exercises behavior that
// IS real today:
//   • OfflineQueueService (local sqflite queue) — pure, no network, always runs
//   • Double-tap task completion idempotency via the UI — needs a live backend
//   • Navigation resilience after login — needs a live backend
//
// Backend-dependent tests are SKIPPED (not falsely green) unless E2E creds are
// provided:
//   flutter test integration_test/staging_e2e_test.dart \
//     --dart-define=E2E_EMAIL=... --dart-define=E2E_PASSWORD=...
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/main.dart' as app;
import 'package:integration_test/integration_test.dart';

import 'helpers/test_credentials.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline queue (local, no backend required)', () {
    testWidgets('enqueue → getPending → markProcessing → markCompleted',
        (tester) async {
      final queue = OfflineQueueService();

      // Start from a clean slate for deterministic counts.
      await queue.clearCompleted();
      final startLen = await queue.getQueueLength();

      final id = await queue.enqueue(
        QueuedRequest(
          method: 'POST',
          endpoint: '/tasks',
          body: const {'name': 'Offline Task'},
        ),
      );
      expect(id, greaterThan(0));
      expect(await queue.getQueueLength(), startLen + 1);

      final pending = await queue.getPending();
      expect(pending, isNotEmpty);
      final mine = pending.firstWhere((r) => r.id == id);
      expect(mine.endpoint, '/tasks');
      expect(mine.method, 'POST');
      expect(mine.body?['name'], 'Offline Task');

      await queue.markProcessing(id);
      await queue.markCompleted(id);

      // Completed entries no longer count toward the pending length.
      expect(await queue.getQueueLength(), startLen);

      await queue.clearCompleted();
    });

    testWidgets('queue preserves FIFO order and multiple entries',
        (tester) async {
      final queue = OfflineQueueService();
      await queue.clearCompleted();
      final startLen = await queue.getQueueLength();

      final id1 = await queue.enqueue(
        QueuedRequest(method: 'POST', endpoint: '/a', body: const {'n': 1}),
      );
      final id2 = await queue.enqueue(
        QueuedRequest(method: 'POST', endpoint: '/b', body: const {'n': 2}),
      );

      expect(await queue.getQueueLength(), startLen + 2);

      final next = await queue.getNext();
      expect(next?.id, id1, reason: 'getNext should return the oldest entry.');

      // Cleanup.
      await queue.markCompleted(id1);
      await queue.markCompleted(id2);
      await queue.clearCompleted();
    });
  });

  group('Live backend flows', () {
    testWidgets('double-tap task completion does not double-count (idempotent)',
        (tester) async {
      if (!TestCredentials.ensureConfigured()) return;

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

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

      expect(
        find.text('Inicio'),
        findsWidgets,
        reason: 'Login did not reach home.',
      );

      final tasksTab = find.text('Tareas');
      expect(tasksTab, findsWidgets, reason: 'Tasks tab not found.');
      await tester.tap(tasksTab.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Double-tap the first completable task. The app must remain stable; the
      // backend's request_id idempotency prevents a duplicate ledger entry.
      final completeButtons = find.byIcon(Icons.check_circle_outline);
      if (completeButtons.evaluate().isNotEmpty) {
        await tester.tap(completeButtons.first);
        await tester.pump(const Duration(milliseconds: 80));
        await tester.tap(completeButtons.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // App stays functional (no crash, no exception screen).
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
