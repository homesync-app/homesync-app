import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';

class SimplifiedDebt {
  final String fromUserId;
  final String fromName;
  final String? fromAvatarUrl;
  final String toUserId;
  final String toName;
  final String? toAvatarUrl;
  final double amount;

  const SimplifiedDebt({
    required this.fromUserId,
    required this.fromName,
    required this.fromAvatarUrl,
    required this.toUserId,
    required this.toName,
    required this.toAvatarUrl,
    required this.amount,
  });

  String get description =>
      '$fromName le paga \$${amount.toStringAsFixed(0)} a $toName';
}

class DebtSimplifier {
  static List<SimplifiedDebt> simplify(
    List<HouseholdBalanceModel> balances,
  ) {
    final creditors = <_BalanceEntry>[];
    final debtors = <_BalanceEntry>[];

    for (final b in balances) {
      if (b.balance > 0.01) {
        creditors.add(
            _BalanceEntry(b.userId, b.displayName, b.avatarUrl, b.balance));
      } else if (b.balance < -0.01) {
        debtors.add(
            _BalanceEntry(b.userId, b.displayName, b.avatarUrl, -b.balance));
      }
    }

    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b) => b.amount.compareTo(a.amount));

    final result = <SimplifiedDebt>[];
    var ci = 0, di = 0;

    while (ci < creditors.length && di < debtors.length) {
      final creditor = creditors[ci];
      final debtor = debtors[di];
      final transfer =
          creditor.amount < debtor.amount ? creditor.amount : debtor.amount;

      if (transfer > 0.01) {
        result.add(SimplifiedDebt(
          fromUserId: debtor.userId,
          fromName: debtor.name,
          fromAvatarUrl: debtor.avatarUrl,
          toUserId: creditor.userId,
          toName: creditor.name,
          toAvatarUrl: creditor.avatarUrl,
          amount: transfer,
        ));
      }

      creditor.amount -= transfer;
      debtor.amount -= transfer;

      if (creditor.amount < 0.01) ci++;
      if (debtor.amount < 0.01) di++;
    }

    return result;
  }
}

class _BalanceEntry {
  final String userId;
  final String name;
  final String? avatarUrl;
  double amount;

  _BalanceEntry(this.userId, this.name, this.avatarUrl, this.amount);
}
