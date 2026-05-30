// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — DebtSimplifier contract tests
//
// Exercises the REAL DebtSimplifier from lib/ (core/utils/debt_simplifier.dart),
// which powers the multi-member settle-up in the friends/convivencia dashboard.
// This is the highest-risk logic in the friends mode: it decides who pays whom
// to bring every member's balance back to zero.
//
// Convention (matches HouseholdBalanceModel): a POSITIVE balance means the
// member is a creditor (they're owed money / "a favor"); a NEGATIVE balance
// means they're a debtor (they owe / "debe").
//
// Run with: flutter test test/debt_simplifier_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/utils/debt_simplifier.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';

void main() {
  HouseholdBalanceModel balance(String id, double amount) =>
      HouseholdBalanceModel(
        userId: id,
        userFullName: id,
        balance: amount,
      );

  group('DebtSimplifier.simplify', () {
    test('returns no debts when everyone is settled', () {
      final debts = DebtSimplifier.simplify([
        balance('a', 0),
        balance('b', 0),
      ]);
      expect(debts, isEmpty);
    });

    test('treats sub-cent balances as settled (noise tolerance)', () {
      final debts = DebtSimplifier.simplify([
        balance('a', 0.009),
        balance('b', -0.009),
      ]);
      expect(debts, isEmpty);
    });

    test('simple two-member debt: debtor pays creditor the full amount', () {
      final debts = DebtSimplifier.simplify([
        balance('creditor', 50),
        balance('debtor', -50),
      ]);

      expect(debts, hasLength(1));
      expect(debts.single.fromUserId, 'debtor');
      expect(debts.single.toUserId, 'creditor');
      expect(debts.single.amount, closeTo(50, 0.001));
    });

    test('one debtor splits across two creditors (largest creditor first)', () {
      final debts = DebtSimplifier.simplify([
        balance('debtor', -100),
        balance('bigCreditor', 70),
        balance('smallCreditor', 30),
      ]);

      // Greedy match: largest creditor is paid first.
      expect(debts, hasLength(2));
      expect(debts[0].toUserId, 'bigCreditor');
      expect(debts[0].amount, closeTo(70, 0.001));
      expect(debts[1].toUserId, 'smallCreditor');
      expect(debts[1].amount, closeTo(30, 0.001));
      expect(debts.every((d) => d.fromUserId == 'debtor'), isTrue);
    });

    test('every transfer conserves money: debts sum to total owed', () {
      final balances = [
        balance('a', -40),
        balance('b', -20),
        balance('c', 35),
        balance('d', 25),
      ];

      final debts = DebtSimplifier.simplify(balances);

      final totalMoved =
          debts.fold<double>(0, (sum, d) => sum + d.amount);
      final totalOwed = balances
          .where((b) => b.balance < 0)
          .fold<double>(0, (sum, b) => sum + b.balance.abs());

      expect(totalMoved, closeTo(totalOwed, 0.001));
      expect(totalMoved, closeTo(60, 0.001));
    });

    test('settling all produced debts leaves everyone at zero', () {
      final balances = [
        balance('a', -40),
        balance('b', -20),
        balance('c', 35),
        balance('d', 25),
      ];

      final net = <String, double>{
        for (final b in balances) b.userId: b.balance,
      };

      for (final debt in DebtSimplifier.simplify(balances)) {
        // Debtor pays (their negative balance moves toward zero), creditor
        // receives (their positive balance moves toward zero).
        net[debt.fromUserId] = net[debt.fromUserId]! + debt.amount;
        net[debt.toUserId] = net[debt.toUserId]! - debt.amount;
      }

      for (final entry in net.entries) {
        expect(entry.value, closeTo(0, 0.001),
            reason: '${entry.key} should net to zero after settlement');
      }
    });

    test('never emits a zero or negative transfer', () {
      final debts = DebtSimplifier.simplify([
        balance('a', -15),
        balance('b', 10),
        balance('c', 5),
      ]);

      expect(debts, isNotEmpty);
      expect(debts.every((d) => d.amount > 0.01), isTrue);
    });

    test('carries debtor/creditor names and avatars into the result', () {
      final debts = DebtSimplifier.simplify([
        HouseholdBalanceModel(
          userId: 'u1',
          userFullName: 'Ana Lopez',
          avatarUrl: 'http://x/ana.png',
          balance: -30,
        ),
        HouseholdBalanceModel(
          userId: 'u2',
          userFullName: 'Beto Diaz',
          avatarUrl: 'http://x/beto.png',
          balance: 30,
        ),
      ]);

      expect(debts, hasLength(1));
      final d = debts.single;
      expect(d.fromName, 'Ana'); // displayName takes first token
      expect(d.fromAvatarUrl, 'http://x/ana.png');
      expect(d.toName, 'Beto');
      expect(d.toAvatarUrl, 'http://x/beto.png');
    });
  });
}
