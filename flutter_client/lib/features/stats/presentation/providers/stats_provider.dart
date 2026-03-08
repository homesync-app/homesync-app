import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/stats/data/repositories/supabase_stats_repository.dart';
import 'package:homesync_client/features/stats/domain/repositories/stats_repository.dart';

part 'stats_provider.g.dart';

@Riverpod(keepAlive: true)
StatsRepository statsRepository(StatsRepositoryRef ref) {
  final statsRpc = ref.watch(statsRpcServiceProvider);
  return SupabaseStatsRepository(statsRpc);
}

@Riverpod(keepAlive: true)
class StatsController extends _$StatsController {
  @override
  Future<StatsData> build() async {
    final repository = ref.watch(statsRepositoryProvider);
    final householdId = await ref.watch(householdIdProvider.future);
    
    if (householdId == null) {
      return StatsData.empty();
    }

    final results = await Future.wait([
      repository.getTaskStatsByCategory(),
      repository.getXpHistory(),
      repository.getCoinHistory(),
      repository.getExpenseStatsByCategory(),
      repository.getMemberActivityStats(),
      repository.getWeeklyRanking(),
    ]);

    return StatsData(
      taskStats: results[0],
      xpHistory: results[1],
      coinHistory: results[2],
      expenseStats: results[3],
      memberActivity: results[4],
      weeklyRanking: results[5],
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

class StatsData {
  final List<Map<String, dynamic>> taskStats;
  final List<Map<String, dynamic>> xpHistory;
  final List<Map<String, dynamic>> coinHistory;
  final List<Map<String, dynamic>> expenseStats;
  final List<Map<String, dynamic>> memberActivity;
  final List<Map<String, dynamic>> weeklyRanking;

  StatsData({
    required this.taskStats,
    required this.xpHistory,
    required this.coinHistory,
    required this.expenseStats,
    required this.memberActivity,
    required this.weeklyRanking,
  });

  factory StatsData.empty() => StatsData(
    taskStats: [],
    xpHistory: [],
    coinHistory: [],
    expenseStats: [],
    memberActivity: [],
    weeklyRanking: [],
  );
}
