import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';

/// Por que no se pudo armar el reparto. El texto lo pone la UI (ARB): aca
/// solo va el motivo, asi el builder no hardcodea copy en un idioma.
enum ExpenseSplitValidationError {
  /// Reparto entre miembros sin ningun miembro elegido.
  noMembersSelected,

  /// Montos fijos que no suman el total del gasto.
  fixedAmountsMismatch,
}

class ExpenseSplitBuildResult {
  final List<Map<String, dynamic>> splits;
  final ExpenseSplitValidationError? validationError;

  const ExpenseSplitBuildResult({
    required this.splits,
    this.validationError,
  });

  bool get hasValidationError => validationError != null;
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
    String? splitRatioAnchorId,
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
      // The configured ratio belongs to the anchor member (not "whoever is
      // creating the expense"), so the split is stable regardless of who loads
      // or pays it. Falls back to an even split when there is no anchor.
      final anchorId = splitRatioAnchorId;
      if (financeMembers.length == 2 && defaultRatio != 0.5 && anchorId != null) {
        final splits = financeMembers.map((member) {
          final isAnchor = member.userId == anchorId;
          final memberRatio = isAnchor ? defaultRatio : (1.0 - defaultRatio);
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
          validationError: ExpenseSplitValidationError.noMembersSelected,
        );
      }

      final splitAmount = amount / selectedMembers.length;
      final splits = selectedMembers
          .map(
            (memberId) => {
              'user_id': memberId,
              'amount': splitAmount,
            },
          )
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
          validationError: ExpenseSplitValidationError.fixedAmountsMismatch,
        );
      }

      return ExpenseSplitBuildResult(splits: splits);
    }

    return const ExpenseSplitBuildResult(splits: []);
  }
}
