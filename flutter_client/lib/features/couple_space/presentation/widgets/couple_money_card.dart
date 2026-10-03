import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/domain/couple_money.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_art.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/design/app_section_header.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

/// Keep the title readable when the action needs a separate line.
class CoupleMoneySectionHeader extends StatelessWidget {
  final VoidCallback onAction;

  const CoupleMoneySectionHeader({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 340 &&
            MediaQuery.textScalerOf(context).scale(14) <= 16) {
          return AppSectionHeader(
            title: t.coupleWeekMoneyTitle,
            actionLabel: t.coupleWeekMoneySeeAll,
            onAction: onAction,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(title: t.coupleWeekMoneyTitle),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(t.coupleWeekMoneySeeAll),
            ),
          ],
        );
      },
    );
  }
}

/// El saldo entre los dos y cuánto puso cada uno este mes. Solo quien debe
/// tiene el botón para saldar; con economía integrada se muestra el total.
class CoupleMoneyCard extends StatelessWidget {
  final bool sharedEconomy;
  final CoupleBalanceView? balance;
  final CoupleMonthMoney? month;
  final CouplePerson me;
  final CouplePerson partner;
  final String Function(double amount) formatAmount;
  final VoidCallback onSettle;

  const CoupleMoneyCard({
    super.key,
    required this.sharedEconomy,
    required this.balance,
    required this.month,
    required this.me,
    required this.partner,
    required this.formatAmount,
    required this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final month = this.month;
    final balance = this.balance;
    final partnerLabel = partner.label;

    if ((!sharedEconomy && balance == null) || month == null) {
      return const _MoneySkeleton();
    }

    // Lo que se lee de corrido (para el lector de pantalla) y lo que se ve:
    // una etiqueta chica arriba y el monto grande abajo.
    final String spoken;
    final String label;
    final String? amount;
    final Color amountColor;
    final Color tint;
    Widget? footer;

    if (sharedEconomy) {
      tint = AppColors.sage;
      if (month.isEmpty) {
        spoken = t.coupleWeekMoneyNoExpenses;
        label = t.coupleWeekMoneyNoExpenses;
        amount = null;
      } else {
        spoken = t.coupleWeekMoneySharedTotal(formatAmount(month.total));
        label = t.coupleWeekMoneySharedLabel;
        amount = formatAmount(month.total);
      }
      amountColor = theme.textPrimary;
    } else {
      final view = balance!;
      switch (view.direction) {
        case CoupleBalanceDirection.even:
          spoken = t.coupleWeekMoneyEven;
          label = t.coupleWeekMoneyEven;
          amount = null;
          amountColor = theme.textPrimary;
          tint = AppColors.sage;
        case CoupleBalanceDirection.iOwe:
          spoken = t.coupleWeekMoneyYouOwe(
            formatAmount(view.amount),
            partnerLabel,
          );
          label = t.coupleWeekMoneyYouOweLabel(partnerLabel);
          amount = formatAmount(view.amount);
          amountColor =
              theme.isDarkMode ? theme.primary : AppColors.primaryDark;
          tint = theme.primary;
          footer = AppButton(
            label: t.coupleWeekMoneySettle,
            icon: Icons.payments_rounded,
            size: AppButtonSize.small,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
            onTap: onSettle,
          );
        case CoupleBalanceDirection.theyOwe:
          spoken = t.coupleWeekMoneyTheyOwe(
            partnerLabel,
            formatAmount(view.amount),
          );
          label = t.coupleWeekMoneyTheyOweLabel(partnerLabel);
          amount = formatAmount(view.amount);
          amountColor = AppColors.iconSage;
          tint = AppColors.sage;
          footer = Text(
            t.coupleSettleCreditorHint(partnerLabel),
            style: AppTypography.caption.copyWith(
              color: theme.textSecondary,
            ),
          );
      }
    }

    final headline = Semantics(
      label: spoken,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: amount == null
                  ? AppTypography.cardTitle.copyWith(color: theme.textPrimary)
                  : AppTypography.caption.copyWith(
                      color: theme.textSecondary,
                    ),
            ),
            if (amount != null)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  maxLines: 1,
                  style: AppTypography.heroAmount.copyWith(
                    fontSize: 28,
                    color: amountColor,
                    fontFeatures: kTabularFigures,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return CoupleSurface(
      padding: AppInsets.compactCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tint.withValues(
                      alpha: theme.isDarkMode ? 0.2 : 0.14,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  alignment: Alignment.center,
                  child: const CoupleArt(kind: CoupleArtKind.wallet, size: 48),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.normal,
                  switchInCurve: AppMotion.standard,
                  // El layout por defecto centra: el monto va a la izquierda.
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, if (current != null) current],
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(spoken),
                    child: headline,
                  ),
                ),
              ),
            ],
          ),
          if (!month.isEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              t.coupleWeekMoneyPaidCaption(sharedEconomy ? 'shared' : 'split'),
              style: AppTypography.caption.copyWith(
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _PaidChip(
                    person: me,
                    amount: formatAmount(month.mePaid),
                    tint: theme.primary,
                  ),
                ),
                SizedBox(
                  height: 34,
                  child: VerticalDivider(
                    width: AppSpacing.md,
                    color: theme.border,
                  ),
                ),
                Expanded(
                  child: _PaidChip(
                    person: partner,
                    amount: formatAmount(month.partnerPaid),
                    tint: AppColors.sage,
                  ),
                ),
              ],
            ),
          ] else if (!sharedEconomy) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.coupleWeekMoneyNoExpenses,
              style: AppTypography.caption.copyWith(
                color: theme.textSecondary,
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer,
          ],
        ],
      ),
    );
  }
}

/// Lo que puso una persona este mes, con su mascota y el color de su lado.
class _PaidChip extends StatelessWidget {
  final CouplePerson person;
  final String amount;
  final Color tint;

  const _PaidChip({
    required this.person,
    required this.amount,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Semantics(
      label: '${person.label}: $amount',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        amount,
                        maxLines: 1,
                        style: AppTypography.bodyStrong.copyWith(
                          color: theme.textPrimary,
                          fontFeatures: kTabularFigures,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      child: Column(
        children: [
          Row(
            children: [
              ShimmerLoading(width: 48, height: 48, borderRadius: AppRadii.md),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(
                      width: 120,
                      height: 12,
                      borderRadius: AppRadii.xs,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    ShimmerLoading(
                      width: 170,
                      height: 26,
                      borderRadius: AppRadii.xs,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(height: 46, borderRadius: AppRadii.md),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: ShimmerLoading(height: 46, borderRadius: AppRadii.md),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
