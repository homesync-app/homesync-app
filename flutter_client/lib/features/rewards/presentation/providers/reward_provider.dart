import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/supabase_reward_repository.dart';

part 'reward_provider.g.dart';

@riverpod
class Rewards extends _$Rewards {
  RealtimeChannel? _channel;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    final admin = ref.watch(adminProvider);
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    // Realtime setup
    _setupRealtime(householdId);

    final repo = ref.read(rewardRepositoryProvider);
    if (admin.isAdminUser) {
      final client = Supabase.instance.client;
      final rewardsResponse = await client.rpc(
        'qa_admin_get_rewards',
        params: {'p_household_id': householdId},
      );
      final rewards = List<Map<String, dynamic>>.from(rewardsResponse as List);
      if (rewards.isEmpty) {
        log.i('QA reward store empty, seeding default rewards...');
        await client.rpc(
          'qa_admin_seed_default_rewards',
          params: {'p_household_id': householdId},
        );
        final secondTry = await client.rpc(
          'qa_admin_get_rewards',
          params: {'p_household_id': householdId},
        );
        return List<Map<String, dynamic>>.from(secondTry as List);
      }
      return rewards;
    }

    final result = await repo.getRewards(householdId);

    return result.fold(
      (failure) {
        log.e('Error loading rewards: ${failure.message}');
        throw Exception(failure.message);
      },
      (rewards) async {
        // If the store is empty, automatically clone templates to provide immediate content
        if (rewards.isEmpty) {
          log.i('Reward store empty, auto-cloning templates...');
          final cloneResult = await repo.cloneTemplates();
          return cloneResult.fold(
            (l) => [], // If clone fails, return empty
            (r) async {
              // Fetch again after cloning
              final secondTry = await repo.getRewards(householdId);
              return secondTry.getOrElse((_) => []);
            },
          );
        }
        return rewards;
      },
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
            ref.invalidateSelf();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<Either<Failure, void>> suggestReward({
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
    String? category,
    bool isApproved = false,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    final householdId = await ref.read(householdIdProvider.future);

    if (userId == null || householdId == null) {
      log.w('Suggest reward aborted: missing userId or householdId');
      return const Left(ValidationFailure('Usuario o hogar no identificado'));
    }

    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.suggestReward(
      householdId: householdId,
      title: title,
      description: description,
      cost: cost,
      icon: icon,
      category: category,
      createdBy: userId,
      isApproved: isApproved,
    );

    return result.fold(
      (failure) {
        log.w('Suggest reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        ref.invalidateSelf();
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
        ref.invalidateSelf();
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
        ref.invalidateSelf();
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
        ref.invalidateSelf();
        return Right(success);
      },
    );
  }

  Future<Either<Failure, int>> cloneTemplates() async {
    final admin = ref.read(adminProvider);
    if (admin.isAdminUser) {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) {
        return const Left(ValidationFailure('Hogar QA no identificado'));
      }
      try {
        final seeded = await Supabase.instance.client.rpc(
          'qa_admin_seed_default_rewards',
          params: {'p_household_id': householdId},
        );
        ref.invalidateSelf();
        return Right((seeded as num).toInt());
      } catch (e) {
        log.w('QA seed rewards failure: $e');
        return Left(ServerFailure(e.toString()));
      }
    }

    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.cloneTemplates();

    return result.fold(
      (failure) {
        log.w('Clone templates failure: ${failure.message}');
        return Left(failure);
      },
      (count) {
        ref.invalidateSelf();
        return Right(count);
      },
    );
  }
}
