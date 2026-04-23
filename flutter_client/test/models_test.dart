// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — Real Model Unit Tests
// Tests the ACTUAL app model classes (not fakes)
// Run with: flutter test test/models_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // TASK MODEL
  // ───────────────────────────────────────────────────────────────────────────
  group('✅ TaskModel — fromMap() deserialization', () {
    test('Parses a complete valid map correctly', () {
      final map = {
        'id': 'task-1',
        'title': 'Lavar platos',
        'description': 'Usar lavavajilla',
        'category': 'kitchen',
        'assigned_to': 'user-1',
        'status': 'active',
        'xp_reward': 20,
        'coin_reward': 10,
        'recurrence_type': 'weekly',
        'recurrence_interval': 2,
        'due_at': '2026-12-31T23:59:00.000Z',
        'household_id': 'house-1',
        'created_at': '2026-01-01T00:00:00.000Z',
        'priority': 'high',
        'type': 'recurring',
        'difficulty': 'easy',
      };

      final task = TaskModel.fromMap(map);

      expect(task.id, equals('task-1'));
      expect(task.title, equals('Lavar platos'));
      expect(task.category, equals('kitchen'));
      expect(task.status, equals(TaskStatus.active));
      expect(task.xpReward, equals(20));
      expect(task.coinReward, equals(10));
      expect(task.recurrenceType, equals('weekly'));
      expect(task.recurrenceInterval, equals(2));
      expect(task.householdId, equals('house-1'));
      expect(task.priority, equals(TaskPriority.high));
      expect(task.difficulty, equals(TaskDifficulty.easy));
    });

    test('Uses default values when optional fields are null', () {
      final map = {
        'id': 'task-2',
        'title': 'Tarea minimal',
        'status': null,       // should default to 'active'
        'xp_reward': null,    // should default to 0
        'coin_reward': null,  // should default to 0
        'household_id': null, // should default to ''
        'created_at': null,   // should default to now
        'recurrence_interval': null, // should default to 1
      };

      final task = TaskModel.fromMap(map);

      expect(task.status, equals(TaskStatus.active));
      expect(task.xpReward, equals(0));
      expect(task.coinReward, equals(0));
      expect(task.householdId, equals(''));
      expect(task.recurrenceInterval, equals(1));
      expect(task.priority, equals(TaskPriority.medium));
      expect(task.difficulty, equals(TaskDifficulty.medium));
    });

    test('Defaults missing title to "Sin título"', () {
      final map = {
        'id': 'task-3',
        'title': null,
        'status': 'active',
        'household_id': 'h1',
        'created_at': '2026-01-01T00:00:00.000Z',
      };
      final task = TaskModel.fromMap(map);
      expect(task.title, equals('Sin título'));
    });

    test('Parses xp_reward as num (double input → int)', () {
      final map = {
        'id': 'task-4',
        'title': 'Test',
        'status': 'active',
        'xp_reward': 15.0, // double in JSON
        'coin_reward': 7.0,
        'household_id': 'h1',
        'created_at': '2026-01-01T00:00:00.000Z',
      };
      final task = TaskModel.fromMap(map);
      expect(task.xpReward, equals(15));
      expect(task.coinReward, equals(7));
    });

    test('Parses due_at date correctly', () {
      final map = {
        'id': 'task-5',
        'title': 'Test',
        'status': 'active',
        'household_id': 'h1',
        'created_at': '2026-01-01T00:00:00.000Z',
        'due_at': '2026-06-15T10:30:00.000Z',
      };
      final task = TaskModel.fromMap(map);
      expect(task.dueAt, isNotNull);
      expect(task.dueAt!.month, equals(6));
      expect(task.dueAt!.day, equals(15));
    });

    test('Invalid due_at date results in null (no crash)', () {
      final map = {
        'id': 'task-6',
        'title': 'Test',
        'status': 'active',
        'household_id': 'h1',
        'created_at': '2026-01-01T00:00:00.000Z',
        'due_at': 'not-a-date',
      };
      final task = TaskModel.fromMap(map);
      expect(task.dueAt, isNull);
    });
  });

  group('✅ TaskModel — Status computed properties', () {
    TaskModel makeTask(TaskStatus status) => TaskModel(
          id: 't',
          title: 'Test',
          status: status,
          xpReward: 10,
          coinReward: 5,
          householdId: 'h1',
          createdAt: DateTime(2026, 1, 1),
        );

    test('isActive is true for "active"', () {
      expect(makeTask(TaskStatus.active).isActive, isTrue);
    });

    test('isActive is true for "assigned" (also active)', () {
      expect(makeTask(TaskStatus.assigned).isActive, isTrue);
    });

    test('isActive is false for other statuses', () {
      expect(makeTask(TaskStatus.verified).isActive, isFalse);
    });

    test('isCompleted/isVerified/isObjected are mutually exclusive', () {
      expect(makeTask(TaskStatus.verified).isVerified, isTrue);
      expect(makeTask(TaskStatus.verified).isObjected, isFalse);

      expect(makeTask(TaskStatus.objected).isObjected, isTrue);
      expect(makeTask(TaskStatus.objected).isVerified, isFalse);
    });

    test('isRecurring is false when recurrenceType is null', () {
      final task = makeTask(TaskStatus.active);
      expect(task.isRecurring, isFalse);
    });

    test('isRecurring is true when recurrenceType is set', () {
      final task = TaskModel(
        id: 't',
        title: 'Weekly',
        status: TaskStatus.active,
        xpReward: 10,
        coinReward: 5,
        householdId: 'h1',
        createdAt: DateTime(2026, 1, 1),
        recurrenceType: 'weekly',
      );
      expect(task.isRecurring, isTrue);
    });
  });

  group('✅ TaskModel — isOverdue', () {
    test('Task with past due date and active status is overdue', () {
      final task = TaskModel(
        id: 't',
        title: 'Overdue task',
        status: TaskStatus.active,
        xpReward: 10,
        coinReward: 5,
        householdId: 'h1',
        createdAt: DateTime(2026, 1, 1),
        dueAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(task.isOverdue, isTrue);
    });

    test('Verified task with past due date is NOT overdue', () {
      final task = TaskModel(
        id: 't',
        title: 'Done task',
        status: TaskStatus.verified,
        xpReward: 10,
        coinReward: 5,
        householdId: 'h1',
        createdAt: DateTime(2026, 1, 1),
        dueAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(task.isOverdue, isFalse);
    });

    test('Task with no due date is never overdue', () {
      final task = TaskModel(
        id: 't',
        title: 'No due',
        status: TaskStatus.active,
        xpReward: 10,
        coinReward: 5,
        householdId: 'h1',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(task.isOverdue, isFalse);
    });
  });

  group('✅ TaskModel — recurrenceLabel', () {
    String labelFor(String? type) => TaskModel(
          id: 't',
          title: 'T',
          status: TaskStatus.active,
          xpReward: 0,
          coinReward: 0,
          householdId: 'h',
          createdAt: DateTime(2026),
          recurrenceType: type,
        ).recurrenceLabel;

    test('daily → "Diaria"', () => expect(labelFor('daily'), equals('Diaria')));
    test('weekly → "Semanal"', () => expect(labelFor('weekly'), equals('Semanal')));
    test('monthly → "Mensual"', () => expect(labelFor('monthly'), equals('Mensual')));
    test('custom → "Personalizada"', () => expect(labelFor('custom'), equals('Personalizada')));
    test('null → "Sin repetición"', () => expect(labelFor(null), equals('Sin repetición')));
  });

  group('✅ TaskModel — copyWith()', () {
    final original = TaskModel(
      id: 'task-1',
      title: 'Original',
      status: TaskStatus.active,
      xpReward: 10,
      coinReward: 5,
      householdId: 'h1',
      createdAt: DateTime(2026, 1, 1),
    );

    test('copyWith changes only specified fields', () {
      final updated = original.copyWith(status: TaskStatus.verified, title: 'Modified');
      expect(updated.id, equals('task-1'));       // unchanged
      expect(updated.householdId, equals('h1')); // unchanged
      expect(updated.status, equals(TaskStatus.verified)); // changed
      expect(updated.title, equals('Modified'));   // changed
    });

    test('copyWith preserves all fields if nothing specified', () {
      final copy = original.copyWith();
      expect(copy.id, equals(original.id));
      expect(copy.title, equals(original.title));
      expect(copy.xpReward, equals(original.xpReward));
    });
  });

  group('✅ TaskModel — equality & hashCode', () {
    test('Two tasks with same id are equal', () {
      final t1 = TaskModel(id: 'x', title: 'A', status: TaskStatus.active, xpReward: 10,
          coinReward: 5, householdId: 'h', createdAt: DateTime(2026),);
      final t2 = TaskModel(id: 'x', title: 'B', status: TaskStatus.verified, xpReward: 99,
          coinReward: 0, householdId: 'h2', createdAt: DateTime(2025),);
      expect(t1, equals(t2));
      expect(t1.hashCode, equals(t2.hashCode));
    });

    test('Tasks with different ids are not equal', () {
      final t1 = TaskModel(id: 'a', title: 'T', status: TaskStatus.active, xpReward: 0,
          coinReward: 0, householdId: 'h', createdAt: DateTime(2026),);
      final t2 = TaskModel(id: 'b', title: 'T', status: TaskStatus.active, xpReward: 0,
          coinReward: 0, householdId: 'h', createdAt: DateTime(2026),);
      expect(t1, isNot(equals(t2)));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // EXPENSE MODEL
  // ───────────────────────────────────────────────────────────────────────────
  group('💸 ExpenseModel — fromJson() deserialization', () {
    test('Parses complete map with nested payer info', () {
      final map = {
        'id': 'exp-1',
        'title': 'Supermercado',
        'amount': 3500.50,
        'category': 'supermarket',
        'household_id': 'h1',
        'paid_by': 'user-1',
        'paid_at': '2026-02-01T12:00:00.000Z',
        'created_at': '2026-02-01T12:00:00.000Z',
        'payer': {'email': 'blas@email.com', 'full_name': 'Blas Oroná'},
      };

      final expense = ExpenseModel.fromJson(map);

      expect(expense.id, equals('exp-1'));
      expect(expense.title, equals('Supermercado'));
      expect(expense.amount, closeTo(3500.50, 0.01));
      expect(expense.category, equals('supermarket'));
      expect(expense.payerEmail, equals('blas@email.com'));
      expect(expense.payerFullName, equals('Blas Oroná'));
    });

    test('Falls back to "users" key if "payer" key missing', () {
      final map = {
        'id': 'exp-2',
        'title': 'Alquiler',
        'amount': 50000.0,
        'household_id': 'h1',
        'paid_by': 'user-1',
        'paid_at': '2026-02-01T12:00:00.000Z',
        'created_at': '2026-02-01T12:00:00.000Z',
        'users': {'email': 'novia@email.com', 'full_name': 'María García'},
      };

      final expense = ExpenseModel.fromJson(map);
      expect(expense.payerEmail, equals('novia@email.com'));
    });

    test('Handles missing payer gracefully (no crash)', () {
      final map = {
        'id': 'exp-3',
        'title': 'Test',
        'amount': 100.0,
        'household_id': 'h1',
        'paid_by': 'user-1',
        'created_at': '2026-02-01T12:00:00.000Z',
      };

      expect(() => ExpenseModel.fromJson(map), returnsNormally);
      final expense = ExpenseModel.fromJson(map);
      expect(expense.payerEmail, isNull);
      expect(expense.payerFullName, isNull);
    });

    test('Defaults amount to 0.0 if null', () {
      final map = {
        'id': 'exp-4',
        'title': 'Test',
        'amount': null,
        'household_id': 'h1',
        'paid_by': 'u1',
        'created_at': '2026-02-01T12:00:00.000Z',
      };
      expect(ExpenseModel.fromJson(map).amount, equals(0.0));
    });
  });

  group('💸 ExpenseModel — Display helpers', () {
    ExpenseModel makeExpense({
      String? fullName,
      String? email,
      String? category,
      double amount = 1234.5,
    }) =>
        ExpenseModel(
          id: 'e',
          title: 'Test',
          amount: amount,
          category: category,
          householdId: 'h',
          paidBy: 'u',
          paidAt: DateTime(2026),
          createdAt: DateTime(2026),
          payerFullName: fullName,
          payerEmail: email,
        );

    test('payerDisplayName uses first name from full name', () {
      expect(makeExpense(fullName: 'Blas Oroná').payerDisplayName, equals('Blas'));
    });

    test('payerDisplayName falls back to email prefix', () {
      expect(makeExpense(email: 'blas@email.com').payerDisplayName, equals('blas'));
    });

    test('payerDisplayName returns "Alguien" when both are null', () {
      expect(makeExpense().payerDisplayName, equals('Alguien'));
    });

    test('formattedAmount shows 2 decimal places with \$ prefix', () {
      expect(makeExpense(amount: 1234.5).formattedAmount, equals(r'$1234.50'));
      expect(makeExpense(amount: 100.0).formattedAmount, equals(r'$100.00'));
    });

    test('categoryIcon returns correct emoji for known categories', () {
      expect(makeExpense(category: 'supermarket').categoryIcon, equals('🛒'));
      expect(makeExpense(category: 'utilities').categoryIcon, equals('💡'));
      expect(makeExpense(category: 'rent').categoryIcon, equals('🏠'));
    });
  });

  group('💸 HouseholdBalanceModel — computed properties', () {
    HouseholdBalanceModel makeBalance(double balance) => HouseholdBalanceModel(
          userId: 'u1',
          balance: balance,
        );

    test('isSettled when balance is ~0', () {
      expect(makeBalance(0.0).isSettled, isTrue);
      expect(makeBalance(0.005).isSettled, isTrue);  // < 0.01 threshold
      expect(makeBalance(-0.005).isSettled, isTrue);
    });

    test('isCreditor when balance > 0.01', () {
      expect(makeBalance(50.0).isCreditor, isTrue);
      expect(makeBalance(-50.0).isCreditor, isFalse);
      expect(makeBalance(0.0).isCreditor, isFalse);
    });

    test('isDebtor when balance < -0.01', () {
      expect(makeBalance(-50.0).isDebtor, isTrue);
      expect(makeBalance(50.0).isDebtor, isFalse);
      expect(makeBalance(0.0).isDebtor, isFalse);
    });

    test('statusLabel shows correct text', () {
      expect(makeBalance(0.0).statusLabel, contains('Al día'));
      expect(makeBalance(100.0).statusLabel, equals('Aportó de más'));
      expect(makeBalance(-100.0).statusLabel, equals('Debe aportar'));
    });

    test('displayName uses full name first', () {
      const b = HouseholdBalanceModel(
        userId: 'u1',
        balance: 0,
        userFullName: 'Blas Oroná',
        userEmail: 'blas@email.com',
      );
      expect(b.displayName, equals('Blas'));
    });

    test('displayName falls back to email prefix', () {
      const b = HouseholdBalanceModel(
        userId: 'u1',
        balance: 0,
        userEmail: 'blas@email.com',
      );
      expect(b.displayName, equals('blas'));
    });

    test('displayName returns "Miembro" when no info', () {
      expect(makeBalance(0).displayName, equals('Miembro'));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // SAVINGS GOAL MODEL
  // ───────────────────────────────────────────────────────────────────────────
  group('🏆 SavingsGoalModel — fromJson() & progress', () {
    test('Parses complete JSON correctly', () {
      final json = {
        'id': 'goal-1',
        'household_id': 'h1',
        'title': 'Vacaciones',
        'target_amount': 100000.0,
        'current_amount': 25000.0,
        'color': '#6366F1',
        'icon': '✈️',
        'created_at': '2026-01-01T00:00:00.000Z',
      };

      final goal = SavingsGoalModel.fromJson(json);
      expect(goal.id, equals('goal-1'));
      expect(goal.title, equals('Vacaciones'));
      expect(goal.targetAmount, closeTo(100000.0, 0.01));
      expect(goal.currentAmount, closeTo(25000.0, 0.01));
      expect(goal.color, equals('#6366F1'));
      expect(goal.icon, equals('✈️'));
    });

    test('progress is 0.0 when nothing saved', () {
      final goal = SavingsGoalModel(
        id: 'g', householdId: 'h', title: 'Test',
        targetAmount: 1000.0, currentAmount: 0.0, createdAt: DateTime(2026),
      );
      expect(goal.progress, equals(0.0));
    });

    test('progress is 0.25 when 25% saved', () {
      final goal = SavingsGoalModel(
        id: 'g', householdId: 'h', title: 'Test',
        targetAmount: 1000.0, currentAmount: 250.0, createdAt: DateTime(2026),
      );
      expect(goal.progress, closeTo(0.25, 0.001));
    });

    test('progress is 1.0 when fully funded', () {
      final goal = SavingsGoalModel(
        id: 'g', householdId: 'h', title: 'Test',
        targetAmount: 1000.0, currentAmount: 1000.0, createdAt: DateTime(2026),
      );
      expect(goal.progress, closeTo(1.0, 0.001));
    });

    test('progress can exceed 1.0 when overfunded', () {
      final goal = SavingsGoalModel(
        id: 'g', householdId: 'h', title: 'Test',
        targetAmount: 1000.0, currentAmount: 1200.0, createdAt: DateTime(2026),
      );
      expect(goal.progress, greaterThan(1.0));
    });

    test('Uses default color and icon when not provided', () {
      final json = {
        'id': 'goal-2',
        'household_id': 'h1',
        'title': 'Meta',
        'target_amount': 5000.0,
        'current_amount': 0.0,
        'created_at': '2026-01-01T00:00:00.000Z',
        // no 'color' or 'icon'
      };
      final goal = SavingsGoalModel.fromJson(json);
      expect(goal.color, equals('#FF7E67'));
      expect(goal.icon, equals('💰'));
    });
  });

  group('🏆 SavingsContributionModel — fromJson()', () {
    test('Parses correctly with nested user data', () {
      final json = {
        'id': 'contrib-1',
        'goal_id': 'goal-1',
        'user_id': 'user-1',
        'amount': 5000.0,
        'note': 'Mi parte del mes',
        'created_at': '2026-02-15T10:00:00.000Z',
        'user': {'full_name': 'Blas Oroná', 'avatar_url': 'https://example.com/avatar.png'},
      };

      final contrib = SavingsContributionModel.fromJson(json);
      expect(contrib.id, equals('contrib-1'));
      expect(contrib.amount, closeTo(5000.0, 0.01));
      expect(contrib.note, equals('Mi parte del mes'));
      expect(contrib.userName, equals('Blas Oroná'));
      expect(contrib.userAvatar, equals('https://example.com/avatar.png'));
    });

    test('Handles missing user data without crashing', () {
      final json = {
        'id': 'contrib-2',
        'goal_id': 'goal-1',
        'user_id': 'user-1',
        'amount': 1000.0,
        'created_at': '2026-02-15T10:00:00.000Z',
        // no 'user' key
      };
      expect(() => SavingsContributionModel.fromJson(json), returnsNormally);
      final contrib = SavingsContributionModel.fromJson(json);
      expect(contrib.userName, isNull);
      expect(contrib.userAvatar, isNull);
    });
  });
}
