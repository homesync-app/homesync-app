import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';

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
final coupleDuelStatsProvider =
    FutureProvider<CoupleDuelStats>((ref) async {
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
