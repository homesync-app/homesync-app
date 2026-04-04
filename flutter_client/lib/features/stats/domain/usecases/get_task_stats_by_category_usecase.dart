import '../repositories/stats_repository.dart';

class GetTaskStatsByCategoryUseCase {
  final StatsRepository _repository;

  const GetTaskStatsByCategoryUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getTaskStatsByCategory();
  }
}
