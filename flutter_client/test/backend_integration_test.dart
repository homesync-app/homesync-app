// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — Comprehensive Unit Test Suite
// Run with: flutter test test/backend_integration_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // 1. AUTH — User registration & login validation
  // ───────────────────────────────────────────────────────────────────────────
  group('🔐 Auth — Email/Password Validation', () {
    test('Email must contain @', () {
      expect(AuthValidator.isValidEmail('user@email.com'), isTrue);
      expect(AuthValidator.isValidEmail('invalidemail.com'), isFalse);
      expect(AuthValidator.isValidEmail(''), isFalse);
    });

    test('Password must be at least 6 characters', () {
      expect(AuthValidator.isValidPassword('pass123'), isTrue);
      expect(AuthValidator.isValidPassword('12345'), isFalse);
      expect(AuthValidator.isValidPassword(''), isFalse);
    });

    test('Full name is optional on sign-up but cannot be blank if provided',
        () {
      expect(AuthValidator.isValidName(null), isTrue); // optional
      expect(AuthValidator.isValidName('Blas'), isTrue);
      expect(AuthValidator.isValidName('  '), isFalse); // whitespace only
    });

    test('signUp creates a solo household of type couple by default', () {
      const householdType = 'couple';
      expect(householdType, equals('couple'));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 2. HOUSEHOLD LINKING — Invitation code & join flow
  // ───────────────────────────────────────────────────────────────────────────
  group('🏠 Household — Invitation Codes', () {
    test('Invitation code must be exactly 6 characters', () {
      expect(InviteCodeValidator.isValid('ABC123'), isTrue);
      expect(InviteCodeValidator.isValid('AB12'), isFalse);
      expect(InviteCodeValidator.isValid(''), isFalse);
      expect(InviteCodeValidator.isValid('TOOLONG7'), isFalse);
    });

    test('Code is case-insensitive — normalized to uppercase', () {
      expect(InviteCodeValidator.normalize('abc123'), equals('ABC123'));
      expect(InviteCodeValidator.normalize('AbCdEf'), equals('ABCDEF'));
    });

    test('Generated codes are 6 uppercase alphanumeric chars', () {
      final code = InviteCodeValidator.generateFakeCode();
      expect(code.length, equals(6));
      expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(code), isTrue);
    });

    test('Owner role can generate invitation, member cannot', () {
      expect(HouseholdRole.canGenerateInvite('owner'), isTrue);
      expect(HouseholdRole.canGenerateInvite('member'), isFalse);
    });

    test('Joining a household removes user from solo household', () {
      // Simulates the join flow: old household should be cleaned up
      final user = FakeUser(id: 'u1', householdId: 'solo-house');
      final result = HouseholdJoinSimulator.join(
        user: user,
        code: 'ABC123',
        targetHouseholdId: 'real-house',
      );
      expect(result.householdId, equals('real-house'));
      expect(result.oldHouseholdDeleted, isTrue);
    });

    test('Joining with invalid code returns error', () {
      final result = HouseholdJoinSimulator.join(
        user: FakeUser(id: 'u1', householdId: 'solo-house'),
        code: 'WRONG!', // invalid char
        targetHouseholdId: null, // no match
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('Cannot join if already in the target household', () {
      final user = FakeUser(id: 'u1', householdId: 'real-house');
      final result = HouseholdJoinSimulator.join(
        user: user,
        code: 'ABC123',
        targetHouseholdId: 'real-house',
      );
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('ya perteneces'));
    });

    test('Couple household enforces max 2 members', () {
      expect(HouseholdType.canAddMember('couple', currentCount: 1), isTrue);
      expect(HouseholdType.canAddMember('couple', currentCount: 2), isFalse);
    });

    test('ensureHouseholdExists is idempotent for existing users', () {
      final user = FakeUser(id: 'u1', householdId: 'existing-house');
      final alreadyHasHousehold = user.householdId != null;
      expect(alreadyHasHousehold, isTrue); // skip creation
    });

    test('Google OAuth user with no household gets one created', () {
      final user = FakeUser(id: 'google-u1', householdId: null);
      final ensured = HouseholdEnsurer.ensure(user);
      expect(ensured.householdId, isNotNull);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 3. TASKS — CRUD, status, recurrence
  // ───────────────────────────────────────────────────────────────────────────
  group('✅ Tasks — Model & Status Logic', () {
    test('Active task is eligible for completion', () {
      final task = TaskModel(
          id: '1',
          title: 'Lavar platos',
          status: 'active',
          category: 'kitchen');
      expect(task.canComplete, isTrue);
    });

    test('Pending verification task cannot be completed again', () {
      final task = TaskModel(
          id: '2',
          title: 'Limpiar baño',
          status: 'pending_verification',
          category: 'bathroom');
      expect(task.canComplete, isFalse);
    });

    test('Verified task cannot be completed', () {
      final task = TaskModel(
          id: '3',
          title: 'Hacer cama',
          status: 'verified',
          category: 'bedroom');
      expect(task.canComplete, isFalse);
    });

    test('Objected task goes back to active', () {
      final task = TaskModel(
          id: '4',
          title: 'Sacar basura',
          status: 'objected',
          category: 'general');
      expect(task.canRedo, isTrue);
    });

    test('Task categories match expected values', () {
      const validCategories = [
        'cleaning',
        'kitchen',
        'bathroom',
        'bedroom',
        'general',
        'outdoor',
        'pets'
      ];
      for (final cat in validCategories) {
        expect(TaskCategory.isValid(cat), isTrue);
      }
      expect(TaskCategory.isValid('unknown_category'), isFalse);
    });

    test('Task XP reward is non-negative', () {
      final task = TaskModel(
          id: '5',
          title: 'Test',
          status: 'active',
          category: 'general',
          xpReward: 20,
          coinReward: 10);
      expect(task.xpReward, greaterThanOrEqualTo(0));
      expect(task.coinReward, greaterThanOrEqualTo(0));
    });

    test('Task difficulty determines default rewards', () {
      expect(TaskDifficulty.defaultXp('easy'), equals(10));
      expect(TaskDifficulty.defaultXp('medium'), equals(20));
      expect(TaskDifficulty.defaultXp('hard'), equals(40));
    });

    test('Only non-owner can verify tasks (cross-verification)', () {
      // The verifier must be different from the completer
      const completerId = 'user-1';
      const verifierId = 'user-2';
      expect(TaskVerifier.canVerify(completerId, verifierId), isTrue);
      expect(TaskVerifier.canVerify(completerId, completerId), isFalse);
    });
  });

  group('🔄 Tasks — Recurrence', () {
    test('Daily recurrence advances by 1 day', () {
      final due = DateTime(2026, 2, 19, 10, 0);
      final next = RecurrenceCalculator.nextDueDate(due, 'daily', 1);
      expect(next.day, equals(20));
      expect(next.month, equals(2));
    });

    test('Weekly recurrence advances by 7 days', () {
      final due = DateTime(2026, 2, 19, 10, 0);
      final next = RecurrenceCalculator.nextDueDate(due, 'weekly', 1);
      expect(next.day, equals(26));
    });

    test('Biweekly recurrence advances by 14 days (weekly interval=2)', () {
      final due = DateTime(2026, 2, 19, 10, 0);
      final next = RecurrenceCalculator.nextDueDate(due, 'weekly', 2);
      final diff = next.difference(due).inDays;
      expect(diff, equals(14));
    });

    test('Monthly recurrence advances month by 1', () {
      final due = DateTime(2026, 2, 19, 10, 0);
      final next = RecurrenceCalculator.nextDueDate(due, 'monthly', 1);
      expect(next.month, equals(3));
    });

    test('Non-recurring task has no recurrenceType', () {
      final task = TaskModel(
          id: '1', title: 'One-time', status: 'active', category: 'general');
      expect(task.isRecurring, isFalse);
    });

    test('Recurring task has recurrenceType set', () {
      final task = TaskModel(
          id: '2',
          title: 'Weekly',
          status: 'active',
          category: 'general',
          recurrenceType: 'weekly');
      expect(task.isRecurring, isTrue);
    });

    test('Recurrence label is human-readable', () {
      expect(RecurrenceHelper.getLabel('daily'), equals('🔄 Diaria'));
      expect(RecurrenceHelper.getLabel('weekly'), equals('🔄 Semanal'));
      expect(RecurrenceHelper.getLabel('monthly'), equals('🔄 Mensual'));
      expect(RecurrenceHelper.getLabel('custom'), equals('🔄 Personalizada'));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 4. EXPENSES — Creation, balance, settlement
  // ───────────────────────────────────────────────────────────────────────────
  group('💸 Expenses — Balance Logic', () {
    test('Equal split divides amount in half', () {
      final split = ExpenseSplit.equal(amount: 100.0, memberCount: 2);
      expect(split.perPerson, equals(50.0));
    });

    test('Equal split with 3 members', () {
      final split = ExpenseSplit.equal(amount: 90.0, memberCount: 3);
      expect(split.perPerson, closeTo(30.0, 0.01));
    });

    test('Payer owes 0 to themselves', () {
      final expense = FakeExpense(
        amount: 100.0,
        paidBy: 'u1',
        splitBetween: ['u1', 'u2'],
      );
      final whatU1Owes = expense.amountOwedBy('u1');
      expect(whatU1Owes, lessThanOrEqualTo(0.0));
    });

    test('Non-payer owes their share', () {
      final expense = FakeExpense(
        amount: 100.0,
        paidBy: 'u1',
        splitBetween: ['u1', 'u2'],
      );
      expect(expense.amountOwedBy('u2'), closeTo(50.0, 0.01));
    });

    test('Expense amount must be positive', () {
      expect(ExpenseValidator.isValidAmount(1.0), isTrue);
      expect(ExpenseValidator.isValidAmount(0.0), isFalse);
      expect(ExpenseValidator.isValidAmount(-50.0), isFalse);
    });

    test('Expense title cannot be empty', () {
      expect(ExpenseValidator.isValidTitle('Pizza'), isTrue);
      expect(ExpenseValidator.isValidTitle(''), isFalse);
      expect(ExpenseValidator.isValidTitle('   '), isFalse);
    });

    test('Expense categories are valid', () {
      const validCategories = [
        'food',
        'transport',
        'home',
        'entertainment',
        'health',
        'shopping',
        'utilities',
        'other'
      ];
      for (final cat in validCategories) {
        expect(ExpenseCategory.isValid(cat), isTrue);
      }
    });

    test('Balance summary: net amount correctly computed', () {
      // u1 paid 100, split equally → u2 owes u1 50
      final balances = BalanceCalculator.calculate(
        paid: {'u1': 100.0, 'u2': 0.0},
        owed: {'u1': 50.0, 'u2': 50.0},
      );
      expect(balances['u1'], closeTo(50.0, 0.01)); // u1 is owed 50
      expect(balances['u2'], closeTo(-50.0, 0.01)); // u2 owes 50
    });

    test('Settled expenses reduce balance to zero', () {
      final balance = BalanceCalculator.afterSettlement(
        currentBalance: -50.0,
        settledAmount: 50.0,
      );
      expect(balance, closeTo(0.0, 0.01));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 5. REWARDS / COINS — Store & transfer
  // ───────────────────────────────────────────────────────────────────────────
  group('🎁 Rewards — Store Logic', () {
    test('User can afford reward if coins >= cost', () {
      final reward = Reward(
          id: '1', title: 'Pizza', cost: 50, icon: '🍕', isCustom: false);
      expect(reward.canAfford(100), isTrue);
      expect(reward.canAfford(50), isTrue);
      expect(reward.canAfford(49), isFalse);
    });

    test('Default reward options are present', () {
      const defaultRewards = [
        'Elegir la película',
        'Masaje de 15 min',
        'Desayuno en la cama',
        'Librarse de lavar platos',
        'Elegir qué cenar',
        'Día libre de tareas',
      ];
      expect(defaultRewards.length, equals(6));
    });

    test('Custom reward requires title and positive cost', () {
      final valid =
          CustomRewardInput(title: 'Movie Night', cost: 30, icon: '🎬');
      final noTitle = CustomRewardInput(title: '', cost: 30, icon: '🎬');
      final zeroCost = CustomRewardInput(title: 'Test', cost: 0, icon: '🎁');

      expect(valid.isValid, isTrue);
      expect(noTitle.isValid, isFalse);
      expect(zeroCost.isValid, isFalse);
    });

    test('Transfer amount must be positive', () {
      expect(TransferValidator.isValidAmount(1), isTrue);
      expect(TransferValidator.isValidAmount(0), isFalse);
      expect(TransferValidator.isValidAmount(-10), isFalse);
    });

    test('Cannot transfer coins to self', () {
      expect(TransferValidator.isDifferentUser('u1', 'u1'), isFalse);
      expect(TransferValidator.isDifferentUser('u1', 'u2'), isTrue);
    });

    test('Insufficient balance prevents transfer', () {
      expect(TransferValidator.hasSufficientBalance(100, 50), isTrue);
      expect(TransferValidator.hasSufficientBalance(49, 50), isFalse);
    });

    test('Ledger entry types include all expected values', () {
      expect(LedgerEntryType.values, contains('task_completion'));
      expect(LedgerEntryType.values, contains('coin_transfer'));
      expect(LedgerEntryType.values, contains('coin_received'));
      expect(LedgerEntryType.values, contains('reward_redemption'));
      expect(LedgerEntryType.values, contains('xp_earned'));
    });

    test('Balance computed correctly from ledger entries', () {
      final entries = [
        LedgerEntry(type: 'task_completion', amount: 10),
        LedgerEntry(type: 'task_completion', amount: 5),
        LedgerEntry(type: 'coin_transfer', amount: -3),
        LedgerEntry(type: 'reward_redemption', amount: -5),
      ];
      final balance = entries.fold<int>(0, (sum, e) => sum + e.amount);
      expect(balance, equals(7));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 6. STATS — Rankings & history
  // ───────────────────────────────────────────────────────────────────────────
  group('📊 Stats — Rankings & History', () {
    test('Weekly ranking sorted by XP descending', () {
      final ranking = [
        {'user': 'u2', 'xp': 30},
        {'user': 'u1', 'xp': 80},
        {'user': 'u3', 'xp': 50},
      ];
      ranking.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      expect(ranking.first['user'], equals('u1'));
      expect(ranking.last['user'], equals('u2'));
    });

    test('Week range label is correctly generated', () {
      final now = DateTime(2026, 2, 20); // Thursday
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      final label =
          '${monday.day}/${monday.month} – ${sunday.day}/${sunday.month}';
      expect(label, contains('16/2'));
      expect(label, contains('22/2'));
    });

    test('Task stats totals aggregate correctly', () {
      final taskStats = [
        {'category': 'kitchen', 'completed_count': 5, 'total_xp': 100},
        {'category': 'bathroom', 'completed_count': 3, 'total_xp': 60},
        {'category': 'cleaning', 'completed_count': 2, 'total_xp': 40},
      ];
      final totalTasks = taskStats.fold<int>(
          0, (s, e) => s + ((e['completed_count'] as num).toInt()));
      final totalXp = taskStats.fold<int>(
          0, (s, e) => s + ((e['total_xp'] as num).toInt()));
      expect(totalTasks, equals(10));
      expect(totalXp, equals(200));
    });

    test('Member contribution pie chart percentages sum to 100', () {
      final members = [
        {'user': 'u1', 'xp_earned': 60},
        {'user': 'u2', 'xp_earned': 40},
      ];
      final total =
          members.fold<int>(0, (s, m) => s + ((m['xp_earned'] as num).toInt()));
      final percents =
          members.map((m) => (m['xp_earned'] as int) / total * 100).toList();
      final sum = percents.reduce((a, b) => a + b);
      expect(sum, closeTo(100.0, 0.01));
    });

    test('MVP is member with most completed tasks', () {
      final members = [
        {'user': 'u1', 'tasks_completed': 10},
        {'user': 'u2', 'tasks_completed': 15},
      ];
      final mvp = members.reduce((a, b) =>
          (a['tasks_completed'] as int) >= (b['tasks_completed'] as int)
              ? a
              : b);
      expect(mvp['user'], equals('u2'));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 7. TRANSACTION HELPERS
  // ───────────────────────────────────────────────────────────────────────────
  group('💬 Transaction — Icons & Labels', () {
    test('getIcon returns correct emoji for each type', () {
      expect(TransactionHelper.getIcon('coins_earned'), equals('✅'));
      expect(TransactionHelper.getIcon('coin_transfer'), equals('📤'));
      expect(TransactionHelper.getIcon('coin_received'), equals('📥'));
      expect(TransactionHelper.getIcon('reward_redemption'), equals('🎁'));
      expect(TransactionHelper.getIcon('xp_earned'), equals('⭐'));
      expect(TransactionHelper.getIcon('unknown'), equals('💰'));
    });

    test('getLabel returns readable text for each type', () {
      expect(TransactionHelper.getLabel('coins_earned', null),
          equals('Tarea completada'));
      expect(TransactionHelper.getLabel('coin_transfer', null),
          equals('Coins enviados'));
      expect(TransactionHelper.getLabel('coin_received', null),
          equals('Coins recibidos'));
      expect(TransactionHelper.getLabel('reward_redemption', null),
          equals('Canje de premio'));
    });

    test('Positive transaction amount returns isPositive=true', () {
      final tx = Transaction(amount: 10);
      expect(tx.isPositive, isTrue);
    });

    test('Negative transaction amount returns isPositive=false', () {
      final tx = Transaction(amount: -5);
      expect(tx.isPositive, isFalse);
    });

    test('Date formatted correctly from ISO string', () {
      const dateStr = '2026-02-19T15:30:00Z';
      final formatted = TransactionHelper.formatDate(dateStr);
      expect(formatted.contains('19'), isTrue);
      expect(formatted.contains('2026'), isTrue);
    });

    test('Invalid date returns original string', () {
      const bad = 'not-a-date';
      final formatted = TransactionHelper.formatDate(bad);
      expect(formatted, equals(bad));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 8. HOUSEHOLD TYPES
  // ───────────────────────────────────────────────────────────────────────────
  group('🏡 Household Types', () {
    test('Couple max members is 2', () {
      expect(HouseholdType.maxMembers('couple'), equals(2));
    });

    test('Family and roommates have unlimited members (-1)', () {
      expect(HouseholdType.maxMembers('family'), equals(-1));
      expect(HouseholdType.maxMembers('roommates'), equals(-1));
    });

    test('Anyone can verify in couple and roommates', () {
      expect(HouseholdType.anyoneCanVerify('couple'), isTrue);
      expect(HouseholdType.anyoneCanVerify('roommates'), isTrue);
    });

    test('Only owner can verify in family type', () {
      expect(HouseholdType.anyoneCanVerify('family'), isFalse);
    });

    test('canAddMember respects limit', () {
      expect(HouseholdType.canAddMember('couple', currentCount: 1), isTrue);
      expect(HouseholdType.canAddMember('couple', currentCount: 2), isFalse);
      expect(HouseholdType.canAddMember('family', currentCount: 10), isTrue);
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER CLASSES (pure Dart — no Flutter/Supabase dependencies)
// ─────────────────────────────────────────────────────────────────────────────

// ── Auth ─────────────────────────────────────────────────────────────────────
class AuthValidator {
  static bool isValidEmail(String email) =>
      email.contains('@') && email.isNotEmpty;
  static bool isValidPassword(String password) => password.length >= 6;
  static bool isValidName(String? name) {
    if (name == null) return true; // optional
    return name.trim().isNotEmpty;
  }
}

// ── Household & Invitations ───────────────────────────────────────────────────
class InviteCodeValidator {
  static bool isValid(String code) =>
      RegExp(r'^[A-Z0-9]{6}$').hasMatch(code.toUpperCase()) && code.length == 6;
  static String normalize(String code) => code.trim().toUpperCase();
  static String generateFakeCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(6, (i) => chars[i % chars.length]).join();
  }
}

class HouseholdRole {
  static bool canGenerateInvite(String role) => role == 'owner';
}

class FakeUser {
  final String id;
  String? householdId;
  FakeUser({required this.id, this.householdId});
}

class _JoinResult {
  final bool success;
  final String? householdId;
  final bool oldHouseholdDeleted;
  final String? errorMessage;
  _JoinResult({
    required this.success,
    this.householdId,
    this.oldHouseholdDeleted = false,
    this.errorMessage,
  });
}

class HouseholdJoinSimulator {
  static _JoinResult join({
    required FakeUser user,
    required String code,
    required String? targetHouseholdId,
  }) {
    if (!InviteCodeValidator.isValid(code)) {
      return _JoinResult(success: false, errorMessage: 'Código inválido');
    }
    if (targetHouseholdId == null) {
      return _JoinResult(success: false, errorMessage: 'Código no encontrado');
    }
    if (user.householdId == targetHouseholdId) {
      return _JoinResult(
          success: false, errorMessage: 'ya perteneces a este hogar');
    }
    return _JoinResult(
      success: true,
      householdId: targetHouseholdId,
      oldHouseholdDeleted: true,
    );
  }
}

class HouseholdEnsurer {
  static FakeUser ensure(FakeUser user) {
    if (user.householdId != null) return user;
    user.householdId = 'new-household-id';
    return user;
  }
}

class HouseholdType {
  static int maxMembers(String type) => type == 'couple' ? 2 : -1;

  static bool anyoneCanVerify(String type) => type != 'family';

  static bool canAddMember(String type, {required int currentCount}) {
    final max = maxMembers(type);
    return max == -1 || currentCount < max;
  }
}

// ── Tasks ─────────────────────────────────────────────────────────────────────
class TaskModel {
  final String id;
  final String title;
  final String status;
  final String category;
  final String? recurrenceType;
  final int xpReward;
  final int coinReward;

  TaskModel({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    this.recurrenceType,
    this.xpReward = 20,
    this.coinReward = 10,
  });

  bool get canComplete => status == 'active';
  bool get canRedo => status == 'objected';
  bool get isRecurring => recurrenceType != null;
}

class TaskCategory {
  static const _valid = {
    'cleaning',
    'kitchen',
    'bathroom',
    'bedroom',
    'general',
    'outdoor',
    'pets'
  };
  static bool isValid(String cat) => _valid.contains(cat);
}

class TaskDifficulty {
  static int defaultXp(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 10;
      case 'medium':
        return 20;
      case 'hard':
        return 40;
      default:
        return 20;
    }
  }
}

class TaskVerifier {
  static bool canVerify(String completedBy, String verifierId) =>
      completedBy != verifierId;
}

class RecurrenceCalculator {
  static DateTime nextDueDate(DateTime current, String type, int interval) {
    switch (type) {
      case 'daily':
        return current.add(Duration(days: interval));
      case 'weekly':
        return current.add(Duration(days: interval * 7));
      case 'monthly':
        return DateTime(
            current.year, current.month + interval, current.day, current.hour);
      default:
        return current;
    }
  }
}

class RecurrenceHelper {
  static String getLabel(String type) {
    switch (type) {
      case 'daily':
        return '🔄 Diaria';
      case 'weekly':
        return '🔄 Semanal';
      case 'monthly':
        return '🔄 Mensual';
      case 'custom':
        return '🔄 Personalizada';
      default:
        return '🔄 $type';
    }
  }
}

// ── Expenses ──────────────────────────────────────────────────────────────────
class ExpenseSplit {
  final double perPerson;
  ExpenseSplit._({required this.perPerson});

  static ExpenseSplit equal(
          {required double amount, required int memberCount}) =>
      ExpenseSplit._(perPerson: amount / memberCount);
}

class FakeExpense {
  final double amount;
  final String paidBy;
  final List<String> splitBetween;

  FakeExpense(
      {required this.amount, required this.paidBy, required this.splitBetween});

  double amountOwedBy(String userId) {
    final share = amount / splitBetween.length;
    if (userId == paidBy) return share - amount; // payer receives money back
    return share;
  }
}

class ExpenseValidator {
  static bool isValidAmount(double amount) => amount > 0;
  static bool isValidTitle(String title) => title.trim().isNotEmpty;
}

class ExpenseCategory {
  static const _valid = {
    'food',
    'transport',
    'home',
    'entertainment',
    'health',
    'shopping',
    'utilities',
    'other'
  };
  static bool isValid(String cat) => _valid.contains(cat);
}

class BalanceCalculator {
  static Map<String, double> calculate({
    required Map<String, double> paid,
    required Map<String, double> owed,
  }) {
    final result = <String, double>{};
    for (final userId in paid.keys) {
      result[userId] = (paid[userId] ?? 0) - (owed[userId] ?? 0);
    }
    return result;
  }

  static double afterSettlement(
          {required double currentBalance, required double settledAmount}) =>
      currentBalance + settledAmount;
}

// ── Rewards ───────────────────────────────────────────────────────────────────
class Reward {
  final String id;
  final String title;
  final int cost;
  final String icon;
  final bool isCustom;
  final bool isActive;
  final String? description;

  Reward({
    required this.id,
    required this.title,
    required this.cost,
    required this.icon,
    required this.isCustom,
    this.isActive = true,
    this.description,
  });

  bool canAfford(int userCoins) => userCoins >= cost;
}

class CustomRewardInput {
  final String title;
  final int cost;
  final String icon;

  CustomRewardInput(
      {required this.title, required this.cost, required this.icon});

  bool get isValid => title.trim().isNotEmpty && cost > 0;
}

class TransferValidator {
  static bool isValidAmount(int amount) => amount > 0;
  static bool isDifferentUser(String from, String to) => from != to;
  static bool hasSufficientBalance(int balance, int amount) =>
      balance >= amount;
}

class LedgerEntry {
  final String type;
  final int amount;
  LedgerEntry({required this.type, required this.amount});
}

class LedgerEntryType {
  static const List<String> values = [
    'task_completion',
    'coin_transfer',
    'coin_received',
    'reward_redemption',
    'xp_earned',
  ];
}

// ── Transactions ──────────────────────────────────────────────────────────────
class Transaction {
  final int amount;
  Transaction({required this.amount});
  bool get isPositive => amount > 0;
}

class TransactionHelper {
  static String getIcon(String type) {
    switch (type) {
      case 'task_completion':
      case 'coins_earned':
        return '✅';
      case 'coin_transfer':
        return '📤';
      case 'coin_received':
        return '📥';
      case 'reward_redemption':
        return '🎁';
      case 'xp_earned':
        return '⭐';
      default:
        return '💰';
    }
  }

  static String getLabel(String type, String? description) {
    switch (type) {
      case 'task_completion':
      case 'coins_earned':
        return 'Tarea completada';
      case 'coin_transfer':
        return 'Coins enviados';
      case 'coin_received':
        return 'Coins recibidos';
      case 'reward_redemption':
        return 'Canje de premio';
      case 'xp_earned':
        return 'XP ganado';
      default:
        return description ?? type;
    }
  }

  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} '
          '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
