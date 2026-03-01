import '../models/reward_model.dart';

/// Abstract contract for the rewards data source.
/// The domain (Use Cases, Providers) depends ONLY on this interface,
/// never on the concrete Supabase implementation.
abstract class RewardsRepositoryInterface {
  Future<List<RewardModel>> getRewards(String householdId);

  Future<void> suggestReward({
    required String householdId,
    required String title,
    String? description,
    required int cost,
    String icon,
    required String userId,
  });

  Future<void> approveReward(String rewardId);

  /// Throws [InsufficientCoinsFailure] if not enough coins.
  Future<void> redeemReward(String rewardId);

  Future<void> deleteReward(String rewardId);
}
