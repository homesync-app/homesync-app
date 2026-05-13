import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/utils/finance_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';

class RecurrentesTab extends ConsumerWidget {
  final String Function(num) formatCurrency;
  final void Function(
    BuildContext context, {
    ExpenseTemplateModel? template,
    String initialType,
  }) onTemplateForm;

  const RecurrentesTab({
    required this.formatCurrency,
    required this.onTemplateForm,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumProvider).value ?? false;
    if (!isPremium) return _buildPremiumLockedRecurrentes(context);

    final t = AppLocalizations.of(context);
    final templatesAsync = ref.watch(expenseTemplateControllerProvider);

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(AppLocalizations.of(context).commonErrorWithDetails('$e')),
      ),
      data: (templates) {
        final incomes = templates.where((t) => t.isIncome).toList();
        final expenses = templates.where((t) => !t.isIncome).toList();

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(expenseTemplateControllerProvider),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (templates.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.update_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ).animatePulse(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t.expensesRecurringEmptyTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            t.expensesRecurringEmptySubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                )
              else ...[
                if (incomes.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    t.expensesRecurringIncomeSection,
                    AppColors.success,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTemplateCard(
                          context,
                          incomes[index],
                          index,
                          AppColors.success,
                        ),
                        childCount: incomes.length,
                      ),
                    ),
                  ),
                ],
                if (expenses.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    t.expensesRecurringExpenseSection,
                    AppColors.primary,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTemplateCard(
                          context,
                          expenses[index],
                          index,
                          null,
                        ),
                        childCount: expenses.length,
                      ),
                    ),
                  ),
                ],
                if (incomes.isEmpty || expenses.isEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        );
      },
    );
  }

  String _templateSplitLabel(BuildContext context, String splitType) {
    final t = AppLocalizations.of(context);
    switch (splitType.toLowerCase()) {
      case 'equal':
        return t.expensesFormSplitShared;
      case 'fixed':
        return t.expensesFormSplitFixed;
      case 'gift':
        return t.expensesFormSplitGift;
      case 'personal':
        return t.expensesFormSplitPersonal;
      default:
        return t.expensesFormSplitShared;
    }
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String label,
    Color color,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: color.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    ExpenseTemplateModel template,
    int index,
    Color? overrideColor,
  ) {
    final color = overrideColor ??
        CategoryMapping.getSmartExpenseDisplayColor(
          template.category,
          title: template.title,
          description: null,
        );
    final icon = template.isIncome
        ? Icons.savings_rounded
        : CategoryMapping.getSmartExpenseDisplayIcon(
            template.category,
            title: template.title,
            description: null,
          );
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onTemplateForm(
          context,
          template: template,
          initialType: template.type,
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedFinanceTitle(
                        AppLocalizations.of(context),
                        title: template.title,
                        titleKey: template.titleKey,
                        category: template.category,
                        transactionType: template.type,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)
                          .expensesRecurrentesDayOfMonth(template.dayOfMonth),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(template.defaultAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: template.isIncome
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!template.isIncome)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _templateSplitLabel(context, template.splitType),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.sage,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animateStaggered(index);
  }

  Widget _buildPremiumLockedRecurrentes(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                size: 80,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context).expensesRecurrentesPremiumTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).expensesRecurrentesPremiumSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PremiumPaywall.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context).expensesRecurrentesPremiumCta,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
