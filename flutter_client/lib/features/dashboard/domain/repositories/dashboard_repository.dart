abstract class DashboardRepository {
  Future<List<Map<String, dynamic>>> getRecentActivity(String householdId);
}
