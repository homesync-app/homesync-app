import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Clave de completación del desafío semanal: hogar + semana cruda
/// ([CoupleChallenge.currentWeekIndex], sin módulo de rotación).
typedef CoupleChallengeWeekKey = ({String householdId, int weekIndex});

/// Resultado de [completeCoupleChallenge].
enum CoupleChallengeOutcome { completed, alreadyCompleted, failed }

/// true si el hogar ya completó el desafío de esa semana (lo registró
/// cualquiera de los dos miembros, en cualquier dispositivo).
final coupleChallengeCompletedProvider = FutureProvider.autoDispose
    .family<bool, CoupleChallengeWeekKey>((ref, key) async {
  final client = ref.watch(supabaseClientProvider);
  final rows = await client
      .from('couple_challenge_completions')
      .select('week_index')
      .eq('household_id', key.householdId)
      .eq('week_index', key.weekIndex)
      .limit(1);
  return rows.isNotEmpty;
});

/// Completa el desafío semanal en UNA sola llamada atómica
/// (`complete_couple_challenge_v1`): registra la semana, acredita XP+coins a
/// cada miembro y deja la actividad en el feed. Reemplaza las 3 llamadas
/// encadenadas que dejaban estado a medias y creaban una tarea fantasma.
///
/// Idempotente en el servidor: si la semana ya estaba registrada devuelve
/// [CoupleChallengeOutcome.alreadyCompleted] sin re-acreditar.
Future<CoupleChallengeOutcome> completeCoupleChallenge(
  WidgetRef ref, {
  required String householdId,
  required int weekIndex,
  required String challengeId,
  required List<String> userIds,
  required String completedBy,
  required int coinReward,
  required int xpReward,
  required String title,
  String? description,
}) async {
  final outcome = await completeCoupleChallengeRpc(
    ref.read(supabaseClientProvider),
    householdId: householdId,
    weekIndex: weekIndex,
    challengeId: challengeId,
    userIds: userIds,
    completedBy: completedBy,
    coinReward: coinReward,
    xpReward: xpReward,
    title: title,
    description: description,
  );
  // El widget dueño del ref pudo desmontarse durante el await del RPC;
  // invalidar con un WidgetRef muerto lanza. El provider es autoDispose,
  // así que en ese caso se refresca solo en el próximo mount.
  if (ref.context.mounted) {
    ref.invalidate(coupleChallengeCompletedProvider);
  }
  return outcome;
}

/// Núcleo testeable: arma los params del RPC y mapea la respuesta. Vive aparte
/// de [completeCoupleChallenge] para poder testearlo con un fake de
/// [SupabaseClient] sin necesidad de un WidgetRef.
///
/// IMPORTANTE: nunca pasar una categoría — `tasks.category` (que el flujo viejo
/// tocaba) tiene FK contra `categories(id)`; el desafío no es una categoría de
/// quehacer. Este RPC ni siquiera crea una tarea. (Regresión del bug del FK.)
Future<CoupleChallengeOutcome> completeCoupleChallengeRpc(
  SupabaseClient client, {
  required String householdId,
  required int weekIndex,
  required String challengeId,
  required List<String> userIds,
  required String completedBy,
  required int coinReward,
  required int xpReward,
  required String title,
  String? description,
}) async {
  final response = await client.rpc(
    'complete_couple_challenge_v1',
    params: {
      'p_request_id': const Uuid().v4(),
      'p_household_id': householdId,
      'p_week_index': weekIndex,
      'p_challenge_id': challengeId,
      'p_user_ids': userIds,
      'p_xp_reward': xpReward,
      'p_coin_reward': coinReward,
      'p_title': title,
      'p_description': description,
      'p_completed_by': completedBy,
    },
  );

  final map = (response is Map) ? Map<String, dynamic>.from(response) : null;
  return switch (map?['status']) {
    'completed' => CoupleChallengeOutcome.completed,
    'already_completed' => CoupleChallengeOutcome.alreadyCompleted,
    _ => CoupleChallengeOutcome.failed,
  };
}
