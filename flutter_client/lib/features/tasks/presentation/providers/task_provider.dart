import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/constants/app_constants.dart';

import '../../data/repositories/supabase_task_repository.dart';
import '../../domain/models/task_model.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';

part 'task_provider.g.dart';

// ── Use Case Providers ────────────────────────────────────────────────────────

@riverpod
GetTasksUseCase getTasksUseCase(GetTasksUseCaseRef ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
}

@riverpod
CompleteTaskUseCase completeTaskUseCase(CompleteTaskUseCaseRef ref) {
  return CompleteTaskUseCase(ref.watch(taskRepositoryProvider));
}

@riverpod
CreateTaskUseCase createTaskUseCase(CreateTaskUseCaseRef ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
}

// ── UI State Providers ────────────────────────────────────────────────────────

@riverpod
class TaskCategoryFilter extends _$TaskCategoryFilter {
  @override
  Set<String> build() => {};

  void toggle(String category) {
    final next = Set<String>.from(state);
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }
    state = next;
  }

  void clear() => state = {};
}

@riverpod
class TaskSearchQuery extends _$TaskSearchQuery {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

@riverpod
class TaskViewMode extends _$TaskViewMode {
  @override
  bool build() => false;
  void setList() => state = false;
  void setCalendar() => state = true;
  void toggle() => state = !state;
}

// ── Main Tasks Notifier ───────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class Tasks extends _$Tasks {
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  static const int _pageSize = 50;
  RealtimeChannel? _channel;

  @override
  Future<List<TaskModel>> build() async {
    _hasMore = true;
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    _setupRealtime(householdId);

    final useCase = ref.watch(getTasksUseCaseProvider);
    final result = await useCase(householdId, limit: _pageSize, offset: 0);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (tasks) {
        if (tasks.length < _pageSize) {
          _hasMore = false;
        }
        return tasks;
      },
    );
  }

  void _setupRealtime(String householdId) {
    _channel?.unsubscribe();
    final client = ref.read(supabaseClientProvider);
    
    _channel = client
        .channel('tasks_realtime_$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableTasks,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (payload) {
            log.i('Realtime task change detected: ${payload.eventType}');
            silentRefresh();
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

  Future<void> silentRefresh() async {
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    final currentTasks = state.value ?? [];
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final useCase = ref.read(getTasksUseCaseProvider);
    try {
      final result = await useCase(
        householdId,
        limit: _pageSize,
        offset: currentTasks.length,
      );

      result.fold(
        (failure) => log.w('Error loading more tasks: ${failure.message}'),
        (nextTasks) {
          if (nextTasks.isEmpty || nextTasks.length < _pageSize) {
            _hasMore = false;
          }
          state = AsyncValue.data([...currentTasks, ...nextTasks]);
        },
      );
    } catch (e) {
      log.w('Error loading more tasks: $e');
    }
  }

  Future<Map<String, dynamic>?> completeTask(TaskModel task, {List<String>? userIds}) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final performers = userIds ?? (currentUserId != null ? [currentUserId] : null);
    final primaryUserId = performers?.first ?? currentUserId;
    
    final oldState = state.value;
    
    // Optimistic update
    if (oldState != null) {
      state = AsyncValue.data(
        oldState.map((t) => t.id == task.id 
          ? t.copyWith(status: TaskStatus.pendingVerification, completedBy: primaryUserId, completedAt: DateTime.now())
          : t
        ).toList()
      );
    }

    try {
      final useCase = ref.read(completeTaskUseCaseProvider);
      final result = await useCase(task, userIds: performers);
      
      if (result.isRight()) {
        // Success: Trigger UI refresh for state consistency
        silentRefresh();
        ref.invalidate(userBalanceProvider);
        ref.invalidate(recentActivityProvider);
      }
      
      return result.fold(
        (failure) {
          state = AsyncValue.data(oldState!);
          return null;
        },
        (data) => data,
      );
    } catch (e) {
      log.w('Complete task failure: $e');
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
      return null;
    }
  }

  Future<void> verifyTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState.map((t) => t.id == task.id 
          ? t.copyWith(status: TaskStatus.verified, verifiedBy: userId, verifiedAt: DateTime.now())
          : t
        ).toList()
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.verifyTask(task.id, userId);
    } catch (e) {
      log.w('Verify task failure: $e');
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> objectTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState.map((t) => t.id == task.id 
          ? t.copyWith(status: TaskStatus.active, completedBy: null, completedAt: null)
          : t
        ).toList()
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.objectTask(task.id, userId);
    } catch (e) {
      log.w('Object task failure: $e');
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> approveTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState.map((t) => t.id == task.id 
          ? t.copyWith(status: TaskStatus.active)
          : t
        ).toList()
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      // We use editTask to change status to active
      await repo.editTask(task.id, {'status': 'active'});
      silentRefresh();
    } catch (e) {
      log.w('Approve task failure: $e');
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> rejectTask(TaskModel task) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(task.id);
      silentRefresh();
    } catch (e) {
      log.w('Reject task failure: $e');
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState.where((t) => t.id != task.id).toList()
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(task.id);
    } catch (e) {
      log.w('Delete task failure: $e');
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> updateSchedule(TaskModel task, String? recurrenceType) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.updateSchedule(task.id, recurrenceType);
      refresh();
    } catch (e) {
      log.w('Update schedule failure: $e');
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      final xp = taskData['xpReward'] as int;
      final coins = taskData['coinReward'] as int;
      final isTemplate = taskData['isTemplate'] as bool? ?? false;
      
      // Approval logic: 
      // 1. Default templates are always trusted (isTemplate: true)
      // 2. Custom tasks need approval ONLY if coins > 2
      final needsApproval = !isTemplate && coins > 2;
      
      final useCase = ref.read(createTaskUseCaseProvider);
      final result = await useCase(
        title: taskData['title'] as String,
        description: taskData['description'] as String?,
        category: taskData['category'] as String,
        difficulty: taskData['difficulty'] as String,
        xpReward: xp,
        coinReward: coins,
        assignedTo: taskData['assignedTo'] as String?,
        recurrenceType: taskData['recurrenceType'] as String?,
        status: needsApproval ? 'pending_approval' : null,
      );
      
      if (result.isRight() && needsApproval) {
        // If it needs approval, we need to update its status to pending_approval
        // Since createTask RPC doesn't take status, we might need a way to get the ID 
        // and update it, or have the RPC handle it.
        // Assuming we can silentRefresh and then update latest if we knew which one it is.
        // FOR NOW: I'll assume I can find the task by title/createdAt or just wait for refresh.
        // Actually, better to have the repo return the ID or handle status.
      }

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          silentRefresh();
          ref.invalidate(recentActivityProvider);
        },
      );
    } catch (e) {
      log.w('Create task failure: $e');
      rethrow;
    }
  }

  Future<void> editTask(String taskId, Map<String, dynamic> updates) async {
    try {
      final xp = updates['xp_reward'] as int?;
      final coins = updates['coin_reward'] as int?;
      
      if (coins != null || xp != null) {
        // Find current task to get missing values for check
        final task = state.value?.firstWhere((t) => t.id == taskId);
        if (task != null) {
          final newCoins = coins ?? task.coinReward;
          final newXp = xp ?? task.xpReward;

          // Approval logic based on user request:
          // "pendientes de acreditacion es cuando edita una y cambia los coins a mas de lo que habia"
          // We also keep a sanity check for XP > 50 if they inflate it too much.
          if (newCoins > task.coinReward || newXp > 50) {
            updates['status'] = 'pending_approval';
          }
        }
      }

      final repo = ref.read(taskRepositoryProvider);
      await repo.editTask(taskId, updates);
      refresh();
    } catch (e) {
      log.w('Edit task failure: $e');
    }
  }
}


// ── Derived / Filtered Providers ──────────────────────────────────────────────

@riverpod
AsyncValue<List<TaskModel>> filteredTasks(FilteredTasksRef ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final selectedCategories = ref.watch(taskCategoryFilterProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider);

  return tasksAsync.whenData((tasks) {
    var result = tasks;
    if (selectedCategories.isNotEmpty) {
      result = result
          .where((t) => selectedCategories
              .contains(AppColors.normaliseCategory(t.category)))
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return result;
  });
}

@riverpod
AsyncValue<List<String>> activeCategories(ActiveCategoriesRef ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.whenData((tasks) {
    final activeSet = <String>{};
    for (var t in tasks) {
      if (t.isActive) {
        activeSet.add(AppColors.normaliseCategory(t.category));
      }
    }
    return activeSet.toList();
  });
}

@riverpod
AsyncValue<List<TaskModel>> todayTasks(TodayTasksRef ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final currentUserId = ref.watch(currentUserIdProvider);

  return tasksAsync.whenData((tasks) {
    return tasks.where((task) {
      // 1. Must be active (includes objected) and NOT completed/verified
      if (!task.isActive || task.isCompleted) return false;

      // 2. Ownership check
      if (task.assignedTo != null && task.assignedTo != currentUserId) {
        return false;
      }

      // 3. Visibility check:
      // - Already due today?
      if (task.isDueToday) return true;

      // - Is it a daily recurring task? (These always show unless completed)
      if (task.recurrenceType == 'daily') return true;

      // - Is it overdue? (Due in the past but still active)
      if (task.dueAt != null && task.dueAt!.isBefore(DateTime.now())) {
        return true;
      }

      return false;
    }).toList();
  });
}

@riverpod
Map<String, int> taskStatusCount(TaskStatusCountRef ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.maybeWhen(
    data: (tasks) {
      final counts = <String, int>{};
      for (final task in tasks) {
        final statusKey = task.status.dbValue;
        counts[statusKey] = (counts[statusKey] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => {},
  );
}
