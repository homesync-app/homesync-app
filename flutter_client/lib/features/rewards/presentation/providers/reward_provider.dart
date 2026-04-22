import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/data/repositories/supabase_reward_repository.dart';
import 'package:homesync_client/features/rewards/domain/models/reward_model.dart';
import 'package:homesync_client/features/rewards/domain/usecases/get_rewards_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'reward_provider.g.dart';

const _familyDefaultRewards = <Map<String, dynamic>>[
  {
    'title': 'Postre especial',
    'description': 'Elegir un postre favorito para despues de cenar.',
    'cost': 25,
    'icon': '🍨',
    'category': 'familia',
    'target_type': 'child',
  },
  {
    'title': 'Elegir la cena',
    'description': 'Decidir el menu de una noche en casa.',
    'cost': 40,
    'icon': '🍕',
    'category': 'familia',
    'target_type': 'child',
  },
  {
    'title': '15 minutos extra de pantalla',
    'description': 'Un ratito mas para jugar o mirar algo.',
    'cost': 35,
    'icon': '📱',
    'category': 'familia',
    'target_type': 'child',
  },
  {
    'title': 'Juguete o premio pequeno',
    'description': 'Canje por algo simple elegido con un adulto.',
    'cost': 90,
    'icon': '🧩',
    'category': 'familia',
    'target_type': 'child',
  },
  {
    'title': 'Cafe o mate preparado',
    'description': 'Un mimo simple tomado del modo pareja.',
    'cost': 30,
    'icon': '☕',
    'category': 'familia',
    'target_type': 'adult',
  },
  {
    'title': '15 minutos de masajes',
    'description': 'Un premio corto para bajar un cambio.',
    'cost': 60,
    'icon': '💆',
    'category': 'familia',
    'target_type': 'adult',
  },
  {
    'title': 'Vale por elegir la peli',
    'description': 'Elegis que ver sin negociar esa noche.',
    'cost': 55,
    'icon': '🎬',
    'category': 'familia',
    'target_type': 'adult',
  },
  {
    'title': 'Cena casera especial',
    'description': 'Una noche distinta con algo rico hecho en casa.',
    'cost': 95,
    'icon': '🍽️',
    'category': 'familia',
    'target_type': 'adult',
  },
  {
    'title': 'Noche de peli',
    'description': 'Plan simple para disfrutar todos juntos.',
    'cost': 80,
    'icon': '🎥',
    'category': 'familia',
    'target_type': 'all',
  },
  {
    'title': 'Helado para todos',
    'description': 'Salida o pedido de helado familiar.',
    'cost': 110,
    'icon': '🍦',
    'category': 'familia',
    'target_type': 'all',
  },
  {
    'title': 'Pedir comida',
    'description': 'Una noche sin cocinar para toda la familia.',
    'cost': 180,
    'icon': '🥡',
    'category': 'familia',
    'target_type': 'all',
  },
  {
    'title': 'Plan del fin de semana',
    'description': 'Elegir una salida o actividad para hacer juntos.',
    'cost': 160,
    'icon': '🌟',
    'category': 'familia',
    'target_type': 'all',
  },
];

const _rewardsPageSize = 20;

class RewardsPageState {
  final List<RewardModel> items;
  final bool hasMore;
  final bool isLoadingMore;

  const RewardsPageState({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
  });

  RewardsPageState copyWith({
    List<RewardModel>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return RewardsPageState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class _RewardsPageChunk {
  final List<RewardModel> items;
  final bool hasMore;

  const _RewardsPageChunk({
    required this.items,
    required this.hasMore,
  });
}

final getRewardsUseCaseProvider = Provider<GetRewardsUseCase>((ref) {
  return GetRewardsUseCase(ref.read(rewardRepositoryProvider));
});

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

    _setupRealtime(householdId);

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
    if (caps.type == HouseholdType.family) {
      if (isAdminQa) {
        final client = ref.read(supabaseClientProvider);
        await client.rpc(
          'qa_admin_seed_default_rewards',
          params: {'p_household_id': householdId},
        );
        return;
      }

      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) return;

      final client = ref.read(supabaseClientProvider);
      final rows = _familyDefaultRewards
          .map(
            (reward) => {
              'household_id': householdId,
              'title': reward['title'],
              'description': reward['description'],
              'cost': reward['cost'],
              'icon': reward['icon'],
              'category': reward['category'],
              'created_by': currentUserId,
              'is_approved': true,
              'is_active': true,
              'target_type': reward['target_type'],
            },
          )
          .toList();
      await client.from('rewards').insert(rows);
      return;
    }

    if (isAdminQa) {
      final client = ref.read(supabaseClientProvider);
      await client.rpc(
        'qa_admin_seed_default_rewards',
        params: {'p_household_id': householdId},
      );
      return;
    }

    final repo = ref.read(rewardRepositoryProvider);
    await repo.cloneTemplates();
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
        ref.invalidateSelf();
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
        final client = ref.read(supabaseClientProvider);
        final seeded = await client.rpc(
          'qa_admin_seed_default_rewards',
          params: {'p_household_id': householdId},
        );
        ref.invalidateSelf();
        return Right((seeded as num).toInt());
      } catch (e, stack) {
        log.w('QA seed rewards failure: $e', error: e, stackTrace: stack);
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

class PaginatedRewardsController extends AsyncNotifier<RewardsPageState> {
  @override
  Future<RewardsPageState> build() async {
    final chunk = await _fetchChunk(offset: 0);
    return RewardsPageState(
      items: chunk.items,
      hasMore: chunk.hasMore,
      isLoadingMore: false,
    );
  }

  Future<_RewardsPageChunk> _fetchChunk({required int offset}) async {
    final admin = ref.read(adminProvider);
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) {
      return const _RewardsPageChunk(items: [], hasMore: false);
    }

    final household = await ref.read(currentHouseholdProvider.future);
    final caps = HouseholdCapabilities(
      type: HouseholdType.fromString(household?.householdType),
      tasksEnabled: household?.tasksEnabled ?? true,
    );

    if (admin.isAdminUser) {
      final client = ref.read(supabaseClientProvider);
      var rows = List<Map<String, dynamic>>.from(
        await client.rpc(
          'qa_admin_get_rewards',
          params: {'p_household_id': householdId},
        ) as List,
      );

      if (rows.isEmpty && offset == 0) {
        await ref.read(rewardsProvider.notifier)._seedDefaultRewards(
              householdId: householdId,
              caps: caps,
              isAdminQa: true,
            );
        rows = List<Map<String, dynamic>>.from(
          await client.rpc(
            'qa_admin_get_rewards',
            params: {'p_household_id': householdId},
          ) as List,
        );
      }

      final activeRewards = rows
          .map(RewardModel.fromJson)
          .where((reward) => reward.isActive)
          .toList();
      final end = (offset + _rewardsPageSize).clamp(0, activeRewards.length);
      final page = offset >= activeRewards.length
          ? const <RewardModel>[]
          : activeRewards.sublist(offset, end);
      return _RewardsPageChunk(
        items: page,
        hasMore: end < activeRewards.length,
      );
    }

    final useCase = ref.read(getRewardsUseCaseProvider);
    var result = await useCase(
      householdId,
      limit: _rewardsPageSize,
      offset: offset,
    );

    if (result.isRight() && result.getOrElse((_) => const []).isEmpty && offset == 0) {
      await ref.read(rewardsProvider.notifier)._seedDefaultRewards(
            householdId: householdId,
            caps: caps,
            isAdminQa: false,
          );
      result = await useCase(
        householdId,
        limit: _rewardsPageSize,
        offset: offset,
      );
    }

    return result.fold(
      (failure) => throw failure,
      (items) => _RewardsPageChunk(
        items: items,
        hasMore: items.length == _rewardsPageSize,
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<RewardsPageState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final chunk = await _fetchChunk(offset: 0);
      return RewardsPageState(
        items: chunk.items,
        hasMore: chunk.hasMore,
        isLoadingMore: false,
      );
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final chunk = await _fetchChunk(offset: current.items.length);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...chunk.items],
          hasMore: chunk.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      log.e(
        'Paginated rewards loadMore failed: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

final paginatedRewardsProvider =
    AsyncNotifierProvider<PaginatedRewardsController, RewardsPageState>(
      PaginatedRewardsController.new,
    );

@riverpod
Future<List<RewardModel>> filteredRewards(FilteredRewardsRef ref) async {
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
