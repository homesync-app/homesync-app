import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';

/// Clave de completación del desafío semanal: hogar + semana cruda
/// ([CoupleChallenge.currentWeekIndex], sin módulo de rotación).
typedef CoupleChallengeWeekKey = ({String householdId, int weekIndex});

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

/// Registra la completación de la semana. Idempotente: si el otro miembro
/// ya la registró (carrera entre los dos teléfonos), el conflicto se ignora.
Future<void> recordCoupleChallengeCompletion(
  WidgetRef ref, {
  required String householdId,
  required int weekIndex,
  required String challengeId,
  required String completedBy,
}) async {
  final client = ref.read(supabaseClientProvider);
  await client.from('couple_challenge_completions').upsert(
    {
      'household_id': householdId,
      'week_index': weekIndex,
      'challenge_id': challengeId,
      'completed_by': completedBy,
    },
    onConflict: 'household_id,week_index',
    ignoreDuplicates: true,
  );
  ref.invalidate(coupleChallengeCompletedProvider);
}
