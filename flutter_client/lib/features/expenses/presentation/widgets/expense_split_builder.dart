import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';

class ExpenseSplitBuildResult {
  final List<Map<String, dynamic>> splits;
  final String? validationMessage;

  const ExpenseSplitBuildResult({
    required this.splits,
    this.validationMessage,
  });

  bool get hasValidationError => validationMessage != null;
}

class ExpenseSplitBuilder {
  static ExpenseSplitBuildResult build({
    required bool showSplit,
    required SplitType splitMode,
    required double amount,
    required String paidByUserId,
    required List<MemberModel> financeMembers,
    required Set<String> selectedMembers,
    required Map<String, double> fixedAmounts,
    required double defaultRatio,
    required String? currentUserId,
  }) {
    if (!showSplit || splitMode == SplitType.personal) {
      return ExpenseSplitBuildResult(
        splits: [
          {'user_id': paidByUserId, 'amount': amount},
        ],
      );
    }

    if (splitMode == SplitType.gift) {
      return const ExpenseSplitBuildResult(splits: []);
    }

    if (splitMode == SplitType.equal) {
      if (financeMembers.length == 2 && defaultRatio != 0.5) {
        final splits = financeMembers.map((member) {
          final isCurrentUser = member.userId == currentUserId;
          final memberRatio = isCurrentUser ? defaultRatio : (1.0 - defaultRatio);
          return {
            'user_id': member.userId,
            'amount': amount * memberRatio,
          };
        }).toList();

        return ExpenseSplitBuildResult(splits: splits);
      }

      if (selectedMembers.isEmpty) {
        return const ExpenseSplitBuildResult(
          splits: [],
          validationMessage: 'Debes seleccionar al menos un miembro para dividir.',
        );
      }

      final splitAmount = amount / selectedMembers.length;
      final splits = selectedMembers
          .map((memberId) => {
                'user_id': memberId,
                'amount': splitAmount,
              },)
          .toList();

      return ExpenseSplitBuildResult(splits: splits);
    }

    if (splitMode == SplitType.fixed) {
      double totalFixed = 0;
      final splits = <Map<String, dynamic>>[];

      for (final member in financeMembers) {
        final amountForMember = fixedAmounts[member.userId] ?? 0.0;
        if (amountForMember > 0) {
          totalFixed += amountForMember;
          splits.add({
            'user_id': member.userId,
            'amount': amountForMember,
          });
        }
      }

      if ((totalFixed - amount).abs() > 0.01) {
        return ExpenseSplitBuildResult(
          splits: splits,
          validationMessage:
              'El reparto debe sumar el total (\$${amount.toStringAsFixed(2)})',
        );
      }

      return ExpenseSplitBuildResult(splits: splits);
    }

    return const ExpenseSplitBuildResult(splits: []);
  }
}
