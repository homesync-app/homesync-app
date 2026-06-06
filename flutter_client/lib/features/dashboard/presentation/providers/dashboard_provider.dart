import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/recent_activity_merge.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

final recentActivityRealtimeDelayProvider = FutureProvider<bool>((ref) async {
  await Future<void>.delayed(const Duration(seconds: 4));
  return true;
});

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseDashboardRepository(client, ref);
}

@riverpod
GetRecentActivityUseCase getRecentActivityUseCase(
  Ref ref,
) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetRecentActivityUseCase(repository);
}

// Stream remoto puro. NO watchea optimistic ni hidden filter aca: si lo
// hiciera, al cambiar cualquiera de esos la subscripcion al stream se
// destruiria y recrearia, pasando por AsyncLoading -> la UI se pondria en
// blanco. La merge con optimistic/hidden ocurre en `recentActivityProvider`
// abajo, que es un Provider sync.
@riverpod
Stream<List<Map<String, dynamic>>> recentActivityRemote(Ref ref) {
  final householdIdAsync = ref.watch(householdIdProvider);

  return householdIdAsync.when(
    data: (householdId) {
      final userId = ref.watch(currentUserIdProvider);
      if (householdId == null || householdId.isEmpty || userId == null) {
        return Stream.value([]);
      }
      final repository = ref.watch(dashboardRepositoryProvider);
      return repository.watchRecentActivity(householdId, userId);
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.value([]),
  );
}

// Provider publico: combina el stream remoto con el estado optimista y el
// filtro de gastos ocultos. Al ser sync (Provider<AsyncValue<...>>), cuando
// cambia el optimistic solo recomputa la merge -> sin AsyncLoading -> sin
// blanqueo de UI. La firma del consumer (.when sobre AsyncValue) no cambia.
@riverpod
AsyncValue<List<Map<String, dynamic>>> recentActivity(Ref ref) {
  final optimistic = ref.watch(optimisticRecentActivityProvider);
  final hiddenExpenseIds = ref.watch(hiddenRecentExpenseIdsProvider);
  final householdId = ref.watch(householdIdProvider).value;
  final bootstrap = ref.watch(homeBootstrapProvider).value;
  final realtimeReady =
      ref.watch(recentActivityRealtimeDelayProvider).value ?? false;
  final remoteAsync = ref.watch(recentActivityRemoteProvider);
  final remoteHasPendingApproval =
      remoteAsync.hasValue && _hasPendingApprovalActivity(remoteAsync.value);

  if (!realtimeReady &&
      !remoteHasPendingApproval &&
      bootstrap != null &&
      bootstrap.householdId == householdId) {
    final visibleBootstrap = _filterHiddenExpenses(
      bootstrap.recentActivities,
      hiddenExpenseIds,
    );
    final scopedOptimistic = optimistic.where((activity) {
      return activity['household_id'] == householdId;
    }).toList();
    return AsyncValue.data(
      mergeOptimisticActivities(scopedOptimistic, visibleBootstrap),
    );
  }

  if (remoteAsync.hasError &&
      bootstrap != null &&
      bootstrap.householdId == householdId) {
    final visibleBootstrap = _filterHiddenExpenses(
      bootstrap.recentActivities,
      hiddenExpenseIds,
    );
    final scopedOptimistic = optimistic.where((activity) {
      return activity['household_id'] == householdId;
    }).toList();
    return AsyncValue.data(
      mergeOptimisticActivities(scopedOptimistic, visibleBootstrap),
    );
  }

  return remoteAsync.whenData((remote) {
    final visibleRemote = _filterHiddenExpenses(remote, hiddenExpenseIds);
    final scopedOptimistic = optimistic.where((activity) {
      return activity['household_id'] == householdId;
    }).toList();
    return mergeOptimisticActivities(scopedOptimistic, visibleRemote);
  });
}

bool _hasPendingApprovalActivity(List<Map<String, dynamic>>? activities) {
  if (activities == null) return false;
  return activities.any((activity) {
    final data = activity['data'] as Map<String, dynamic>? ?? const {};
    return activity['type'] == 'task_pending_approval' ||
        data['approval_status'] == 'pending_approval' ||
        data['task_status'] == 'pending_approval';
  });
}

@riverpod
class HiddenRecentExpenseIds extends _$HiddenRecentExpenseIds {
  @override
  Set<String> build() => const <String>{};

  void hide(String expenseId) {
    state = {...state, expenseId};
  }

  void restore(String expenseId) {
    state = {...state}..remove(expenseId);
  }
}

@riverpod
class OptimisticRecentActivity extends _$OptimisticRecentActivity {
  @override
  List<Map<String, dynamic>> build() => const [];

  void addTaskCompleted(
    TaskModel task, {
    String? activityId,
    DateTime? completedAt,
  }) {
    final householdId = ref.read(householdIdProvider).value ?? task.householdId;
    final userId = ref.read(currentUserIdProvider);
    if (householdId.isEmpty || userId == null) return;

    final members =
        ref.read(householdMembersProvider).value ?? const <MemberModel>[];
    final member = members.where((m) => m.userId == userId).firstOrNull;
    final now = DateTime.now();
    final activityCreatedAt = completedAt ?? now;

    final activity = <String, dynamic>{
      // Id SIEMPRE sintético, aunque llegue `activityId` del RPC. Esto garantiza
      // que la widget key del feed (que usa `activity['id']` con prefijo de
      // tipo) distinga la fila optimista local de la real del server cuando
      // ambas coexisten brevemente en la lista — la merge de
      // `mergeOptimisticActivities` igual suprime la optimista vía
      // `data['activity_id']` cuando el realtime emite la real.
      'id': 'optimistic-task-${task.id}-${now.microsecondsSinceEpoch}',
      'household_id': householdId,
      'type': 'task',
      'created_at': activityCreatedAt.toIso8601String(),
      'creator_id': userId,
      'optimistic': true,
      'data': {
        'user_name': member?.displayName ?? 'Alguien',
        'avatar_url': member?.avatarUrl,
        'title': task.title,
        'task_title': task.title,
        'title_key': task.titleKey,
        'activity_id': activityId,
        'task_id': task.id,
        'category': task.category,
        'xp_reward': task.xpReward,
        'coins_reward': task.coinReward,
      },
    };

    state = [
      activity,
      ...state.where((item) {
        final data = item['data'] as Map<String, dynamic>? ?? {};
        final itemActivityId = data['activity_id']?.toString();
        if (activityId != null && itemActivityId == activityId) {
          return false;
        }
        return item['id'] != activity['id'];
      }),
    ].take(8).toList();
  }

  void addRewardRedeemed({
    required String title,
    required String icon,
    required int cost,
  }) {
    final householdId = ref.read(householdIdProvider).value;
    final userId = ref.read(currentUserIdProvider);
    if (householdId == null || householdId.isEmpty || userId == null) return;

    final members =
        ref.read(householdMembersProvider).value ?? const <MemberModel>[];
    final member = members.where((m) => m.userId == userId).firstOrNull;
    final now = DateTime.now();
    final activity = <String, dynamic>{
      'id': 'optimistic-reward-${now.microsecondsSinceEpoch}',
      'household_id': householdId,
      'type': 'reward',
      'created_at': now.toIso8601String(),
      'creator_id': userId,
      'optimistic': true,
      'data': {
        'user_name': member?.displayName ?? 'Alguien',
        'avatar_url': member?.avatarUrl,
        'title': title,
        'reward_icon': icon,
        'reward_cost': cost,
      },
    };

    state = [activity, ...state].take(8).toList();
  }
}

List<Map<String, dynamic>> _filterHiddenExpenses(
  List<Map<String, dynamic>> activities,
  Set<String> hiddenExpenseIds,
) {
  if (hiddenExpenseIds.isEmpty) return activities;

  return activities.where((activity) {
    if (activity['type'] != 'expense') return true;
    final data = activity['data'] as Map<String, dynamic>? ?? {};
    final expenseId = data['expense_id']?.toString();
    return expenseId == null || !hiddenExpenseIds.contains(expenseId);
  }).toList();
}
