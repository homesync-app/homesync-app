import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import '../../domain/repositories/reward_repository.dart';
import '../../data/repositories/supabase_reward_repository.dart';

final rewardsProvider =
    AsyncNotifierProvider<RewardsNotifier, List<Map<String, dynamic>>>(() {
  return RewardsNotifier();
});

class RewardsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.getRewards(householdId);

    return result.fold(
      (failure) {
        log.e('Error loading rewards: ${failure.message}');
        throw Exception(failure.message);
      },
      (rewards) => rewards,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> suggestReward({
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final householdId = await ref.read(householdIdProvider.future);

    if (userId == null || householdId == null) {
      log.w('Suggest reward aborted: missing userId or householdId');
      return;
    }

    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.suggestReward(
      householdId: householdId,
      title: title,
      description: description,
      cost: cost,
      icon: icon,
      createdBy: userId,
    );

    result.fold(
      (failure) => log.w('Suggest reward failure: ${failure.message}'),
      (_) => refresh(),
    );
  }

  Future<void> approveReward(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.approveReward(rewardId);

    result.fold(
      (failure) => log.w('Approve reward failure: ${failure.message}'),
      (_) => refresh(),
    );
  }

  Future<void> redeem(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.redeemReward(rewardId);

    result.fold(
      (failure) => log.w('Redeem reward failure: ${failure.message}'),
      (_) => refresh(),
    );
  }

  Future<void> deleteReward(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.deleteReward(rewardId);

    result.fold(
      (failure) => log.w('Delete reward failure: ${failure.message}'),
      (_) => refresh(),
    );
  }
}
