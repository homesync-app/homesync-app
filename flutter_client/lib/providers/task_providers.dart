import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../models/member.dart';
import 'core_providers.dart';
import 'household_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UI State Providers (Riverpod 3.x — uses Notifier, not legacy StateProvider)
// ─────────────────────────────────────────────────────────────────────────────

/// Currently selected category filter (null = all)
class TaskCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;
}

final taskCategoryFilterProvider =
    NotifierProvider<TaskCategoryFilterNotifier, String?>(
        TaskCategoryFilterNotifier.new);

/// View mode: false = list view, true = calendar view
class TaskSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final taskSearchQueryProvider = NotifierProvider<TaskSearchQueryNotifier, String>(TaskSearchQueryNotifier.new);

class TaskViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = list, true = calendar

  void setList() => state = false;
  void setCalendar() => state = true;
  void toggle() => state = !state;
}

final taskViewModeProvider =
    NotifierProvider<TaskViewModeNotifier, bool>(TaskViewModeNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Household Members Provider
// ─────────────────────────────────────────────────────────────────────────────



// ─────────────────────────────────────────────────────────────────────────────
// Tasks AsyncNotifier
// ─────────────────────────────────────────────────────────────────────────────

class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() => _fetchTasks();

  // ── Private ───────────────────────────────────────────────────────────────

  Future<List<Task>> _fetchTasks() async {
    final rpc = ref.read(rpcServiceProvider);
    final raw = await rpc.getTasks();
    return raw.map((t) => Task.fromMap(t)).toList();
  }

  SupabaseClient get _db => Supabase.instance.client;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Force a fresh fetch from the server
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTasks);
  }

  /// Mark a task as completed and award XP/coins
  Future<Map<String, dynamic>> completeTask(Task task) async {
    final rpc = ref.read(rpcServiceProvider);
    final result = await rpc.completeTaskTransaction(
      taskId: task.id,
      taskTitle: task.title,
      xpReward: task.xpReward,
      coinReward: task.coinReward,
      householdId: task.householdId,
    );
    await refresh();
    return result;
  }

  /// Verify a completed task (done by the other person)
  Future<void> verifyTask(Task task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('No autenticado');

    await _db.from('tasks').update({
      'status': 'verified',
      'verified_by': userId,
      'verified_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', task.id);

    await refresh();
  }

  /// Object / dispute a completed task
  Future<void> objectTask(Task task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('No autenticado');

    await _db.from('tasks').update({
      'status': 'objected',
      'objected_by': userId,
      'objected_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', task.id);

    await refresh();
  }

  /// Delete a task permanently
  Future<void> deleteTask(Task task) async {
    await _db.from('tasks').delete().eq('id', task.id);
    await refresh();
  }

  /// Update the recurrence schedule of a task
  Future<void> updateSchedule(Task task, String? recurrenceType) async {
    await _db.from('tasks').update({
      'recurrence_type': recurrenceType,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', task.id);
    await refresh();
  }

  /// Create a new task
  Future<void> createTask(Map<String, dynamic> taskData) async {
    final rpc = ref.read(rpcServiceProvider);
    
    // We expect taskData to contain: title, description, category, difficulty, 
    // xpReward, coinReward, assignedTo, recurrenceType, etc.
    await rpc.createTask(
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

  /// Edit an existing task
  Future<void> editTask(String taskId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _db.from('tasks').update(updates).eq('id', taskId);
    await refresh();
  }
}

/// The main tasks provider — exposes [TasksNotifier]
final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Derived / Filtered Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Tasks filtered by the selected category chip
final filteredTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final selectedCategory = ref.watch(taskCategoryFilterProvider);

  return tasksAsync.whenData((tasks) {
    if (selectedCategory != null) {
      tasks = tasks.where((t) => t.category == selectedCategory).toList();
    }
    final searchQuery = ref.watch(taskSearchQueryProvider);
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      tasks = tasks.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return tasks;
  });
});

/// Tasks that are due today (for HomeScreen widget)
final todayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final currentUserId = ref.watch(currentUserIdProvider);

  return tasksAsync.whenData((tasks) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day + 1);

    return tasks.where((task) {
      // Only active tasks
      if (!task.isActive) return false;
      
      // Task is assigned to another user, skip it
      if (task.assignedTo != null && task.assignedTo != currentUserId) {
        return false;
      }
      
      // Skip already completed/verified tasks
      if (task.status == 'verified') return false;
      
      // If has a specific due date, check if it's today
      if (task.dueAt != null) {
        return task.dueAt!.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
               task.dueAt!.isBefore(endOfDay);
      }
      
      // If has recurrence (daily, weekly, etc.), show it
      if (task.recurrenceType != null && task.recurrenceType!.isNotEmpty) {
        return true;
      }
      
      // If no schedule but active, show it too
      return task.dueAt == null && task.recurrenceType == null;
    }).toList();
  });
});

/// Count of tasks by status — for stats badges
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
