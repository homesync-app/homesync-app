import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/settlement_confirm_dialog.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:uuid/uuid.dart';

/// Confirmación para dejar el balance entre los dos en cero.
///
/// Sirve para las dos direcciones: [isOwedByMe] true registra que le pagué a
/// mi pareja; false, que mi pareja me pagó a mí. Antes solo existía la primera,
/// así que quien tenía la plata a favor no podía registrar que ya se la
/// devolvieron.
///
/// Se genera una sola clave de idempotencia por diálogo: si se reintenta tras
/// un error o un timeout, el servidor resuelve a la misma liquidación en vez
/// de duplicarla.
Future<void> showCoupleSettlementDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String partnerId,
  required String partnerName,
  required double amount,
  required bool isOwedByMe,
  VoidCallback? onSettled,
}) async {
  final t = AppLocalizations.of(context);
  final currentUserId = ref.read(currentUserIdProvider);
  if (currentUserId == null) {
    AppSnackBar.show(
      context,
      message: t.homeCoupleSettlementErrorNoUser,
      type: AppSnackBarType.error,
    );
    return;
  }

  final payerId = isOwedByMe ? currentUserId : partnerId;
  final receiverId = isOwedByMe ? partnerId : currentUserId;
  final formattedAmount = ref.read(currencyProvider).format(amount);
  final requestId = const Uuid().v4();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => SettlementConfirmDialog(
      titleText: t.homeCoupleSettlementDialogTitle,
      amountText: formattedAmount,
      directionText: isOwedByMe
          ? t.homeCoupleSettlementDialogDirectionPay(partnerName)
          : t.homeCoupleSettlementDialogDirectionReceive(partnerName),
      bodyText: t.homeCoupleSettlementDialogBalanceZero,
      confirmLabel: t.homeCoupleSettlementDialogConfirm,
      cancelLabel: t.homeCoupleSettlementDialogCancel,
      doneBadgeText: t.homeCoupleSettlementDoneBadge,
      errorTextBuilder: t.homeCoupleSettlementError,
      onConfirm: () => ref.read(expenseControllerProvider.notifier).settleDebt(
            fromUserId: payerId,
            toUserId: receiverId,
            amount: amount,
            requestId: requestId,
          ),
      onSettled: () {
        onSettled?.call();
        if (!context.mounted) return;
        AppSnackBar.show(
          context,
          message: isOwedByMe
              ? t.homeCoupleSettlementSuccessPay(partnerName)
              : t.homeCoupleSettlementSuccessReceive(partnerName),
          type: AppSnackBarType.success,
        );
      },
    ),
  );
}
