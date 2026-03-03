import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
import 'package:homesync_client/features/tasks/domain/usecases/complete_task_usecase.dart';
import 'package:homesync_client/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/usecases/save_expense_usecase.dart';

// Manual Mock for TaskRepository
class MockTaskRepository implements TaskRepository {
  bool createTaskCalled = false;
  bool completeTaskCalled = false;
  
  @override
  Future<void> createTask({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
  }) async {
    createTaskCalled = true;
  }

  @override
  Future<Map<String, dynamic>> completeTask(TaskModel task, {String? userId}) async {
    completeTaskCalled = true;
    return {'success': true, 'xp_gained': 20};
  }

  @override
  Future<List<TaskModel>> getTasks(String householdId, {int limit = 100, int offset = 0}) async => throw UnimplementedError();
  @override
  Future<void> deleteTask(String taskId) async => throw UnimplementedError();
  @override
  Future<void> updateSchedule(String taskId, String? recurrenceType) async => throw UnimplementedError();
  @override
  Future<void> verifyTask(String taskId, String verifiedByUserId) async => throw UnimplementedError();
  @override
  Future<void> objectTask(String taskId, String objectedByUserId) async => throw UnimplementedError();
  @override
  Future<void> editTask(String taskId, Map<String, dynamic> updates) async => throw UnimplementedError();
}

// Manual Mock for ExpenseRepository
class MockExpenseRepository implements ExpenseRepository {
  bool saveExpenseCalled = false;

  @override
  Future<void> saveExpense({
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
  }) async {
    saveExpenseCalled = true;
  }

  @override
  Future<String> getHouseholdId(String userId) async => throw UnimplementedError();
  @override
  Future<List<ExpenseModel>> getRecentExpenses(String householdId) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> getExpenseWithSplits(String expenseId) async => throw UnimplementedError();
  @override
  Future<List<HouseholdBalanceModel>> getHouseholdBalances(String householdId) async => throw UnimplementedError();
  @override
  Future<void> deleteExpense(String expenseId) async => throw UnimplementedError();
  @override
  Future<void> settleDebt({required String householdId, required String toUserId, required double amount}) async => throw UnimplementedError();
}

void main() {
  group('CompleteTaskUseCase', () {
    late MockTaskRepository mockRepo;
    late CompleteTaskUseCase useCase;

    setUp(() {
      mockRepo = MockTaskRepository();
      useCase = CompleteTaskUseCase(mockRepo);
    });

    test('Should call repository when task is active', () async {
      final task = TaskModel(
        id: '1', title: 'T', status: TaskStatus.active, 
        xpReward: 10, coinReward: 5, householdId: 'h', createdAt: DateTime.now()
      );
      
      await useCase.call(task);
      
      expect(mockRepo.completeTaskCalled, isTrue);
    });

    test('Should throw StateError when task is NOT active', () async {
      final task = TaskModel(
        id: '1', title: 'T', status: TaskStatus.verified, // already done
        xpReward: 10, coinReward: 5, householdId: 'h', createdAt: DateTime.now()
      );
      
      expect(() => useCase.call(task), throwsStateError);
      expect(mockRepo.completeTaskCalled, isFalse);
    });
  });

  group('CreateTaskUseCase', () {
    late MockTaskRepository mockRepo;
    late CreateTaskUseCase useCase;

    setUp(() {
      mockRepo = MockTaskRepository();
      useCase = CreateTaskUseCase(mockRepo);
    });

    test('Should call repository with valid data', () async {
      await useCase.call(
        title: 'Lavar platos',
        category: 'kitchen',
        difficulty: 'easy',
        xpReward: 10,
        coinReward: 5
      );
      
      expect(mockRepo.createTaskCalled, isTrue);
    });

    test('Should throw ArgumentError if category is empty', () async {
      expect(() => useCase.call(
        title: 'Title',
        category: '',
        difficulty: 'easy',
        xpReward: 10,
        coinReward: 5
      ), throwsArgumentError);
    });

    test('Should throw ArgumentError if title is empty', () async {
      expect(() => useCase.call(
        title: '',
        category: 'kitchen',
        difficulty: 'easy',
        xpReward: 10,
        coinReward: 5
      ), throwsArgumentError);
    });
  });

  group('SaveExpenseUseCase', () {
    late MockExpenseRepository mockRepo;
    late SaveExpenseUseCase useCase;

    setUp(() {
      mockRepo = MockExpenseRepository();
      useCase = SaveExpenseUseCase(mockRepo);
    });

    test('Should call repository with valid data', () async {
      await useCase.call(
        householdId: 'h1',
        title: 'Super',
        amount: 100.0,
        category: 'food',
        paidBy: 'u1',
        paidAt: DateTime.now(),
        splitType: SplitType.equal
      );
      
      expect(mockRepo.saveExpenseCalled, isTrue);
    });

    test('Should throw Exception if amount is zero or negative', () async {
      expect(() => useCase.call(
        householdId: 'h1',
        title: 'Super',
        amount: 0.0,
        category: 'food',
        paidBy: 'u1',
        paidAt: DateTime.now(),
        splitType: SplitType.equal
      ), throwsException);
    });

    test('Should throw Exception if householdId is empty', () async {
      expect(() => useCase.call(
        householdId: '',
        title: 'Super',
        amount: 100.0,
        category: 'food',
        paidBy: 'u1',
        paidAt: DateTime.now(),
        splitType: SplitType.equal
      ), throwsException);
    });
  });
}
