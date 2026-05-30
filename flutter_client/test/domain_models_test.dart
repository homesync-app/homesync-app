// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — Domain model contract tests
//
// These tests exercise the REAL production models from lib/ (TaskModel,
// ExpenseModel, HouseholdBalanceModel, HouseholdCapabilities/HouseholdType).
//
// NOTE: this file replaces the old `backend_integration_test.dart`, which
// re-implemented all of this logic *inside the test file* and therefore never
// touched production code. Those tests were tautological — they could stay
// green while the real app logic broke. Always assert against lib/ symbols.
//
// Run with: flutter test test/domain_models_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // TaskModel — status logic & completion eligibility
  // ───────────────────────────────────────────────────────────────────────────
  group('TaskModel status logic', () {
    TaskModel taskWith(TaskStatus status) => TaskModel(
          id: 't1',
          title: 'Lavar platos',
          status: status,
          xpReward: 20,
          coinReward: 10,
          householdId: 'h1',
          createdAt: DateTime(2026, 1, 1),
        );

    test('active task is pending/actionable', () {
      final task = taskWith(TaskStatus.active);
      expect(task.isActive, isTrue);
      expect(task.isPending, isTrue);
      expect(task.isCompleted, isFalse);
    });

    test('pending_verification task counts as completed, not active', () {
      final task = taskWith(TaskStatus.pendingVerification);
      expect(task.isPendingVerification, isTrue);
      expect(task.isCompleted, isTrue);
      expect(task.isActive, isFalse);
    });

    test('verified task is completed and not active', () {
      final task = taskWith(TaskStatus.verified);
      expect(task.isVerified, isTrue);
      expect(task.isCompleted, isTrue);
      expect(task.isActive, isFalse);
    });

    test('objected task returns to the active pool', () {
      final task = taskWith(TaskStatus.objected);
      expect(task.isObjected, isTrue);
      expect(task.isActive, isTrue);
    });

    test('TaskStatus.fromString maps snake_case backend values', () {
      expect(
        TaskStatus.fromString('pending_approval'),
        TaskStatus.pendingApproval,
      );
      expect(
        TaskStatus.fromString('pending_verification'),
        TaskStatus.pendingVerification,
      );
      expect(TaskStatus.fromString('verified'), TaskStatus.verified);
      // Unknown / null falls back to active.
      expect(TaskStatus.fromString('garbage'), TaskStatus.active);
      expect(TaskStatus.fromString(null), TaskStatus.active);
    });

    test('TaskStatus.dbValue round-trips snake_case', () {
      expect(TaskStatus.pendingApproval.dbValue, 'pending_approval');
      expect(TaskStatus.pendingVerification.dbValue, 'pending_verification');
      expect(TaskStatus.verified.dbValue, 'verified');
    });
  });

  group('TaskModel recurrence', () {
    TaskModel recurring(String? type) => TaskModel(
          id: 't1',
          title: 'Test',
          status: TaskStatus.active,
          xpReward: 0,
          coinReward: 0,
          householdId: 'h1',
          createdAt: DateTime(2026, 1, 1),
          recurrenceType: type,
        );

    test('non-recurring task has isRecurring == false', () {
      expect(recurring(null).isRecurring, isFalse);
    });

    test('recurring task has isRecurring == true', () {
      expect(recurring('weekly').isRecurring, isTrue);
    });

    test('daily recurring task is always scheduled for today', () {
      final task = recurring('daily');
      expect(task.isScheduledForToday, isTrue);
    });

    test('hasRotation reflects rotation pool presence', () {
      final noPool = recurring('daily');
      final withPool = TaskModel(
        id: 't2',
        title: 'Rotates',
        status: TaskStatus.active,
        xpReward: 0,
        coinReward: 0,
        householdId: 'h1',
        createdAt: DateTime(2026, 1, 1),
        rotationPool: const ['user-1', 'user-2'],
      );
      expect(noPool.hasRotation, isFalse);
      expect(withPool.hasRotation, isTrue);
    });
  });

  group('TaskModel.fromMap / toMap round-trip', () {
    test('parses backend snapshot and serializes back', () {
      final map = {
        'id': 'task-9',
        'title': 'Sacar la basura',
        'status': 'pending_verification',
        'xp_reward': 30,
        'coin_reward': 5,
        'household_id': 'house-1',
        'created_at': '2026-02-19T10:00:00Z',
        'recurrence_type': 'weekly',
        'recurrence_interval': 2,
        'type': 'recurring',
        'difficulty': 'hard',
      };

      final task = TaskModel.fromMap(map);
      expect(task.id, 'task-9');
      expect(task.status, TaskStatus.pendingVerification);
      expect(task.xpReward, 30);
      expect(task.recurrenceInterval, 2);
      expect(task.type, TaskType.recurring);
      expect(task.difficulty, TaskDifficulty.hard);

      final serialized = task.toMap();
      expect(serialized['status'], 'pending_verification');
      expect(serialized['type'], 'recurring');
      expect(serialized['recurrence_interval'], 2);
    });

    test('tolerates missing fields with sane defaults', () {
      final task = TaskModel.fromMap({'id': 'x'});
      expect(task.title, isNotEmpty); // 'Sin título'
      expect(task.status, TaskStatus.active);
      expect(task.xpReward, 0);
      expect(task.difficulty, TaskDifficulty.medium);
      expect(task.priority, TaskPriority.medium);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // ExpenseModel — privacy inference & display helpers
  // ───────────────────────────────────────────────────────────────────────────
  group('ExpenseModel privacy inference', () {
    ExpenseModel fromSplit(String splitType, {bool? isShared}) {
      final map = {
        'id': 'e1',
        'title': 'Gasto',
        'amount': 100,
        'household_id': 'h1',
        'paid_by': 'u1',
        'split_type': splitType,
        'created_at': '2026-03-21T10:00:00Z',
        'paid_at': '2026-03-21T10:00:00Z',
      };
      if (isShared != null) map['is_shared'] = isShared;
      return ExpenseModel.fromJson(map);
    }

    test('personal split is inferred private when is_shared omitted', () {
      expect(fromSplit('personal').isShared, isFalse);
    });

    test('gift split is inferred private when is_shared omitted', () {
      expect(fromSplit('gift').isShared, isFalse);
    });

    test('equal split is inferred shared when is_shared omitted', () {
      expect(fromSplit('equal').isShared, isTrue);
    });

    test('explicit is_shared from backend always wins', () {
      expect(fromSplit('personal', isShared: true).isShared, isTrue);
      expect(fromSplit('equal', isShared: false).isShared, isFalse);
    });
  });

  group('ExpenseModel display helpers', () {
    test('formattedAmount renders two decimals with currency sign', () {
      final expense = ExpenseModel(
        id: 'e1',
        title: 'Café',
        amount: 150.5,
        householdId: 'h1',
        paidBy: 'u1',
        paidAt: DateTime(2026, 3, 1),
        createdAt: DateTime(2026, 3, 1),
      );
      expect(expense.formattedAmount, '\$150.50');
      expect(expense.categoryIcon, isNotEmpty);
    });

    test('payerDisplayName prefers first name then email then fallback', () {
      ExpenseModel withPayer({String? name, String? email}) => ExpenseModel(
            id: 'e1',
            title: 't',
            amount: 1,
            householdId: 'h1',
            paidBy: 'u1',
            paidAt: DateTime(2026, 3, 1),
            createdAt: DateTime(2026, 3, 1),
            payerFullName: name,
            payerEmail: email,
          );
      expect(withPayer(name: 'Juan Pérez').payerDisplayName, 'Juan');
      expect(withPayer(email: 'ana@mail.com').payerDisplayName, 'ana');
      expect(withPayer().payerDisplayName, 'Alguien');
    });

    test('type helpers distinguish income / expense / settlement', () {
      ExpenseModel typed(String type) => ExpenseModel(
            id: 'e1',
            title: 't',
            amount: 1,
            householdId: 'h1',
            paidBy: 'u1',
            paidAt: DateTime(2026, 3, 1),
            createdAt: DateTime(2026, 3, 1),
            type: type,
          );
      expect(typed('income').isIncome, isTrue);
      expect(typed('expense').isExpense, isTrue);
      expect(typed('settlement').isSettlement, isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // HouseholdBalanceModel — balance status logic
  // ───────────────────────────────────────────────────────────────────────────
  group('HouseholdBalanceModel status', () {
    HouseholdBalanceModel withBalance(double b) =>
        HouseholdBalanceModel(userId: 'u1', balance: b);

    test('creditor has positive balance beyond the rounding epsilon', () {
      final creditor = withBalance(50);
      expect(creditor.isCreditor, isTrue);
      expect(creditor.isDebtor, isFalse);
      expect(creditor.isSettled, isFalse);
    });

    test('debtor has negative balance beyond the rounding epsilon', () {
      final debtor = withBalance(-30);
      expect(debtor.isDebtor, isTrue);
      expect(debtor.isCreditor, isFalse);
      expect(debtor.isSettled, isFalse);
    });

    test('sub-cent balance is treated as settled', () {
      expect(withBalance(0).isSettled, isTrue);
      expect(withBalance(0.005).isSettled, isTrue);
      expect(withBalance(-0.009).isSettled, isTrue);
    });

    test('displayName prefers first name, then email local-part, then fallback',
        () {
      expect(
        const HouseholdBalanceModel(
          userId: 'u1',
          userFullName: 'Juan Pérez',
          balance: 0,
        ).displayName,
        'Juan',
      );
      expect(
        const HouseholdBalanceModel(
          userId: 'u2',
          userEmail: 'ana@mail.com',
          balance: 0,
        ).displayName,
        'ana',
      );
      expect(
        const HouseholdBalanceModel(userId: 'u3', balance: 0).displayName,
        'Miembro',
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // HouseholdType / HouseholdCapabilities — mode-aware feature gating
  // ───────────────────────────────────────────────────────────────────────────
  group('HouseholdType.fromString', () {
    test('maps known backend strings', () {
      expect(HouseholdType.fromString('solo'), HouseholdType.solo);
      expect(HouseholdType.fromString('couple'), HouseholdType.couple);
      expect(HouseholdType.fromString('family'), HouseholdType.family);
      expect(HouseholdType.fromString('friends'), HouseholdType.friends);
    });

    test('maps legacy "roommates" alias to friends', () {
      expect(HouseholdType.fromString('roommates'), HouseholdType.friends);
    });

    test('is case-insensitive', () {
      expect(HouseholdType.fromString('COUPLE'), HouseholdType.couple);
    });

    test('falls back to couple for unknown/null', () {
      expect(HouseholdType.fromString('weird'), HouseholdType.couple);
      expect(HouseholdType.fromString(null), HouseholdType.couple);
    });
  });

  group('HouseholdCapabilities feature gating', () {
    HouseholdCapabilities caps(HouseholdType type, {bool tasks = true}) =>
        HouseholdCapabilities(type: type, tasksEnabled: tasks);

    test('solo hides partner tab, split, shared tasks and love notes', () {
      final solo = caps(HouseholdType.solo);
      expect(solo.showPartnerTab, isFalse);
      expect(solo.showExpensesSplit, isFalse);
      expect(solo.hasSharedTasks, isFalse);
      expect(solo.showLoveNotes, isFalse);
      expect(solo.showFamilyBoard, isFalse);
    });

    test('couple shows love notes and couple rewards experience', () {
      final couple = caps(HouseholdType.couple);
      expect(couple.showLoveNotes, isTrue);
      expect(couple.usesCoupleRewardsExperience, isTrue);
      expect(couple.showFamilyBoard, isFalse);
      expect(couple.showPartnerTab, isTrue);
    });

    test('family and friends show the family board, not love notes', () {
      for (final type in [HouseholdType.family, HouseholdType.friends]) {
        final c = caps(type);
        expect(c.showFamilyBoard, isTrue, reason: '$type should show board');
        expect(c.showLoveNotes, isFalse, reason: '$type has no love notes');
        expect(c.usesCoupleRewardsExperience, isFalse);
      }
    });

    test('tasksEnabled gates tasks and stats together', () {
      final disabled = caps(HouseholdType.family, tasks: false);
      expect(disabled.showTasks, isFalse);
      expect(disabled.showStats, isFalse);
    });
  });
}
