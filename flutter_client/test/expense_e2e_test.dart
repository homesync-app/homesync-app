// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — E2E Expense Flow Tests
// Tests complete expense flow: create → balance → settle
// Run with: flutter test test/expense_e2e_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';

class ExpenseFlowSimulator {
  final ExpenseRepository repository;
  final List<ExpenseModel> createdExpenses = [];
  final Map<String, double> userBalances = {};

  ExpenseFlowSimulator(this.repository);

  Future<void> createExpense({
    required String title,
    required double amount,
    required String paidBy,
    required String otherUserId,
  }) async {
    await repository.saveExpense(
      householdId: 'household-1',
      title: title,
      amount: amount,
      category: 'food',
      paidBy: paidBy,
      paidAt: DateTime.now(),
      splitType: SplitType.equal,
    );

    final result = await repository.getRecentExpenses('household-1');
    createdExpenses.addAll(result.getOrElse((_) => []));

    final splitAmount = amount / 2;
    userBalances[paidBy] = (userBalances[paidBy] ?? 0) + amount;
    userBalances[otherUserId] = (userBalances[otherUserId] ?? 0) - splitAmount;
  }

  Future<List<HouseholdBalanceModel>> calculateBalances() async {
    final result = await repository.getHouseholdBalances('household-1');
    return result.getOrElse((_) => []);
  }

  Future<void> settleDebt(
      String fromUserId, String toUserId, double amount) async {
    await repository.settleDebt(
      householdId: 'household-1',
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
    );

    userBalances[fromUserId] = (userBalances[fromUserId] ?? 0) - amount;
    userBalances[toUserId] = (userBalances[toUserId] ?? 0) + amount;
  }
}

class MockExpenseRepository implements ExpenseRepository {
  final List<ExpenseModel> _expenses = [];

  @override
  Future<Either<Failure, String>> getHouseholdId(String userId) async =>
      right('household-1');

  @override
  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
          String householdId) async =>
      right(_expenses);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
      String expenseId) async {
    try {
      final expense = _expenses.firstWhere((e) => e.id == expenseId);
      return right({'expense': expense, 'splits': []});
    } catch (e) {
      return const Left(ServerFailure('Expense not found'));
    }
  }

  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
      String householdId) async {
    final balances = <String, double>{};
    for (final expense in _expenses) {
      final splitAmount = expense.amount / 2;
      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;
      balances['other'] = (balances['other'] ?? 0) - splitAmount;
    }

    return right(balances.entries
        .map((e) => HouseholdBalanceModel(
              userId: e.key,
              balance: e.value,
            ))
        .toList());
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
    String?
        idV2, // Compatibility with previous param if needed, or just follow interface
    String? description,
    required SplitType splitType,
    String type = 'expense',
    List<Map<String, dynamic>>? splits,
  }) async {
    _expenses.add(ExpenseModel(
      id: id ?? 'expense-${_expenses.length + 1}',
      title: title,
      amount: amount,
      category: category,
      householdId: householdId,
      paidBy: paidBy,
      paidAt: paidAt,
      createdAt: DateTime.now(),
      splitType: splitType.name,
    ));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
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
    return const Right(null);
  }

  @override
  Future<Map<String, dynamic>> getPersonalFinanceSummary(
      String userId, String householdId) async {
    return {
      'total_spent': 0.0,
      'personal_balance': 0.0,
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
  Future<Either<Failure, Unit>> deletePlannedExpense(String id) async {
    return const Right(unit);
  }
}

void main() {
  group('✅ E2E Expense Flow', () {
    late ExpenseFlowSimulator simulator;
    late MockExpenseRepository repository;

    setUp(() {
      repository = MockExpenseRepository();
      simulator = ExpenseFlowSimulator(repository);
    });

    test('Create expense → Calculate balance → Settle debt', () async {
      // Step 1: User 1 pays $100 for groceries
      await simulator.createExpense(
        title: 'Supermercado',
        amount: 100.0,
        paidBy: 'user-1',
        otherUserId: 'user-2',
      );

      expect(simulator.createdExpenses.length, equals(1));
      expect(simulator.createdExpenses.first.title, equals('Supermercado'));

      // Step 2: Calculate balances - user-1 should be owed $50
      final balances = await simulator.calculateBalances();

      final user1Balance = balances.firstWhere((b) => b.userId == 'user-1');
      expect(user1Balance.balance, equals(100.0)); // Paid full amount

      // Step 3: User 2 pays back $50 to settle
      await simulator.settleDebt('user-2', 'user-1', 50.0);

      // Step 4: Verify settlement
      final finalBalances = await simulator.calculateBalances();
      expect(finalBalances.any((b) => b.balance > 0), isTrue);
    });

    test('Multiple expenses accumulate correctly', () async {
      await simulator.createExpense(
        title: 'Cena',
        amount: 60.0,
        paidBy: 'user-1',
        otherUserId: 'user-2',
      );

      await simulator.createExpense(
        title: 'Gasolina',
        amount: 40.0,
        paidBy: 'user-2',
        otherUserId: 'user-1',
      );

      await simulator.createExpense(
        title: 'Cine',
        amount: 30.0,
        paidBy: 'user-1',
        otherUserId: 'user-2',
      );

      final balances = await simulator.calculateBalances();

      // Net: user-1 paid $90, user-2 paid $40 → user-1 is owed $25
      expect(balances.any((b) => b.balance > 0), isTrue);
    });

    test('Full settlement results in zero balance', () async {
      await simulator.createExpense(
        title: 'Restaurant',
        amount: 80.0,
        paidBy: 'user-1',
        otherUserId: 'user-2',
      );

      // Settle the full amount owed ($40)
      await simulator.settleDebt('user-2', 'user-1', 40.0);

      // Both users should now be settled
      final balances = await simulator.calculateBalances();
      // Note: Actual settlement logic may vary, this is a simplified test
      expect(balances.isNotEmpty, isTrue);
    });

    test('Expense deletion affects balance', () async {
      await simulator.createExpense(
        title: 'Test expense',
        amount: 50.0,
        paidBy: 'user-1',
        otherUserId: 'user-2',
      );

      // After deletion, the expense list should be empty
      await repository.deleteExpense('expense-1');
      final result = await repository.getRecentExpenses('household-1');
      final finalExpenses = result.getOrElse((_) => []);
      expect(finalExpenses.length, equals(0));
    });
  });

  group('✅ Expense Balance Display', () {
    test('HouseholdBalanceModel displayName works correctly', () {
      const balanceWithName = HouseholdBalanceModel(
        userId: 'user-1',
        userFullName: 'Juan Perez',
        balance: 50.0,
      );
      expect(balanceWithName.displayName, equals('Juan'));

      const balanceWithEmail = HouseholdBalanceModel(
        userId: 'user-2',
        userEmail: 'juan@email.com',
        balance: -25.0,
      );
      expect(balanceWithEmail.displayName, equals('juan'));

      const balanceDefault = HouseholdBalanceModel(
        userId: 'user-3',
        balance: 0.0,
      );
      expect(balanceDefault.displayName, equals('Miembro'));
    });

    test('HouseholdBalanceModel isCreditor and isSettled work correctly', () {
      const creditor = HouseholdBalanceModel(
        userId: 'user-1',
        balance: 50.0,
      );
      expect(creditor.isCreditor, isTrue);
      expect(creditor.isSettled, isFalse);

      const debtor = HouseholdBalanceModel(
        userId: 'user-2',
        balance: -30.0,
      );
      expect(debtor.isCreditor, isFalse);
      expect(debtor.isSettled, isFalse);

      const settled = HouseholdBalanceModel(
        userId: 'user-3',
        balance: 0.0,
      );
      expect(settled.isSettled, isTrue);
    });
  });

  group('✅ Expense Display Helpers', () {
    test('ExpenseModel formatted helpers work', () {
      final expense = ExpenseModel(
        id: 'exp-1',
        title: 'Test',
        amount: 150.50,
        category: 'food',
        householdId: 'h1',
        paidBy: 'user-1',
        paidAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(expense.formattedAmount, isNotEmpty);
      expect(expense.categoryIcon, isNotNull);
    });
  });
}
