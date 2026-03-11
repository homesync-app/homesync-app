import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

/// Abstract contract for rewards data.
abstract class RewardRepository {
  /// Fetch all rewards for a household.
  Future<Either<Failure, List<Map<String, dynamic>>>> getRewards(
      String householdId);

  /// Create or suggest a new reward.
  Future<Either<Failure, void>> suggestReward({
    required String householdId,
    required String title,
    String? description,
    required int cost,
    required String icon,
    required String createdBy,
  });

  /// Approve a suggested reward (owner only).
  Future<Either<Failure, void>> approveReward(String rewardId);

  /// Redeem a reward (spends coins).
  Future<Either<Failure, void>> redeemReward(String rewardId);

  /// Delete a reward.
  Future<Either<Failure, void>> deleteReward(String rewardId);

  /// Clone reward templates to the current household.
  Future<Either<Failure, int>> cloneTemplates();
}
