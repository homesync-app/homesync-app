import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../models/reward_model.dart';
import '../repositories/reward_repository.dart';

/// Use case: fetches all rewards for a given household.
/// Single responsibility: orchestrate fetching, apply any business rules.
class GetRewardsUseCase {
  final RewardRepository _repository;

  const GetRewardsUseCase(this._repository);

  Future<Either<Failure, List<RewardModel>>> call(
    String householdId, {
    int? limit,
    int? offset,
  }) async {
    final rewards = await _repository.getRewards(
      householdId,
      limit: limit,
      offset: offset,
    );
    return rewards.map(
      (items) => items
          .map(RewardModel.fromJson)
          .where((reward) => reward.isActive)
          .toList(),
    );
  }
}
