abstract class StatsRepository {
  Future<List<Map<String, dynamic>>> getTaskStatsByCategory();
  Future<List<Map<String, dynamic>>> getXpHistory();
  Future<List<Map<String, dynamic>>> getCoinHistory();
  Future<List<Map<String, dynamic>>> getExpenseStatsByCategory();
  Future<List<Map<String, dynamic>>> getMemberActivityStats();
  Future<List<Map<String, dynamic>>> getWeeklyRanking();
  Future<bool> isWeekProcessed();
  Future<Map<String, dynamic>> awardWeeklyWinner();
  Future<Map<String, dynamic>> checkShouldShowWinner();
  Future<List<Map<String, dynamic>>> getWeeklyDuelHistory();
  Future<Map<String, dynamic>> saveWeeklyDuelResult({
    required String householdId,
    required DateTime weekStartDate,
    required String winnerUserId,
    required String winnerName,
    required String loserUserId,
    required String loserName,
    required int winnerXp,
    required int loserXp,
  });
}
