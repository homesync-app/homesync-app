import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import '../../data/repositories/supabase_task_repository.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';
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

/// Currently selected category filter chip (null = all)
class TaskCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? category) => state = category;
}

final taskCategoryFilterProvider =
    NotifierProvider<TaskCategoryFilterNotifier, String?>(
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
  @override
  Future<List<TaskModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final useCase = ref.read(getTasksUseCaseProvider);
    return useCase(householdId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<Map<String, dynamic>> completeTask(TaskModel task) async {
    final useCase = ref.read(completeTaskUseCaseProvider);
    final result = await useCase(task);
    await refresh();
    return result;
  }

  Future<void> verifyTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('No autenticado');
    final repo = ref.read(taskRepositoryProvider);
    await repo.verifyTask(task.id, userId);
    await refresh();
  }

  Future<void> objectTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('No autenticado');
    final repo = ref.read(taskRepositoryProvider);
    await repo.objectTask(task.id, userId);
    await refresh();
  }

  Future<void> deleteTask(TaskModel task) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.deleteTask(task.id);
    await refresh();
  }

  Future<void> updateSchedule(TaskModel task, String? recurrenceType) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.updateSchedule(task.id, recurrenceType);
    await refresh();
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    final useCase = ref.read(createTaskUseCaseProvider);
    await useCase(
      title: taskData['title'] as String,
      description: taskData['description'] as String?,
      category: taskData['category'] as String,
      difficulty: taskData['difficulty'] as String,
      xpReward: taskData['xpReward'] as int,
      coinReward: taskData['coinReward'] as int,
      assignedTo: taskData['assignedTo'] as String?,
      recurrenceType: taskData['recurrenceType'] as String?,
    );
    await refresh();
  }

  Future<void> editTask(String taskId, Map<String, dynamic> updates) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.editTask(taskId, updates);
    await refresh();
  }
}

// ── Derived / Filtered Providers ──────────────────────────────────────────────

/// Tasks filtered by category chip and search query.
final filteredTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final selectedCategory = ref.watch(taskCategoryFilterProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider);

  return tasksAsync.whenData((tasks) {
    var result = tasks;
    if (selectedCategory != null) {
      result = result
          .where((t) => (t.category ?? 'general') == selectedCategory)
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return result;
  });
});

/// Tasks due today — for Home Screen widget.
final todayTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final currentUserId = ref.watch(currentUserIdProvider);

  return tasksAsync.whenData((tasks) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day + 1);

    return tasks.where((task) {
      if (!task.isActive) return false;
      if (task.assignedTo != null && task.assignedTo != currentUserId) return false;
      if (task.status == 'verified') return false;
      if (task.dueAt != null) {
        return task.dueAt!.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            task.dueAt!.isBefore(endOfDay);
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
        counts[task.status] = (counts[task.status] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => {},
  );
});
