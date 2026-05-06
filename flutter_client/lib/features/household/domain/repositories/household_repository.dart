import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../models/household_model.dart';

/// Abstract contract: who provides household data.
abstract class HouseholdRepository {
  /// Returns the household ID for a given user, or null if not in one.
  Future<Either<Failure, String?>> getHouseholdId(String userId);

  /// Returns the full household model for a given household ID.
  Future<Either<Failure, HouseholdModel?>> getHousehold(String householdId);

  /// Returns a list of member user IDs for a household.
  Future<Either<Failure, List<String>>> getMemberIds(String householdId);

  /// Returns raw member data from Supabase
  Future<Either<Failure, List<Map<String, dynamic>>>> getHouseholdMembersRaw();

  /// Generates a new invitation code for the user's current household
  Future<Either<Failure, String>> generateInvitationCode();

  /// Joins a household using the provided code
  Future<Either<Failure, Map<String, dynamic>>> joinHousehold(String code);

  /// Resets the current user's data (tasks, expenses, balances, etc.)
  Future<Either<Failure, Map<String, dynamic>>> resetUserAccount();

  /// Removes a member from the household (only for owners)
  Future<Either<Failure, void>> removeMember(String userId);

  /// Resets user account and removes them from the household
  Future<Either<Failure, Map<String, dynamic>>> resetAndClearHousehold();

  /// Updates the default split ratio for the household
  Future<Either<Failure, void>> updateDefaultSplitRatio(
    String householdId,
    double ratio,
  );

  /// Updates household finance mode and default split ratio.
  Future<Either<Failure, void>> updateFinanceSettings(
    String householdId, {
    required String financeMode,
    required double defaultSplitRatio,
  });

  /// Updates the household type (solo, couple, family, friends)
  Future<Either<Failure, void>> updateHouseholdType(
    String householdId,
    String type,
  );

  /// Enables or disables household tasks for this household.
  Future<Either<Failure, void>> updateTasksEnabled(
    String householdId,
    bool enabled,
  );

  /// Updates the custom display role for a member (e.g. Padre, Madre)
  Future<Either<Failure, void>> updateMemberDisplayRole(
    String userId,
    String? displayRole,
  );

  /// Updates the permission type for a member.
  /// [type] must be one of `parent`, `guardian`, `teen`, `child`.
  Future<Either<Failure, void>> updateMemberType(String userId, String type);

  /// QA admin: restores a testing scenario to its seeded baseline.
  Future<Either<Failure, Map<String, dynamic>>> qaResetScenario(
    String householdId,
  );

  /// QA admin: creates a new dummy member inside a testing scenario.
  Future<Either<Failure, Map<String, dynamic>>> qaAddDummyMember({
    required String householdId,
    required String fullName,
    String? displayRole,
    String? avatarUrl,
    String role = 'member',
  });

  /// QA admin: removes a dummy QA member completely when safe to do so.
  Future<Either<Failure, Map<String, dynamic>>> qaDeleteDummyMember({
    required String householdId,
    required String userId,
  });
}
