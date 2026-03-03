import '../models/household_model.dart';

/// Abstract contract: who provides household data.
abstract class HouseholdRepository {
  /// Returns the household ID for a given user, or null if not in one.
  Future<String?> getHouseholdId(String userId);

  /// Returns the full household model for a given household ID.
  Future<HouseholdModel?> getHousehold(String householdId);

  /// Returns a list of member user IDs for a household.
  Future<List<String>> getMemberIds(String householdId);

  /// Returns raw member data from Supabase
  Future<List<Map<String, dynamic>>> getHouseholdMembersRaw();

  /// Generates a new invitation code for the user's current household
  Future<String> generateInvitationCode();

  /// Joins a household using the provided code
  Future<Map<String, dynamic>> joinHousehold(String code);

  /// Resets the current user's data (tasks, expenses, balances, etc.)
  Future<Map<String, dynamic>> resetUserAccount();

  /// Removes a member from the household (only for owners)
  Future<void> removeMember(String userId);

  /// Resets user account and removes them from the household
  Future<Map<String, dynamic>> resetAndClearHousehold();
}
