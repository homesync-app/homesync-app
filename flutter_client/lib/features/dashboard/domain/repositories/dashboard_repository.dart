abstract class DashboardRepository {
  Future<List<Map<String, dynamic>>> getRecentActivity(
    String householdId,
    String userId,
  );

  Stream<List<Map<String, dynamic>>> watchRecentActivity(
    String householdId,
    String userId,
  );
}
