import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/settlement_confirm_dialog.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:uuid/uuid.dart';

/// Confirmación para que quien debe registre que le pagó a su pareja.
///
/// Solo la usa quien debe: en pareja no hace falta que el otro confirme, si
/// le pagó le pagó, y el saldo queda en cero al instante. Quien tiene la plata
/// a favor no registra nada (decisión de producto, 2026-09-28).
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

  final formattedAmount = ref.read(currencyProvider).format(amount);
  final requestId = const Uuid().v4();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => SettlementConfirmDialog(
      titleText: t.homeCoupleSettlementDialogTitle,
      amountText: formattedAmount,
      directionText: t.homeCoupleSettlementDialogDirectionPay(partnerName),
      bodyText: t.homeCoupleSettlementDialogBalanceZero,
      confirmLabel: t.homeCoupleSettlementDialogConfirm,
      cancelLabel: t.homeCoupleSettlementDialogCancel,
      doneBadgeText: t.homeCoupleSettlementDoneBadge,
      errorTextBuilder: t.homeCoupleSettlementError,
      onConfirm: () => ref.read(expenseControllerProvider.notifier).settleDebt(
            fromUserId: currentUserId,
            toUserId: partnerId,
            amount: amount,
            requestId: requestId,
          ),
      onSettled: () {
        onSettled?.call();
        if (!context.mounted) return;
        AppSnackBar.show(
          context,
          message: t.homeCoupleSettlementSuccessPay(partnerName),
          type: AppSnackBarType.success,
        );
        _askForReviewAfterSettle(ref);
      },
    ),
  );
}

/// Dejar el balance en cero es un momento de alivio: el mejor para pedir la
/// reseña. El servicio decide si corresponde; si falla, el equilibrio igual
/// quedó registrado y no se muestra nada.
void _askForReviewAfterSettle(WidgetRef ref) {
  try {
    unawaited(ref.read(reviewPromptServiceProvider).onSettleUp());
  } catch (error) {
    log.w('Review prompt skipped after settle-up: $error');
  }
}
