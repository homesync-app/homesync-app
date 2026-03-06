import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/supabase_task_repository.dart';
import '../../domain/models/task_model.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';

// ── Use Case Providers ────────────────────────────────────────────────────────

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.read(taskRepositoryProvider));
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  return CompleteTaskUseCase(ref.read(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.read(taskRepositoryProvider));
});

// ── UI State Providers ────────────────────────────────────────────────────────

/// Currently selected category filters (empty = all)
class TaskCategoryFilterNotifier extends Notifier<Set<String>> {
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

final taskCategoryFilterProvider =
    NotifierProvider<TaskCategoryFilterNotifier, Set<String>>(
        TaskCategoryFilterNotifier.new);

/// Search query string
class TaskSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final taskSearchQueryProvider =
    NotifierProvider<TaskSearchQueryNotifier, String>(
        TaskSearchQueryNotifier.new);

/// View mode toggle (false = list, true = calendar)
class TaskViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setList() => state = false;
  void setCalendar() => state = true;
  void toggle() => state = !state;
}

final taskViewModeProvider =
    NotifierProvider<TaskViewModeNotifier, bool>(TaskViewModeNotifier.new);

// ── Main Tasks Notifier ───────────────────────────────────────────────────────

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(TasksNotifier.new);

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  static const int _pageSize = 50;
  RealtimeChannel? _channel;

  @override
  Future<List<TaskModel>> build() async {
    _hasMore = true;
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    // Realtime setup
    _setupRealtime(householdId);

    final useCase = ref.read(getTasksUseCaseProvider);
    final result = await useCase(householdId, limit: _pageSize, offset: 0);

    return result.fold(
      (failure) {
        log.e('Error loading tasks: ${failure.message}');
        throw Exception(failure.message);
      },
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  /// Same as refresh but without showing the loading state, good for instantaneous updates.
  Future<void> silentRefresh() async {
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    final currentTasks = state.value ?? [];
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final useCase = ref.read(getTasksUseCaseProvider);
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
  }

  Future<Map<String, dynamic>?> completeTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    final useCase = ref.read(completeTaskUseCaseProvider);
    final result = await useCase(task, userId: userId);

    return result.fold(
      (failure) {
        log.w('Complete task failure: ${failure.message}');
        return null;
      },
      (data) async {
        await refresh();
        return data;
      },
    );
  }

  Future<void> verifyTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      log.w('Verify task aborted: user not authenticated');
      return;
    }
    final repo = ref.read(taskRepositoryProvider);
    final result = await repo.verifyTask(task.id, userId);

    result.fold(
      (failure) => log.w('Verify task failure: ${failure.message}'),
      (_) => refresh(),
    );
  }

  Future<void> objectTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      log.w('Object task aborted: user not authenticated');
      return;
    }
    final repo = ref.read(taskRepositoryProvider);
    final result = await repo.objectTask(task.id, userId);

    result.fold(
      (failure) => log.w('Object task failure: ${failure.message}'),
      (_) => refresh(),
    );
  }

  Future<void> deleteTask(TaskModel task) async {
    final repo = ref.read(taskRepositoryProvider);
    final result = await repo.deleteTask(task.id);

    result.fold(
      (failure) => log.w('Delete task failure: ${failure.message}'),
      (_) => refresh(),
    );
  }

  Future<void> updateSchedule(TaskModel task, String? recurrenceType) async {
    final repo = ref.read(taskRepositoryProvider);
    final result = await repo.updateSchedule(task.id, recurrenceType);

    result.fold(
      (failure) => log.w('Update schedule failure: ${failure.message}'),
      (_) => refresh(),
    );
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final useCase = ref.read(createTaskUseCaseProvider);
    final result = await useCase(
      title: taskData['title'] as String,
      description: taskData['description'] as String?,
      category: taskData['category'] as String,
      difficulty: taskData['difficulty'] as String,
      xpReward: taskData['xpReward'] as int,
      coinReward: taskData['coinReward'] as int,
      assignedTo: taskData['assignedTo'] as String?,
      recurrenceType: taskData['recurrenceType'] as String?,
    );

    result.fold(
      (failure) => log.w('Create task failure: ${failure.message}'),
      (_) => silentRefresh(),
    );
  }

  Future<void> editTask(String taskId, Map<String, dynamic> updates) async {
    final repo = ref.read(taskRepositoryProvider);
    final result = await repo.editTask(taskId, updates);

    result.fold(
      (failure) => log.w('Edit task failure: ${failure.message}'),
      (_) => refresh(),
    );
  }
}

// ── Derived / Filtered Providers ──────────────────────────────────────────────

final filteredTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
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
});

/// Only the categories that actually have at least one active task.
final activeCategoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
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
});

/// Tasks due today — for Home Screen widget.
final todayTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final currentUserId = ref.watch(currentUserIdProvider);

  return tasksAsync.whenData((tasks) {
    return tasks.where((task) {
      if (!task.isActive) return false;
      if (task.assignedTo != null && task.assignedTo != currentUserId) {
        return false;
      }
      if (task.isVerified) return false;
      if (task.dueAt != null) {
        return task.isDueToday;
      }
      if (task.isRecurring) return true;
      return false;
    }).toList();
  });
});

/// Count of tasks by status — for stats badges.
final taskStatusCountProvider = Provider<Map<String, int>>((ref) {
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
});
