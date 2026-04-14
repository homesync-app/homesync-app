import '../repositories/stats_repository.dart';

class GetExpenseStatsByCategoryUseCase {
  final StatsRepository _repository;

  const GetExpenseStatsByCategoryUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getExpenseStatsByCategory();
  }
}
