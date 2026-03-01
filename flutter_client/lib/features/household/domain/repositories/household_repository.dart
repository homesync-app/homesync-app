import '../models/household_model.dart';

/// Abstract contract: who provides household data.
abstract class HouseholdRepository {
  /// Returns the household ID for a given user, or null if not in one.
  Future<String?> getHouseholdId(String userId);

  /// Returns the full household model for a given household ID.
  Future<HouseholdModel?> getHousehold(String householdId);

  /// Returns a list of member user IDs for a household.
  Future<List<String>> getMemberIds(String householdId);
}
