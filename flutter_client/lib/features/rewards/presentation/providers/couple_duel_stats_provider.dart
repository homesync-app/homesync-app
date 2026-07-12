import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';

/// Estadísticas del "duelo" semanal que muestra la pestaña Pareja
/// (ranking, stats por miembro, stats por categoría e historial de duelos).
///
/// Antes la pantalla disparaba estos 4 RPC de forma imperativa en su
/// `initState`, así que se pagaban recién en la primera visita a Pareja. Al
/// vivir en un provider keepAlive se pueden calentar en segundo plano desde
/// el Home (ver `_scheduleSecondaryTabPrefetch` en MainScreen) y quedan
/// cacheados para que el tab abra instantáneo.
class CoupleDuelStats {
  final List<Map<String, dynamic>> taskStats;
  final List<Map<String, dynamic>> memberStats;
  final List<Map<String, dynamic>> weeklyRanking;
  final List<Map<String, dynamic>> duelHistory;

  const CoupleDuelStats({
    this.taskStats = const [],
    this.memberStats = const [],
    this.weeklyRanking = const [],
    this.duelHistory = const [],
  });

  static const empty = CoupleDuelStats();
}

List<Map<String, dynamic>> _mapList(dynamic value) =>
    value is List ? List<Map<String, dynamic>>.from(value) : const [];

/// FutureProvider keepAlive (no autoDispose) a propósito: queremos que el
/// resultado sobreviva mientras el usuario se mueve entre pestañas, igual que
/// el caché en estado que tenía la pantalla. El refresh manual (pull-to-refresh
/// del tab) lo invalida explícitamente.
final coupleDuelStatsProvider = FutureProvider<CoupleDuelStats>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null || householdId.isEmpty) {
    return CoupleDuelStats.empty;
  }

  // El modo admin/QA usa RPCs distintas que reciben el household explícito.
  final admin = ref.watch(adminProvider);
  if (admin.isAdminUser) {
    final client = ref.read(supabaseClientProvider);
    final results = await Future.wait<dynamic>([
      client.rpc(
        'qa_admin_get_task_stats_by_category',
        params: {'p_household_id': householdId},
      ),
      client.rpc(
        'qa_admin_get_member_activity_stats',
        params: {'p_household_id': householdId},
      ),
      client.rpc(
        'qa_admin_get_weekly_ranking',
        params: {'p_household_id': householdId},
      ),
      client.rpc(
        'qa_admin_get_weekly_duel_history',
        params: {'p_household_id': householdId},
      ),
    ]);
    return CoupleDuelStats(
      taskStats: _mapList(results[0]),
      memberStats: _mapList(results[1]),
      weeklyRanking: _mapList(results[2]),
      duelHistory: _mapList(results[3]),
    );
  }

  final rpc = ref.read(rpcServiceProvider);
  final results = await Future.wait<dynamic>([
    rpc.getTaskStatsByCategory(),
    rpc.getMemberActivityStats(),
    rpc.getWeeklyRanking(),
    rpc.getWeeklyDuelHistory(),
  ]);
  return CoupleDuelStats(
    taskStats: _mapList(results[0]),
    memberStats: _mapList(results[1]),
    weeklyRanking: _mapList(results[2]),
    duelHistory: _mapList(results[3]),
  );
});

/// XP propio ganado por día (lunes..domingo) de la semana en curso. Alimenta
/// el "Ritmo semanal" de la card del duelo con datos reales. Lee
/// ledger_entries directo (RLS: cada usuario ve su propio ledger); ante
/// cualquier error devuelve la semana vacía en vez de romper la card.
final weeklyXpByDayProvider = FutureProvider<List<int>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return List.filled(7, 0);

  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));

  try {
    final client = ref.read(supabaseClientProvider);
    final rows = await client
        .from('ledger_entries')
        .select('amount, created_at')
        .eq('user_id', userId)
        .eq('currency', 'XP')
        .gte('created_at', monday.toUtc().toIso8601String());

    final byDay = List<int>.filled(7, 0);
    for (final row in List<Map<String, dynamic>>.from(rows)) {
      final createdAt =
          DateTime.tryParse(row['created_at']?.toString() ?? '')?.toLocal();
      if (createdAt == null || createdAt.isBefore(monday)) continue;
      byDay[createdAt.weekday - 1] += (row['amount'] as num?)?.toInt() ?? 0;
    }
    return byDay;
  } catch (error, stackTrace) {
    log.w(
      'weeklyXpByDayProvider fallback to empty week',
      error: error,
      stackTrace: stackTrace,
    );
    return List.filled(7, 0);
  }
});
