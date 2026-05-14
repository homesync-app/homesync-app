import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/dashboard/data/repositories/supabase_dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:homesync_client/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

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
  final remoteAsync = ref.watch(recentActivityRemoteProvider);
  final optimistic = ref.watch(optimisticRecentActivityProvider);
  final hiddenExpenseIds = ref.watch(hiddenRecentExpenseIdsProvider);
  final householdId = ref.watch(householdIdProvider).value;

  return remoteAsync.whenData((remote) {
    final visibleRemote = _filterHiddenExpenses(remote, hiddenExpenseIds);
    final scopedOptimistic = optimistic.where((activity) {
      return activity['household_id'] == householdId;
    }).toList();
    return _mergeActivity(scopedOptimistic, visibleRemote);
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

  void addTaskCompleted(TaskModel task) {
    final householdId = ref.read(householdIdProvider).value;
    final userId = ref.read(currentUserIdProvider);
    if (householdId == null || userId == null) return;

    final members =
        ref.read(householdMembersProvider).value ?? const <MemberModel>[];
    final member = members.where((m) => m.userId == userId).firstOrNull;
    final now = DateTime.now();

    final activity = <String, dynamic>{
      'id': 'optimistic-task-${task.id}-${now.microsecondsSinceEpoch}',
      'household_id': householdId,
      'type': 'task',
      'created_at': now.toIso8601String(),
      'creator_id': userId,
      'optimistic': true,
      'data': {
        'user_name': member?.displayName ?? 'Alguien',
        'avatar_url': member?.avatarUrl,
        'title': task.title,
        'task_title': task.title,
        'title_key': task.titleKey,
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
        return data['task_id']?.toString() != task.id;
      }),
    ].take(8).toList();
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

List<Map<String, dynamic>> _mergeActivity(
  List<Map<String, dynamic>> optimistic,
  List<Map<String, dynamic>> remote,
) {
  final remoteTaskIds = remote
      .map((activity) => activity['data'] as Map<String, dynamic>? ?? {})
      .map((data) => data['task_id']?.toString())
      .whereType<String>()
      .toSet();

  final visibleOptimistic = optimistic.where((activity) {
    final data = activity['data'] as Map<String, dynamic>? ?? {};
    final taskId = data['task_id']?.toString();
    return taskId == null || !remoteTaskIds.contains(taskId);
  });

  final merged = [...visibleOptimistic, ...remote];
  merged.sort((a, b) {
    final aTime = DateTime.tryParse(a['created_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = DateTime.tryParse(b['created_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return bTime.compareTo(aTime);
  });

  return merged.take(30).toList();
}
