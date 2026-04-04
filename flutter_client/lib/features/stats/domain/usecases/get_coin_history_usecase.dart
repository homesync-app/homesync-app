import '../repositories/stats_repository.dart';

class GetCoinHistoryUseCase {
  final StatsRepository _repository;

  const GetCoinHistoryUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getCoinHistory();
  }
}
