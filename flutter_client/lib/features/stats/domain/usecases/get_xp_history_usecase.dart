import '../repositories/stats_repository.dart';

class GetXpHistoryUseCase {
  final StatsRepository _repository;

  const GetXpHistoryUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getXpHistory();
  }
}
