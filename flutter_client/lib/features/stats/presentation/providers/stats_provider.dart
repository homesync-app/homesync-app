import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/features/stats/data/repositories/supabase_stats_repository.dart';
import 'package:homesync_client/features/stats/domain/repositories/stats_repository.dart';
import 'package:homesync_client/features/stats/domain/usecases/award_weekly_winner_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/get_coin_history_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/get_expense_stats_by_category_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/get_member_activity_stats_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/get_task_stats_by_category_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/get_weekly_duel_history_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/get_weekly_ranking_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/get_xp_history_usecase.dart';
import 'package:homesync_client/features/stats/domain/usecases/save_weekly_duel_result_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_provider.g.dart';

@Riverpod(keepAlive: true)
StatsRepository statsRepository(StatsRepositoryRef ref) {
  final statsRpc = ref.watch(statsRpcServiceProvider);
  return SupabaseStatsRepository(statsRpc);
}

@riverpod
GetTaskStatsByCategoryUseCase taskStatsByCategoryUseCase(
  TaskStatsByCategoryUseCaseRef ref,
) {
  return GetTaskStatsByCategoryUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
GetXpHistoryUseCase xpHistoryUseCase(XpHistoryUseCaseRef ref) {
  return GetXpHistoryUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
GetCoinHistoryUseCase coinHistoryUseCase(CoinHistoryUseCaseRef ref) {
  return GetCoinHistoryUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
GetExpenseStatsByCategoryUseCase expenseStatsByCategoryUseCase(
  ExpenseStatsByCategoryUseCaseRef ref,
) {
  return GetExpenseStatsByCategoryUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
GetMemberActivityStatsUseCase memberActivityStatsUseCase(
  MemberActivityStatsUseCaseRef ref,
) {
  return GetMemberActivityStatsUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
GetWeeklyRankingUseCase weeklyRankingUseCase(WeeklyRankingUseCaseRef ref) {
  return GetWeeklyRankingUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
GetWeeklyDuelHistoryUseCase weeklyDuelHistoryUseCase(
  WeeklyDuelHistoryUseCaseRef ref,
) {
  return GetWeeklyDuelHistoryUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
AwardWeeklyWinnerUseCase weeklyWinnerAwardUseCase(
  WeeklyWinnerAwardUseCaseRef ref,
) {
  return AwardWeeklyWinnerUseCase(ref.watch(statsRepositoryProvider));
}

@riverpod
SaveWeeklyDuelResultUseCase weeklyDuelResultSaveUseCase(
  WeeklyDuelResultSaveUseCaseRef ref,
) {
  return SaveWeeklyDuelResultUseCase(ref.watch(statsRepositoryProvider));
}

@Riverpod(keepAlive: true)
class StatsController extends _$StatsController {
  @override
  Future<StatsData> build() async {
    final householdId = await ref.watch(householdIdProvider.future);

    if (householdId == null) {
      return StatsData.empty();
    }

    final results = await Future.wait<dynamic>([
      ref.watch(taskStatsByCategoryUseCaseProvider).call(),
      ref.watch(xpHistoryUseCaseProvider).call(),
      ref.watch(coinHistoryUseCaseProvider).call(),
      ref.watch(expenseStatsByCategoryUseCaseProvider).call(),
      ref.watch(memberActivityStatsUseCaseProvider).call(),
      ref.watch(weeklyRankingUseCaseProvider).call(),
      ref.watch(weeklyDuelHistoryUseCaseProvider).call(),
    ]);

    return StatsData(
      taskStats: results[0],
      xpHistory: results[1],
      coinHistory: results[2],
      expenseStats: results[3],
      memberActivity: results[4],
      weeklyRanking: results[5],
      duelHistory: results[6],
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<StatsData>().copyWithPrevious(state);
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
  final List<Map<String, dynamic>> duelHistory;

  StatsData({
    required this.taskStats,
    required this.xpHistory,
    required this.coinHistory,
    required this.expenseStats,
    required this.memberActivity,
    required this.weeklyRanking,
    required this.duelHistory,
  });

  factory StatsData.empty() => StatsData(
    taskStats: [],
    xpHistory: [],
    coinHistory: [],
    expenseStats: [],
    memberActivity: [],
    weeklyRanking: [],
    duelHistory: [],
  );
}
