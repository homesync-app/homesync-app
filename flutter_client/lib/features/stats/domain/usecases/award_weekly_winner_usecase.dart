import '../repositories/stats_repository.dart';

class AwardWeeklyWinnerUseCase {
  final StatsRepository _repository;

  const AwardWeeklyWinnerUseCase(this._repository);

  Future<Map<String, dynamic>> call() {
    return _repository.awardWeeklyWinner();
  }
}
