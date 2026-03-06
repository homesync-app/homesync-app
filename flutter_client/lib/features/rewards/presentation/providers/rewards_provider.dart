import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/supabase_reward_repository.dart';

final rewardsProvider =
    AsyncNotifierProvider<RewardsNotifier, List<Map<String, dynamic>>>(() {
  return RewardsNotifier();
});

class RewardsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    // Realtime setup
    _setupRealtime(householdId);

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

  void _setupRealtime(String householdId) {
    _channel?.unsubscribe();
    final client = ref.read(supabaseClientProvider);

    _channel = client
        .channel('rewards_realtime_$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableRewards,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (payload) {
            log.i('Realtime reward change detected: ${payload.eventType}');
            refresh();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<Either<Failure, void>> suggestReward({
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final householdId = await ref.read(householdIdProvider.future);

    if (userId == null || householdId == null) {
      log.w('Suggest reward aborted: missing userId or householdId');
      return Left(ValidationFailure('Usuario o hogar no identificado'));
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

    return result.fold(
      (failure) {
        log.w('Suggest reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        refresh();
        return Right(success);
      },
    );
  }

  Future<Either<Failure, void>> approveReward(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.approveReward(rewardId);

    return result.fold(
      (failure) {
        log.w('Approve reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        refresh();
        return Right(success);
      },
    );
  }

  Future<Either<Failure, void>> redeem(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.redeemReward(rewardId);

    return result.fold(
      (failure) {
        log.w('Redeem reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        refresh();
        return Right(success);
      },
    );
  }

  Future<Either<Failure, void>> deleteReward(String rewardId) async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.deleteReward(rewardId);

    return result.fold(
      (failure) {
        log.w('Delete reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        refresh();
        return Right(success);
      },
    );
  }

  Future<Either<Failure, int>> cloneTemplates() async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.cloneTemplates();

    return result.fold(
      (failure) {
        log.w('Clone templates failure: ${failure.message}');
        return Left(failure);
      },
      (count) {
        refresh();
        return Right(count);
      },
    );
  }
}
