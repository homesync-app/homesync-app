import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetRecentActivityUseCase {
  final DashboardRepository repository;

  GetRecentActivityUseCase(this.repository);

  Future<List<Map<String, dynamic>>> execute(String householdId) {
    return repository.getRecentActivity(householdId);
  }
}
