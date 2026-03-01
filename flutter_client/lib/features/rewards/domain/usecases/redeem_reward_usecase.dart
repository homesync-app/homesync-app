import '../repositories/rewards_repository_interface.dart';

/// Use case: redeem a reward.
/// Business rules live HERE, not in the provider or screen.
class RedeemRewardUseCase {
  final RewardsRepositoryInterface _repository;

  const RedeemRewardUseCase(this._repository);

  /// Throws [InsufficientCoinsFailure] if balance is too low (from repository).
  /// Throws [ServerFailure] on network error.
  Future<void> call(String rewardId) async {
    await _repository.redeemReward(rewardId);
  }
}
