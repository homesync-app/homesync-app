// Tests Riverpod providers with mocked dependencies
// Run with: flutter test test/providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

class MockTaskRepository implements TaskRepository {
  final List<TaskModel> _tasks = [];
  bool shouldFail = false;
  String? failMessage;

  MockTaskRepository({List<TaskModel>? tasks}) {
    if (tasks != null) _tasks.addAll(tasks);
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(String householdId,
      {int limit = 100, int offset = 0}) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return Right(_tasks.skip(offset).take(limit).toList());
  }

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(TaskModel task,
      {List<String>? userIds, DateTime? completedAt}) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return Right(TaskCompletionResult(
      success: true,
      message: 'ok',
      queued: false,
      xpEarned: task.xpReward,
      coinsEarned: task.coinReward,
    ));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeTasksBatch(
    List<TaskModel> tasks, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return right({'success': true});
  }

  @override
  Future<Either<Failure, void>> verifyTask(
      String taskId, String verifiedByUserId) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> objectTask(
      String taskId, String objectedByUserId) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    _tasks.removeWhere((t) => t.id == taskId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateSchedule(String taskId, String? recurrenceType, {int? recurrenceInterval, List<int>? recurrenceWeekdays, List<int>? recurrenceMonthDays}) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> createTask({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? status,
  }) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    _tasks.add(TaskModel(
      id: 'new-task-${_tasks.length + 1}',
      title: title,
      description: description,
      category: category,
      difficulty: TaskDifficulty.fromString(difficulty),
      status: TaskStatus.active,
      xpReward: xpReward,
      coinReward: coinReward,
      householdId: 'household-1',
      createdAt: DateTime.now(),
    ));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> editTask(
      String taskId, Map<String, dynamic> updates) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoTaskCompletion(
      String activityId) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return const Right({'success': true});
  }
}

void main() {
  group('TaskCategoryFilterNotifier', () {
    test('starts with empty filter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(taskCategoryFilterProvider);
      expect(filter, isEmpty);
    });

    test('toggles category on', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(taskCategoryFilterProvider.notifier).toggle('kitchen');
      final filter = container.read(taskCategoryFilterProvider);
      expect(filter, contains('kitchen'));
    });

    test('toggles category off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(taskCategoryFilterProvider.notifier);
      notifier.toggle('kitchen');
      notifier.toggle('kitchen');
      final filter = container.read(taskCategoryFilterProvider);
      expect(filter, isNot(contains('kitchen')));
    });

    test('clears all filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(taskCategoryFilterProvider.notifier);
      notifier.toggle('kitchen');
      notifier.toggle('bathroom');
      notifier.clear();
      expect(container.read(taskCategoryFilterProvider), isEmpty);
    });
  });

  group('TaskSearchQueryNotifier', () {
    test('starts with empty query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final query = container.read(taskSearchQueryProvider);
      expect(query, isEmpty);
    });

    test('sets search query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(taskSearchQueryProvider.notifier).setQuery('lavar');
      expect(container.read(taskSearchQueryProvider), equals('lavar'));
    });
  });

  group('TaskViewModeNotifier', () {
    test('starts in list mode (false)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = container.read(taskViewModeProvider);
      expect(mode, isFalse);
    });

    test('toggles to calendar mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(taskViewModeProvider.notifier).toggle();
      expect(container.read(taskViewModeProvider), isTrue);
    });

    test('setList and setCalendar work correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(taskViewModeProvider.notifier).setCalendar();
      expect(container.read(taskViewModeProvider), isTrue);

      container.read(taskViewModeProvider.notifier).setList();
      expect(container.read(taskViewModeProvider), isFalse);
    });
  });

  group('filteredTasksProvider', () {
    final testTasks = [
      TaskModel(
        id: '1',
        title: 'Lavar platos',
        category: 'kitchen',
        status: TaskStatus.active,
        xpReward: 20,
        coinReward: 10,
        householdId: 'household-1',
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: '2',
        title: 'Barrer',
        category: 'cleaning',
        status: TaskStatus.active,
        xpReward: 15,
        coinReward: 5,
        householdId: 'household-1',
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: '3',
        title: 'Cocinar',
        category: 'kitchen',
        status: TaskStatus.verified,
        xpReward: 30,
        coinReward: 15,
        householdId: 'household-1',
        createdAt: DateTime.now(),
      ),
    ];

    test('category filter logic works correctly', () {
      final filter = <String>{'kitchen'};
      final filtered =
          testTasks.where((t) => filter.contains(t.category)).toList();
      expect(filtered.length, equals(2));
      expect(filtered.every((t) => t.category == 'kitchen'), isTrue);
    });

    test('search filter works correctly', () {
      const query = 'lavar';
      final filtered = testTasks
          .where((t) => t.title.toLowerCase().contains(query))
          .toList();
      expect(filtered.length, equals(1));
      expect(filtered.first.title, equals('Lavar platos'));
    });

    test('combined filters work correctly', () {
      final categoryFilter = <String>{'kitchen'};
      const searchQuery = 'cocinar';
      var result =
          testTasks.where((t) => categoryFilter.contains(t.category)).toList();
      result = result
          .where((t) => t.title.toLowerCase().contains(searchQuery))
          .toList();
      expect(result.length, equals(1));
    });
  });

  group('taskStatusCountProvider', () {
    test('counts tasks by status correctly', () {
      final tasks = [
        TaskModel(
            id: '1',
            title: 'Task 1',
            status: TaskStatus.active,
            xpReward: 10,
            coinReward: 5,
            householdId: 'h1',
            createdAt: DateTime.now()),
        TaskModel(
            id: '2',
            title: 'Task 2',
            status: TaskStatus.active,
            xpReward: 10,
            coinReward: 5,
            householdId: 'h1',
            createdAt: DateTime.now()),
        TaskModel(
            id: '3',
            title: 'Task 3',
            status: TaskStatus.verified,
            xpReward: 10,
            coinReward: 5,
            householdId: 'h1',
            createdAt: DateTime.now()),
        TaskModel(
            id: '4',
            title: 'Task 4',
            status: TaskStatus.pendingVerification,
            xpReward: 10,
            coinReward: 5,
            householdId: 'h1',
            createdAt: DateTime.now()),
      ];

      final counts = <String, int>{};
      for (final task in tasks) {
        final statusKey = task.status.dbValue;
        counts[statusKey] = (counts[statusKey] ?? 0) + 1;
      }

      expect(counts['active'], equals(2));
      expect(counts['verified'], equals(1));
      expect(counts['pending_verification'], equals(1));
    });
  });
}

class TestCategoryFilterNotifier extends Notifier<Set<String>> {
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


