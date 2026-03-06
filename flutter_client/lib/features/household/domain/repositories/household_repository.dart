import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
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
}
