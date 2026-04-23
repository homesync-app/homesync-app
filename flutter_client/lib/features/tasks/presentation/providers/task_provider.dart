import 'dart:async';

import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_task_repository.dart';
import '../../domain/models/task_model.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/utils/task_completion_utils.dart';

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
      (failure) => throw failure,
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
    state = const AsyncLoading<List<TaskModel>>().copyWithPrevious(state);
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
    } catch (e, stack) {
      log.w('Error loading more tasks: $e', error: e, stackTrace: stack);
    }
  }

  Future<TaskCompletionResult?> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final performers =
        userIds ?? (currentUserId != null ? [currentUserId] : null);
    final primaryUserId = performers?.first ?? currentUserId;
    final effectiveCompletedAt = completedAt ?? DateTime.now();

    final oldState = state.value;

    // Optimistic update
    if (oldState != null) {
      state = AsyncValue.data(oldState
          .map((t) => t.id == task.id
              ? t.copyWith(
                  status: TaskStatus.active,
                  completedBy: primaryUserId,
                  completedAt: effectiveCompletedAt,
                )
              : t,)
          .toList(),);
    }

    try {
      final useCase = ref.read(completeTaskUseCaseProvider);
      final result = await useCase(
        task,
        userIds: performers,
        completedAt: effectiveCompletedAt,
      );

      if (result.isRight()) {
        final isOnline = ref.read(isOnlineProvider);
        final queued = result.fold(
          (_) => false,
          (data) => data.queued,
        );
        if (isOnline && !queued) {
          silentRefresh();
          ref.invalidate(userBalanceProvider);
          ref.invalidate(recentActivityProvider);
        }
      }

      return result.fold(
        (failure) {
          state = AsyncValue.data(oldState!);
          return null;
        },
        (data) => data,
      );
    } catch (e, stack) {
      log.w('Complete task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
      return null;
    }
  }

  Future<Map<String, dynamic>?> completeTasksBatch(
    List<TaskModel> tasks, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final performers =
        userIds ?? (currentUserId != null ? [currentUserId] : null);
    final primaryUserId = performers?.first ?? currentUserId;
    final effectiveCompletedAt = completedAt ?? DateTime.now();
    final taskIds = tasks.map((t) => t.id).toSet();

    final oldState = state.value;

    if (oldState != null) {
      state = AsyncValue.data(oldState
          .map((t) => taskIds.contains(t.id)
              ? t.copyWith(
                  status: TaskStatus.active,
                  completedBy: primaryUserId,
                  completedAt: effectiveCompletedAt,
                )
              : t,)
          .toList(),);
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      final result = await repo.completeTasksBatch(
        tasks,
        userIds: performers,
        completedAt: effectiveCompletedAt,
      );

      if (result.isRight()) {
        final isOnline = ref.read(isOnlineProvider);
        if (isOnline) {
          silentRefresh();
          ref.invalidate(userBalanceProvider);
          ref.invalidate(recentActivityProvider);
        }
      }

      return result.fold(
        (failure) {
          if (oldState != null) state = AsyncValue.data(oldState);
          return null;
        },
        (data) => data,
      );
    } catch (e, stack) {
      log.w('Complete tasks batch failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState);
      return null;
    }
  }

  Future<void> verifyTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(oldState
          .map((t) => t.id == task.id
              ? t.copyWith(
                  status: TaskStatus.verified,
                  verifiedBy: userId,
                  verifiedAt: DateTime.now(),)
              : t,)
          .toList(),);
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.verifyTask(task.id, userId);
    } catch (e, stack) {
      log.w('Verify task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> objectTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(oldState
          .map((t) => t.id == task.id
              ? t.copyWith(
                  status: TaskStatus.active,
                  completedBy: null,
                  completedAt: null,)
              : t,)
          .toList(),);
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.objectTask(task.id, userId);
    } catch (e, stack) {
      log.w('Object task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> approveTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(oldState
          .map((t) =>
              t.id == task.id ? t.copyWith(status: TaskStatus.active) : t,)
          .toList(),);
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      // We use editTask to change status to active
      await repo.editTask(task.id, {'status': 'active'});
      silentRefresh();
    } catch (e, stack) {
      log.w('Approve task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> rejectTask(TaskModel task) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(task.id);
      silentRefresh();
    } catch (e, stack) {
      log.w('Reject task failure: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> submitTaskForApproval(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final submittedAt = DateTime.now();
    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map((t) => t.id == task.id
                ? t.copyWith(
                    status: TaskStatus.pendingApproval,
                    completedBy: userId,
                    completedAt: submittedAt,
                  )
                : t,)
            .toList(),
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.editTask(task.id, {
        'status': 'pending_approval',
        'completed_by': userId,
        'completed_at': submittedAt.toIso8601String(),
        'last_completed_at': submittedAt.toIso8601String(),
      });
      if (ref.read(isOnlineProvider)) {
        silentRefresh();
        ref.invalidate(recentActivityProvider);
      }
    } catch (e, stack) {
      log.w(
        'Submit task for approval failure: $e',
        error: e,
        stackTrace: stack,
      );
      if (oldState != null) state = AsyncValue.data(oldState);
      rethrow;
    }
  }

  Future<TaskCompletionResult?> approvePendingTask(TaskModel task) async {
    final performerId = task.completedBy ?? task.assignedTo;
    if (performerId == null) return null;

    return completeTask(
      task,
      userIds: [performerId],
      completedAt: task.completedAt ?? DateTime.now(),
    );
  }

  Future<void> rejectPendingTask(TaskModel task) async {
    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map((t) => t.id == task.id
                ? t.copyWith(
                    status: TaskStatus.active,
                    completedBy: null,
                    completedAt: null,
                  )
                : t,)
            .toList(),
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.editTask(task.id, {
        'status': 'active',
        'completed_by': null,
        'completed_at': null,
        'last_completed_at': null,
      });
      if (ref.read(isOnlineProvider)) {
        silentRefresh();
        ref.invalidate(recentActivityProvider);
      }
    } catch (e, stack) {
      log.w('Reject pending task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState);
      rethrow;
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(oldState.where((t) => t.id != task.id).toList());
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(task.id);
    } catch (e, stack) {
      log.w('Delete task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> updateSchedule(
    TaskModel task,
    String? recurrenceType, {
    int recurrenceInterval = 1,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? assignedTo,
  }) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.updateSchedule(
        task.id,
        recurrenceType,
        recurrenceInterval: recurrenceInterval,
        recurrenceWeekdays: recurrenceWeekdays,
        recurrenceMonthDays: recurrenceMonthDays,
        assignedTo: assignedTo,
      );
      if (ref.read(isOnlineProvider)) {
        refresh();
      }
    } catch (e, stack) {
      log.w('Update schedule failure: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      final xp = taskData['xpReward'] as int;
      final coins = taskData['coinReward'] as int;

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
        recurrenceInterval: taskData['recurrenceInterval'] as int?,
        recurrenceWeekdays: taskData['recurrenceWeekdays'] as List<int>?,
        recurrenceMonthDays: taskData['recurrenceMonthDays'] as List<int>?,
        status: null,
      );

      result.fold(
        (failure) => throw failure,
        (_) {
          final isOnline = ref.read(isOnlineProvider);
          if (isOnline) {
            silentRefresh();
            ref.invalidate(recentActivityProvider);
          }
        },
      );
    } catch (e, stack) {
      log.w('Create task failure: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> editTask(String taskId, Map<String, dynamic> updates) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.editTask(taskId, updates);
      if (ref.read(isOnlineProvider)) {
        refresh();
      }
    } catch (e, stack) {
      log.w('Edit task failure: $e', error: e, stackTrace: stack);
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
              .contains(CategoryMapping.normaliseCategory(t.category)),)
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
        activeSet.add(CategoryMapping.normaliseCategory(t.category));
      }
    }
    return activeSet.toList();
  });
}

@riverpod
AsyncValue<List<TaskModel>> todayTasks(TodayTasksRef ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  final caps = ref.watch(householdCapabilitiesProvider);
  final members = ref.watch(householdMembersProvider).valueOrNull ?? const [];
  final currentMember =
      members.where((member) => member.userId == currentUserId).firstOrNull;
  final isFamilyMode = caps.type == HouseholdType.family;
  final isFamilyChild = isFamilyMode && (currentMember?.isChild ?? false);
  final shouldUseFamilyHouseholdScope = isFamilyMode && !isFamilyChild;

  return tasksAsync.whenData((tasks) {
    final now = DateTime.now();
    final visibleTasks = tasks.where((task) {
      // In family mode, only children should default to "my tasks".
      // Adults, and any temporarily unresolved family viewer in QA,
      // should keep the household coordination view.
      final shouldFilterByAssignment = isFamilyMode ? isFamilyChild : true;
      if (shouldFilterByAssignment &&
          task.assignedTo != null &&
          task.assignedTo != currentUserId) {
        return false;
      }

      // Completed-today tasks should leave "today" and remain only in activity.
      // Exception: pending-approval tasks still need adult review visibility
      // on the same day the child marked them done.
      if (!task.isPendingApproval && isTaskCompletedOnLocalDate(task, now)) {
        return false;
      }

      // Only actionable tasks belong in this list.
      if (!task.isActive) return false;

      // Pending-approval tasks must surface for adult review regardless
      // of the original due date — the child already acted on them.
      if (task.isPendingApproval) return true;

      if (task.isDueToday) return true;

      if (task.recurrenceType == 'daily') return true;

      if (task.dueAt != null && task.dueAt!.isBefore(DateTime.now())) {
        return true;
      }

      return false;
    }).toList();

    if (visibleTasks.isNotEmpty || !shouldUseFamilyHouseholdScope) {
      return visibleTasks;
    }

    // Family QA and new households can have active tasks without a due date or
    // explicit "today" schedule yet. In that case, show the next active tasks
    // instead of leaving the home empty.
    final householdFallback = tasks.where((task) {
      if (!task.isActive) return false;
      if (!task.isPendingApproval && isTaskCompletedOnLocalDate(task, now)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final aDue = a.dueAt;
        final bDue = b.dueAt;
        if (aDue == null && bDue == null) {
          return a.createdAt.compareTo(b.createdAt);
        }
        if (aDue == null) return 1;
        if (bDue == null) return -1;
        return aDue.compareTo(bDue);
      });

    return householdFallback.take(3).toList();
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
