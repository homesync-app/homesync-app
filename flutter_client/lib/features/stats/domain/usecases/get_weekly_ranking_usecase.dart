import '../repositories/stats_repository.dart';

class GetWeeklyRankingUseCase {
  final StatsRepository _repository;

  const GetWeeklyRankingUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getWeeklyRanking();
  }
}
