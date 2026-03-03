import 'package:homesync_client/features/stats/domain/repositories/stats_repository.dart';
import '../../../../core/services/rpc/stats_rpc_service.dart';

class SupabaseStatsRepository implements StatsRepository {
  final StatsRpcService _rpcService;

  SupabaseStatsRepository(this._rpcService);

  @override
  Future<List<Map<String, dynamic>>> getTaskStatsByCategory() async {
    return _rpcService.getTaskStatsByCategory();
  }

  @override
  Future<List<Map<String, dynamic>>> getXpHistory() async {
    return _rpcService.getXpHistory();
  }

  @override
  Future<List<Map<String, dynamic>>> getCoinHistory() async {
    return _rpcService.getCoinHistory();
  }

  @override
  Future<List<Map<String, dynamic>>> getExpenseStatsByCategory() async {
    return _rpcService.getExpenseStatsByCategory();
  }

  @override
  Future<List<Map<String, dynamic>>> getMemberActivityStats() async {
    return _rpcService.getMemberActivityStats();
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
    return _rpcService.getWeeklyRanking();
  }

  @override
  Future<bool> isWeekProcessed() async {
    return _rpcService.isWeekProcessed();
  }

  @override
  Future<Map<String, dynamic>> awardWeeklyWinner() async {
    return _rpcService.awardWeeklyWinner();
  }

  @override
  Future<Map<String, dynamic>> checkShouldShowWinner() async {
    return _rpcService.checkShouldShowWinner();
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyDuelHistory() async {
    return _rpcService.getWeeklyDuelHistory();
  }

  @override
  Future<Map<String, dynamic>> saveWeeklyDuelResult({
    required String householdId,
    required DateTime weekStartDate,
    required String winnerUserId,
    required String winnerName,
    required String loserUserId,
    required String loserName,
    required int winnerXp,
    required int loserXp,
  }) async {
    return _rpcService.saveWeeklyDuelResult(
      householdId: householdId,
      weekStartDate: weekStartDate,
      winnerUserId: winnerUserId,
      winnerName: winnerName,
      loserUserId: loserUserId,
      loserName: loserName,
      winnerXp: winnerXp,
      loserXp: loserXp,
    );
  }
}
