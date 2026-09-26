import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/domain/couple_money.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

/// "La plata": el saldo entre los dos y cuánto puso cada uno este mes.
///
/// Con economía dividida muestra la deuda en una frase humana y ofrece
/// saldarla desde el lado que corresponda. Con economía integrada no hay deuda
/// posible: muestra lo que gastaron entre los dos.
class CoupleMoneyCard extends StatelessWidget {
  final bool sharedEconomy;
  final CoupleBalanceView? balance;
  final CoupleMonthMoney? month;
  final String partnerLabel;
  final String Function(double amount) formatAmount;
  final VoidCallback onSettle;
  final VoidCallback onRecordPayment;

  const CoupleMoneyCard({
    super.key,
    required this.sharedEconomy,
    required this.balance,
    required this.month,
    required this.partnerLabel,
    required this.formatAmount,
    required this.onSettle,
    required this.onRecordPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final month = this.month;
    final balance = this.balance;

    if ((!sharedEconomy && balance == null) || month == null) {
      return const _MoneySkeleton();
    }

    final String status;
    final String? detail;
    final IconData icon;
    final Color tint;
    Widget? action;

    if (sharedEconomy) {
      status = month.isEmpty
          ? t.coupleWeekMoneyNoExpenses
          : t.coupleWeekMoneySharedTotal(formatAmount(month.total));
      detail = month.isEmpty
          ? null
          : t.coupleWeekMoneySharedPaid(
              formatAmount(month.mePaid),
              partnerLabel,
              formatAmount(month.partnerPaid),
            );
      icon = Icons.account_balance_wallet_rounded;
      tint = AppColors.iconSage;
    } else {
      final view = balance!;
      detail = month.isEmpty
          ? t.coupleWeekMoneyNoExpenses
          : t.coupleWeekMoneyPaid(
              formatAmount(month.mePaid),
              partnerLabel,
              formatAmount(month.partnerPaid),
            );
      switch (view.direction) {
        case CoupleBalanceDirection.even:
          status = t.coupleWeekMoneyEven;
          icon = Icons.check_circle_rounded;
          tint = AppColors.iconSage;
        case CoupleBalanceDirection.iOwe:
          status = t.coupleWeekMoneyYouOwe(
            formatAmount(view.amount),
            partnerLabel,
          );
          icon = Icons.account_balance_wallet_rounded;
          tint = theme.primary;
          action = AppButton(
            label: t.coupleWeekMoneySettle,
            icon: Icons.payments_rounded,
            size: AppButtonSize.small,
            isFullWidth: true,
            onTap: onSettle,
          );
        case CoupleBalanceDirection.theyOwe:
          status = t.coupleWeekMoneyTheyOwe(
            partnerLabel,
            formatAmount(view.amount),
          );
          icon = Icons.account_balance_wallet_rounded;
          tint = AppColors.iconSage;
          action = AppButton(
            label: t.coupleWeekMoneyRecordPayment,
            icon: Icons.task_alt_rounded,
            size: AppButtonSize.small,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
            onTap: onRecordPayment,
          );
      }
    }

    return AppCard(
      padding: AppInsets.compactCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: tint, size: AppControlSizes.iconMd),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: AppMotion.normal,
                      switchInCurve: AppMotion.standard,
                      child: Text(
                        status,
                        key: ValueKey(status),
                        style: AppTypography.cardTitle.copyWith(
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: AppTypography.caption.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.sm),
            action,
          ],
        ],
      ),
    );
  }
}

class _MoneySkeleton extends StatelessWidget {
  const _MoneySkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: AppInsets.compactCard,
      child: Row(
        children: [
          ShimmerLoading(width: 40, height: 40, borderRadius: 20),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: 160, height: 16, borderRadius: AppRadii.xs),
                SizedBox(height: AppSpacing.xs),
                ShimmerLoading(height: 12, borderRadius: AppRadii.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
