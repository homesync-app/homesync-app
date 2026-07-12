import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/data/repositories/supabase_reward_repository.dart';
import 'package:homesync_client/features/rewards/domain/models/reward_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'reward_provider.g.dart';

@riverpod
class Rewards extends _$Rewards {
  RealtimeChannel? _channel;

  @override
  Future<List<RewardModel>> build() async {
    final admin = ref.watch(adminProvider);
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final household = await ref.watch(currentHouseholdProvider.future);
    final caps = HouseholdCapabilities(
      type: HouseholdType.fromString(household?.householdType),
      tasksEnabled: household?.tasksEnabled ?? true,
    );

    final repo = ref.read(rewardRepositoryProvider);
    List<Map<String, dynamic>> rawRewards = [];

    if (admin.isAdminUser) {
      final client = ref.read(supabaseClientProvider);
      final rewardsResponse = await client.rpc(
        'qa_admin_get_rewards',
        params: {'p_household_id': householdId},
      );
      rawRewards = List<Map<String, dynamic>>.from(rewardsResponse as List);
      if (rawRewards.isEmpty) {
        log.i('QA reward store empty, seeding default rewards...');
        await _seedDefaultRewards(
          householdId: householdId,
          caps: caps,
          isAdminQa: true,
        );
        final secondTry = await client.rpc(
          'qa_admin_get_rewards',
          params: {'p_household_id': householdId},
        );
        rawRewards = List<Map<String, dynamic>>.from(secondTry as List);
      }
    } else {
      final result = await repo.getRewards(householdId);
      rawRewards = result.getOrElse((_) => []);

      if (rawRewards.isEmpty) {
        log.i('Reward store empty, seeding defaults for ${caps.type.name}...');
        await _seedDefaultRewards(
          householdId: householdId,
          caps: caps,
          isAdminQa: false,
        );
        final secondTry = await repo.getRewards(householdId);
        rawRewards = secondTry.getOrElse((_) => []);
      }
    }

    // Subscribe to realtime AFTER seeding to avoid cascading invalidations
    // while inserts are in flight, which could trigger repeated seeding.
    _setupRealtime(householdId);

    return rawRewards.map(RewardModel.fromJson).toList();
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

  Future<void> _seedDefaultRewards({
    required String householdId,
    required HouseholdCapabilities caps,
    required bool isAdminQa,
  }) async {
    if (isAdminQa) {
      final client = ref.read(supabaseClientProvider);
      await client.rpc(
        'qa_admin_seed_default_rewards',
        params: {'p_household_id': householdId},
      );
      return;
    }

    final repo = ref.read(rewardRepositoryProvider);
    // Ambos RPC son idempotentes del lado del servidor (guard de existencia
    // + lock), así que dos miembros sembrando a la vez no duplican catálogo.
    if (caps.type == HouseholdType.family) {
      await repo.seedFamilyDefaults(householdId);
    } else {
      await repo.cloneTemplates();
    }
  }

  Future<Either<Failure, void>> suggestReward({
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
    String? category,
    bool isApproved = false,
    String targetType = 'all',
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
      targetType: targetType,
    );

    return result.fold(
      (failure) {
        log.w('Suggest reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        if (ref.mounted) ref.invalidateSelf();
        return Right(success);
      },
    );
  }

  Future<Either<Failure, void>> approveReward(String rewardId) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId != null) {
      final members = await ref.read(householdMembersProvider.future);
      final currentMember =
          members.where((m) => m.userId == currentUserId).firstOrNull;
      if (currentMember != null && !currentMember.isAdult) {
        return const Left(
          ValidationFailure('Solo los adultos pueden aprobar premios'),
        );
      }
    }

    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.approveReward(rewardId);

    return result.fold(
      (failure) {
        log.w('Approve reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        if (ref.mounted) ref.invalidateSelf();
        return Right(success);
      },
    );
  }

  Future<Either<Failure, void>> updateReward({
    required String rewardId,
    required String title,
    String? description,
    required int cost,
    required String icon,
    String? category,
    required String targetType,
  }) async {
    final repo = ref.read(rewardRepositoryProvider);
    final result = await repo.updateReward(
      rewardId: rewardId,
      title: title,
      description: description,
      cost: cost,
      icon: icon,
      category: category,
      targetType: targetType,
    );

    return result.fold(
      (failure) {
        log.w('Update reward failure: ${failure.message}');
        return Left(failure);
      },
      (success) {
        if (ref.mounted) ref.invalidateSelf();
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
        // NOTE: deliberately NOT calling ref.invalidateSelf() here.
        // Redeeming only spends the user's coins — the reward list rows are
        // unchanged, so reloading the list would drop the whole rewards page
        // to AsyncLoading (a jarring full-page "reload"). We only refresh the
        // things that actually changed: the coin balance and the activity
        // feed. Genuine reward-row changes still arrive via the realtime
        // channel set up in build().
        // Guard `ref`: this notifier is auto-dispose and may be torn down during
        // the redeem await, which would make these invalidations throw.
        if (ref.mounted) {
          ref.invalidate(recentActivityProvider);
          ref.invalidate(userBalanceProvider);
        }
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
        if (ref.mounted) ref.invalidateSelf();
        return Right(success);
      },
    );
  }

  /// Siembra el catálogo por defecto según el modo del hogar (familia usa su
  /// propio set server-side; el resto clona la boutique de pareja). Devuelve
  /// cuántos premios se crearon — 0 significa que ya había filas (por ejemplo
  /// propuestas pendientes) y no se cargó nada nuevo.
  Future<Either<Failure, int>> seedDefaults() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) {
      return const Left(ValidationFailure('Hogar no identificado'));
    }

    final admin = ref.read(adminProvider);
    if (admin.isAdminUser) {
      try {
        final client = ref.read(supabaseClientProvider);
        final seeded = await client.rpc(
          'qa_admin_seed_default_rewards',
          params: {'p_household_id': householdId},
        );
        if (ref.mounted) ref.invalidateSelf();
        return Right((seeded as num).toInt());
      } catch (e, stack) {
        log.w('QA seed rewards failure: $e', error: e, stackTrace: stack);
        return Left(ServerFailure(e.toString()));
      }
    }

    final household = await ref.read(currentHouseholdProvider.future);
    final caps = HouseholdCapabilities(
      type: HouseholdType.fromString(household?.householdType),
      tasksEnabled: household?.tasksEnabled ?? true,
    );

    final repo = ref.read(rewardRepositoryProvider);
    final result = caps.type == HouseholdType.family
        ? await repo.seedFamilyDefaults(householdId)
        : await repo.cloneTemplates();

    return result.fold(
      (failure) {
        log.w('Seed defaults failure: ${failure.message}');
        return Left(failure);
      },
      (count) {
        if (ref.mounted) ref.invalidateSelf();
        return Right(count);
      },
    );
  }
}

@riverpod
Future<List<RewardModel>> filteredRewards(Ref ref) async {
  final rewards = await ref.watch(rewardsProvider.future);
  final members = await ref.watch(householdMembersProvider.future);
  final currentUserId = ref.read(currentUserIdProvider);

  final currentMember =
      members.where((m) => m.userId == currentUserId).firstOrNull;
  if (currentMember == null) return rewards;

  if (currentMember.isAdult) {
    return rewards;
  }

  return rewards.where((reward) {
    final isTargeted =
        reward.targetType == 'all' || reward.targetType == 'child';
    final isVisible = reward.isApproved || reward.createdBy == currentUserId;
    return isTargeted && isVisible;
  }).toList();
}
