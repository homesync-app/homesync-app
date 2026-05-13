import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/data/repositories/supabase_reward_repository.dart';
import 'package:homesync_client/features/rewards/domain/repositories/reward_repository.dart';
import 'package:homesync_client/features/rewards/presentation/providers/reward_provider.dart';

class FakePaginatedRewardRepository implements RewardRepository {
  final List<Map<String, dynamic>> rewards;

  FakePaginatedRewardRepository(this.rewards);

  @override
  Future<Either<Failure, void>> approveReward(String rewardId) async =>
      const Right(null);

  @override
  Future<Either<Failure, int>> cloneTemplates() async => const Right(0);

  @override
  Future<Either<Failure, void>> deleteReward(String rewardId) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRewards(
    String householdId, {
    int? limit,
    int? offset,
  }) async {
    final start = offset ?? 0;
    final size = limit ?? rewards.length;
    if (start >= rewards.length) {
      return const Right([]);
    }

    final end = (start + size).clamp(0, rewards.length);
    return Right(rewards.sublist(start, end));
  }

  @override
  Future<Either<Failure, void>> redeemReward(String rewardId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> suggestReward({
    required String householdId,
    required String title,
    String? description,
    required int cost,
    required String icon,
    String? category,
    required String createdBy,
    bool isApproved = false,
    String targetType = 'all',
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateReward({
    required String rewardId,
    required String title,
    String? description,
    required int cost,
    required String icon,
    String? category,
    required String targetType,
  }) async =>
      const Right(null);
}

Map<String, dynamic> _rewardJson(int index) {
  return {
    'id': 'reward-$index',
    'household_id': 'house-1',
    'title': 'Reward $index',
    'description': 'Description $index',
    'cost': 10 + index,
    'icon': 'gift',
    'category': 'mimos',
    'created_by': 'user-1',
    'is_approved': true,
    'is_active': true,
    'target_type': 'all',
    'created_at': DateTime(2026, 1, 1).toIso8601String(),
  };
}

void main() {
  test('paginatedRewardsProvider loads another page and updates hasMore',
      () async {
    final container = ProviderContainer(
      overrides: [
        rewardRepositoryProvider.overrideWith(
          (ref) => FakePaginatedRewardRepository(
            List.generate(25, _rewardJson),
          ),
        ),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(paginatedRewardsProvider.future);
    expect(initial.items, hasLength(20));
    expect(initial.hasMore, isTrue);

    await container.read(paginatedRewardsProvider.notifier).loadMore();

    final paged = container.read(paginatedRewardsProvider).value;
    expect(paged, isNotNull);
    expect(paged!.items, hasLength(25));
    expect(paged.hasMore, isFalse);
    expect(paged.isLoadingMore, isFalse);
  });
}
