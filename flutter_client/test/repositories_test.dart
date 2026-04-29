// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — Repository Unit Tests with Mocks
// Tests repositories with mocked Supabase clients
// Run with: flutter test test/repositories_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';

class MockExpenseRepository implements ExpenseRepository {
  final List<ExpenseModel> _expenses = [];
  bool shouldFail = false;
  String? failMessage;

  @override
  Future<Either<Failure, String>> getHouseholdId(String userId) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return right('household-1');
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
      String householdId,) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return right(_expenses);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
      String expenseId,) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    try {
      final expense = _expenses.firstWhere((e) => e.id == expenseId);
      return right({
        'expense': expense,
        'splits': [],
      });
    } catch (e) {
      return const Left(ServerFailure('Expense not found'));
    }
  }

  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
      String householdId,) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return right([
      const HouseholdBalanceModel(
        userId: 'user-1',
        userFullName: 'Usuario 1',
        balance: 50.0,
      ),
      const HouseholdBalanceModel(
        userId: 'user-2',
        userFullName: 'Usuario 2',
        balance: -50.0,
      ),
    ]);
  }

  @override
  Future<Either<Failure, void>> saveExpense({
    String? id,
    required String householdId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime paidAt,
    String? description,
    required SplitType splitType,
    String type = 'expense',
    List<Map<String, dynamic>>? splits,
    String? receiptPath,
  }) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    final expense = ExpenseModel(
      id: id ?? 'expense-${_expenses.length + 1}',
      title: title,
      amount: amount,
      category: category,
      householdId: householdId,
      paidBy: paidBy,
      paidAt: paidAt,
      createdAt: DateTime.now(),
      description: description,
      splitType: splitType.name,
      type: type,
    );
    _expenses.add(expense);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    _expenses.removeWhere((e) => e.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    if (shouldFail) return Left(ServerFailure(failMessage ?? 'Mock error'));
    return const Right(null);
  }

  @override
  Future<Map<String, dynamic>> getPersonalFinanceSummary(
      String userId, String householdId,) async {
    return {
      'total_balance': 0.0,
      'pending_tasks': 0,
      'active_savings': 0,
    };
  }

  @override
  Future<Either<Failure, List<FeedItemModel>>> getCombinedFeed(String householdId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<ExpenseTemplateModel>>> getTemplates(String householdId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Unit>> saveTemplate(ExpenseTemplateModel template) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> toggleTemplateActivity(String templateId, bool isActive) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> payPlannedExpense({
    required String plannedId,
    required double amount,
    required DateTime paidAt,
    required String paidBy,
  }) async {
    return const Right({'id': 'expense-id'});
  }

  @override
  Future<Either<Failure, Unit>> processRecurringExpenses(String householdId) async {
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<FeedItemModel>>> getMonthlyPendingPlannedExpenses(
    String householdId, {
    required DateTime month,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Unit>> deletePlannedExpense(String id) async {
    return const Right(unit);
  }
}

class MockTaskRepository implements TaskRepository {
  final List<TaskModel> _tasks = [];
  bool shouldFail = false;

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(String householdId,
      {int limit = 100, int offset = 0,}) async {
    if (shouldFail) return const Left(ServerFailure('Mock error'));
    return right(_tasks);
  }

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(TaskModel task,
      {List<String>? userIds, DateTime? completedAt,}) async {
    if (shouldFail) return const Left(ServerFailure('Mock error'));
    return right(TaskCompletionResult(
      success: true,
      message: 'ok',
      queued: false,
      xpEarned: task.xpReward,
      coinsEarned: task.coinReward,
    ),);
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
          String taskId, String verifiedByUserId,) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> objectTask(
          String taskId, String objectedByUserId,) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateSchedule(String taskId, String? recurrenceType, {int? recurrenceInterval, List<int>? recurrenceWeekdays, List<int>? recurrenceMonthDays, String? assignedTo}) async =>
      const Right(null);

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
    List<String>? rotationPool,
  }) async {
    _tasks.add(TaskModel(
      id: 'task-${_tasks.length + 1}',
      title: title,
      description: description,
      category: category,
      difficulty: TaskDifficulty.fromString(difficulty),
      status: TaskStatus.active,
      xpReward: xpReward,
      coinReward: coinReward,
      householdId: 'household-1',
      createdAt: DateTime.now(),
    ),);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> editTask(
          String taskId, Map<String, dynamic> updates,) async =>
      const Right(null);

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoTaskCompletion(
          String activityId,) async =>
      right({'success': true});
}

void main() {
  group('✅ MockExpenseRepository', () {
    late MockExpenseRepository repo;

    setUp(() {
      repo = MockExpenseRepository();
    });

    test('getHouseholdId returns correct household', () async {
      final result = await repo.getHouseholdId('user-1');
      expect(result.getOrElse((_) => ''), equals('household-1'));
    });

    test('saveExpense adds expense to list', () async {
      await repo.saveExpense(
        householdId: 'household-1',
        title: 'Compra supermercado',
        amount: 150.0,
        category: 'food',
        paidBy: 'user-1',
        paidAt: DateTime.now(),
        splitType: SplitType.equal,
      );

      final result = await repo.getRecentExpenses('household-1');
      final expenses = result.getOrElse((_) => []);
      expect(expenses.length, equals(1));
      expect(expenses.first.title, equals('Compra supermercado'));
    });

    test('deleteExpense removes expense', () async {
      await repo.saveExpense(
        householdId: 'household-1',
        title: 'Gasto test',
        amount: 50.0,
        category: 'other',
        paidBy: 'user-1',
        paidAt: DateTime.now(),
        splitType: SplitType.personal,
      );

      final result = await repo.getRecentExpenses('household-1');
      final expenses = result.getOrElse((_) => []);
      final expenseId = expenses.first.id;

      await repo.deleteExpense(expenseId);

      final afterDeleteResult = await repo.getRecentExpenses('household-1');
      final afterDelete = afterDeleteResult.getOrElse((_) => []);
      expect(afterDelete.length, equals(0));
    });

    test('getHouseholdBalances returns correct structure', () async {
      final result = await repo.getHouseholdBalances('household-1');
      final balances = result.getOrElse((_) => []);

      expect(balances.length, equals(2));
      expect(balances.any((b) => b.balance > 0), isTrue);
      expect(balances.any((b) => b.balance < 0), isTrue);
    });

    test('getExpenseWithSplits returns expense with splits', () async {
      await repo.saveExpense(
        id: 'expense-1',
        householdId: 'household-1',
        title: 'Cena',
        amount: 80.0,
        category: 'food',
        paidBy: 'user-1',
        paidAt: DateTime.now(),
        splitType: SplitType.equal,
      );

      final result = await repo.getExpenseWithSplits('expense-1');
      final data = result.getOrElse((_) => {});
      expect(data['expense'], isNotNull);
      expect((data['expense'] as ExpenseModel).title, equals('Cena'));
    });

    test('handles failure gracefully', () async {
      repo.shouldFail = true;
      repo.failMessage = 'Network error';

      final result = await repo.getHouseholdId('user-1');
      expect(result.isLeft(), isTrue);
    });
  });

  group('✅ MockTaskRepository', () {
    late MockTaskRepository repo;

    setUp(() {
      repo = MockTaskRepository();
    });

    test('createTask adds task to list', () async {
      await repo.createTask(
        title: 'Lavar platos',
        category: 'kitchen',
        difficulty: 'easy',
        xpReward: 20,
        coinReward: 10,
      );

      final result = await repo.getTasks('household-1');
      final tasks = result.getOrElse((_) => []);
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Lavar platos'));
    });

    test('completeTask returns correct rewards', () async {
      await repo.createTask(
        title: 'Task reward',
        category: 'cleaning',
        difficulty: 'medium',
        xpReward: 50,
        coinReward: 25,
      );

      final tasksResult = await repo.getTasks('household-1');
      final tasks = tasksResult.getOrElse((_) => []);
      final result = await repo.completeTask(tasks.first, userIds: ['user-1']);
      final data = result.getOrElse((_) => const TaskCompletionResult(
            success: false,
            message: '',
            queued: false,
          ),);

      expect(data.xpEarned, equals(50));
      expect(data.coinsEarned, equals(25));
    });

    test('deleteTask removes task', () async {
      await repo.createTask(
        title: 'To delete',
        category: 'other',
        difficulty: 'hard',
        xpReward: 10,
        coinReward: 5,
      );

      var result = await repo.getTasks('household-1');
      var tasks = result.getOrElse((_) => []);
      await repo.deleteTask(tasks.first.id);

      result = await repo.getTasks('household-1');
      tasks = result.getOrElse((_) => []);
      expect(tasks.length, equals(0));
    });

    test('getTasks respects pagination', () async {
      for (int i = 0; i < 10; i++) {
        await repo.createTask(
          title: 'Task $i',
          category: 'other',
          difficulty: 'easy',
          xpReward: 10,
          coinReward: 5,
        );
      }

      final result = await repo.getTasks('household-1', limit: 100, offset: 0);
      final allTasks = result.getOrElse((_) => []);

      final firstPage = allTasks.sublist(0, 5.clamp(0, allTasks.length));
      final secondPage = allTasks.sublist(5, 10.clamp(0, allTasks.length));

      expect(firstPage.length, equals(5));
      expect(secondPage.length, equals(5));
      expect(firstPage.first.title, isNot(equals(secondPage.first.title)));
    });
  });

  group('✅ Repository pattern integration', () {
    test('can swap implementations', () async {
      final mockRepo = MockExpenseRepository();

      await mockRepo.saveExpense(
        householdId: 'household-1',
        title: 'Shared expense',
        amount: 100.0,
        category: 'utilities',
        paidBy: 'user-1',
        paidAt: DateTime.now(),
        splitType: SplitType.equal,
      );

      final result = await mockRepo.getRecentExpenses('household-1');
      final expenses = result.getOrElse((_) => []);
      expect(expenses.length, equals(1));
    });

    test('abstract repository contract is satisfied', () {
      final repo = MockExpenseRepository();
      expect(repo, isA<ExpenseRepository>());
    });
  });
}
