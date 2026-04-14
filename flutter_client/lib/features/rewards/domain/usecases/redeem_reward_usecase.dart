import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../repositories/reward_repository.dart';

/// Use case: redeem a reward.
/// Business rules live HERE, not in the provider or screen.
class RedeemRewardUseCase {
  final RewardRepository _repository;

  const RedeemRewardUseCase(this._repository);

  Future<Either<Failure, void>> call(String rewardId) =>
      _repository.redeemReward(rewardId);
}
