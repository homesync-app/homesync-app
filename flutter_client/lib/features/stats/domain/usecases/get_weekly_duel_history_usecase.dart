import '../repositories/stats_repository.dart';

class GetWeeklyDuelHistoryUseCase {
  final StatsRepository _repository;

  const GetWeeklyDuelHistoryUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getWeeklyDuelHistory();
  }
}
