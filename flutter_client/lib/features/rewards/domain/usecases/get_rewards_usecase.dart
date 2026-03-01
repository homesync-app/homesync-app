import '../models/reward_model.dart';
import '../repositories/rewards_repository_interface.dart';

/// Use case: fetches all rewards for a given household.
/// Single responsibility: orchestrate fetching, apply any business rules.
class GetRewardsUseCase {
  final RewardsRepositoryInterface _repository;

  const GetRewardsUseCase(this._repository);

  Future<List<RewardModel>> call(String householdId) async {
    final rewards = await _repository.getRewards(householdId);
    // Business rule: only return active rewards (soft-delete safe)
    return rewards.where((r) => r.isActive).toList();
  }
}
