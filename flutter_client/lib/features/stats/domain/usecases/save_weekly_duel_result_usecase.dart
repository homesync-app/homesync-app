import '../repositories/stats_repository.dart';

class SaveWeeklyDuelResultUseCase {
  final StatsRepository _repository;

  const SaveWeeklyDuelResultUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required String householdId,
    required DateTime weekStartDate,
    required String winnerUserId,
    required String winnerName,
    required String loserUserId,
    required String loserName,
    required int winnerXp,
    required int loserXp,
  }) {
    return _repository.saveWeeklyDuelResult(
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
