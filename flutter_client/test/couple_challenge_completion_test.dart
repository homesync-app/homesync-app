import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/rewards/presentation/providers/couple_challenge_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Captura el nombre de función y los params del `.rpc()` para inspeccionarlos.
class _CapturingClient extends Fake implements SupabaseClient {
  _CapturingClient(this.response);
  final Map<String, dynamic> response;
  String? capturedFn;
  Map<String, dynamic>? capturedParams;

  @override
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    Map<String, dynamic>? params,
    dynamic get = false,
  }) {
    capturedFn = fn;
    capturedParams = params;
    return _FakeRpcBuilder<T>(response);
  }
}

/// Builder awaitable: `PostgrestBuilder implements Future`, así que con
/// implementar `then` alcanza para que `await client.rpc(...)` resuelva.
class _FakeRpcBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  _FakeRpcBuilder(this._value);
  final dynamic _value;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) {
    return Future<T>.value(_value as T).then(onValue, onError: onError);
  }
}

void main() {
  group('completeCoupleChallengeRpc', () {
    test(
      'nunca manda una categoría (regresión del bug fk_tasks_category) '
      'y arma los params esperados',
      () async {
        final client = _CapturingClient({
          'status': 'completed',
          'coins_earned': 0,
        });

        final outcome = await completeCoupleChallengeRpc(
          client,
          householdId: 'h1',
          weekIndex: 3,
          challengeId: 'weekly_challenge_1',
          completedBy: 'u1',
          title: 'Desafío: Recreando la primera cita',
          description: 'desc',
        );

        expect(outcome, CoupleChallengeOutcome.completed);
        expect(client.capturedFn, 'complete_couple_challenge_v1');

        final params = client.capturedParams!;
        // El bug original: pasar la categoría localizada del desafío como id
        // de categoría de tarea (FK contra categories). El flujo nuevo no debe
        // mandar NINGÚN parámetro de categoría.
        expect(
          params.keys.any((k) => k.toLowerCase().contains('categor')),
          isFalse,
          reason: 'el desafío no es una categoría de quehacer',
        );
        expect(params['p_household_id'], 'h1');
        expect(params['p_week_index'], 3);
        expect(params['p_challenge_id'], 'weekly_challenge_1');
        expect(params['p_user_ids'], ['u1']);
        expect(params['p_completed_by'], 'u1');
        expect(params['p_coin_reward'], 0);
        expect(params['p_xp_reward'], 0);
      },
    );

    test('mapea already_completed', () async {
      final client = _CapturingClient({'status': 'already_completed'});
      final outcome = await completeCoupleChallengeRpc(
        client,
        householdId: 'h',
        weekIndex: 0,
        challengeId: 'c',
        completedBy: 'u',
        title: 't',
      );
      expect(outcome, CoupleChallengeOutcome.alreadyCompleted);
    });

    test('mapea un status desconocido/invalid a failed', () async {
      final client = _CapturingClient({'status': 'invalid'});
      final outcome = await completeCoupleChallengeRpc(
        client,
        householdId: 'h',
        weekIndex: 0,
        challengeId: 'c',
        completedBy: 'u',
        title: 't',
      );
      expect(outcome, CoupleChallengeOutcome.failed);
    });
  });
}
