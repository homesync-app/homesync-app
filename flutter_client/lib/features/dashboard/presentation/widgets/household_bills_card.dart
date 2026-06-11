import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/recurring_expense_form_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';

/// "Cuentas del piso" para modo convivencia (friends).
///
/// Las cuentas fijas compartidas (alquiler, luz, internet, expensas) son EL
/// feature central de roomies. Reutiliza la infra de gastos recurrentes
/// (`ExpenseTemplateModel` + `RecurringExpenseFormSheet`) pero la presenta como
/// ciudadana de primera clase en el hub de convivencia, no escondida en una
/// sub-tab de Finanzas. Default de split equitativo entre N.
class HouseholdBillsCard extends ConsumerWidget {
  const HouseholdBillsCard({super.key});

  String _formatCurrency(num value) => '\$${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final isPremium = ref.watch(premiumProvider).value ?? false;
    final templatesAsync = ref.watch(expenseTemplateControllerProvider);

    // Solo gastos fijos compartidos (no ingresos, no personales).
    final bills = (templatesAsync.value ?? const <ExpenseTemplateModel>[])
        .where((tpl) => !tpl.isIncome && tpl.splitType != 'personal')
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.householdBillsTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.textPrimary,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.householdBillsSubtitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPremium)
                const Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: AppColors.accentGold,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isPremium)
            _buildPremiumLocked(context, theme, t)
          else if (bills.isEmpty)
            _buildEmpty(theme, t)
          else ...[
            ...bills.map((bill) => _buildBillRow(context, theme, t, bill)),
            const SizedBox(height: 14),
            _buildAddButton(context, t),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumLocked(
    BuildContext context,
    AppThemeColors theme,
    AppLocalizations t,
  ) {
    return Column(
      children: [
        Text(
          t.householdBillsPremiumBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => PremiumPaywall.show(context),
            icon: const Icon(Icons.workspace_premium_rounded, size: 20),
            label: Text(t.householdBillsPremiumUnlock),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(AppThemeColors theme, AppLocalizations t) {
    return Column(
      children: [
        Icon(
          Icons.receipt_long_rounded,
          size: 40,
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 12),
        Text(
          t.householdBillsEmptyTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t.householdBillsEmptyBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(
    BuildContext context,
    AppThemeColors theme,
    AppLocalizations t,
    ExpenseTemplateModel bill,
  ) {
    final emoji = CategoryMapping.categoryIcons[bill.category] ?? '🏠';
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: () => RecurringExpenseFormSheet.show(context, template: bill),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.surfaceVariant,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 19)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.householdBillsDayOfMonth(bill.dayOfMonth),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              t.householdBillsPerMonth(_formatCurrency(bill.defaultAmount)),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, AppLocalizations t) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => RecurringExpenseFormSheet.show(context),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text(t.householdBillsAddButton),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
