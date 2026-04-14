import '../repositories/stats_repository.dart';

class GetMemberActivityStatsUseCase {
  final StatsRepository _repository;

  const GetMemberActivityStatsUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call() {
    return _repository.getMemberActivityStats();
  }
}
