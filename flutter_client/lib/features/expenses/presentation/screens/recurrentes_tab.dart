import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/utils/finance_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/edge_fade.dart';
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
      loading: () => const Center(child: AppLoader()),
      error: (error, stackTrace) => AppErrorState(
        message: t.expensesRecurringLoadError,
        onRetry: () => ref.invalidate(expenseTemplateControllerProvider),
      ),
      data: (templates) {
        final incomes = templates.where((t) => t.isIncome).toList();
        final expenses = templates.where((t) => !t.isIncome).toList();

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(expenseTemplateControllerProvider),
          color: AppColors.primary,
          // Fade también arriba, como en Movimientos: disuelve bajo las tabs.
          child: EdgeFade(
            extent: 0.035,
            child: CustomScrollView(
              // PrimaryScrollController del tab Finanzas (re-tap sube al tope).
              primary: true,
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
                            padding: const EdgeInsets.all(AppSpacing.xl),
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
                            style: AppTypography.sectionTitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxxl,
                            ),
                            child: Text(
                              t.expensesRecurringEmptySubtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary,
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
              style: AppTypography.eyebrow.copyWith(
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => onTemplateForm(
          context,
          template: template,
          initialType: template.type,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
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
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.md),
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
                      style: AppTypography.cardTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)
                          .expensesRecurrentesDayOfMonth(template.dayOfMonth),
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: template.isIncome
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!template.isIncome)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Text(
                        _templateSplitLabel(context, template.splitType),
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
    const gold = Color(0xFFF59E0B);
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // El padding explícito descarta el inset automático de MediaQuery, así
        // que hay que sumar a mano el alto de la nav flotante (extendBody):
        // sin esto el CTA queda pegado/tapado por la pill de navegación.
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_repeat_rounded,
                size: 44,
                color: gold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t.expensesRecurrentesPremiumTitle,
              textAlign: TextAlign.center,
              style: AppTypography.heroAmount.copyWith(
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.expensesRecurrentesPremiumSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 14.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: gold.withValues(alpha: 0.18)),
                boxShadow: theme.cardShadow,
              ),
              child: Column(
                children: [
                  _premiumBullet(
                    icon: Icons.autorenew_rounded,
                    text: t.expensesRecurrentesPremiumBullet1,
                    theme: theme,
                  ),
                  _premiumBulletDivider(theme),
                  _premiumBullet(
                    icon: Icons.notifications_active_rounded,
                    text: t.expensesRecurrentesPremiumBullet2,
                    theme: theme,
                  ),
                  _premiumBulletDivider(theme),
                  _premiumBullet(
                    icon: Icons.visibility_rounded,
                    text: t.expensesRecurrentesPremiumBullet3,
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    PremiumPaywall.show(context, source: 'recurring_expenses'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  t.expensesRecurrentesPremiumCta,
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _premiumBullet({
    required IconData icon,
    required String text,
    required AppThemeColors theme,
  }) {
    const gold = Color(0xFFF59E0B);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, size: 17, color: gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                fontSize: 13,
                height: 1.3,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumBulletDivider(AppThemeColors theme) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 46),
      color: theme.isDarkMode ? theme.divider : AppColors.divider,
    );
  }
}
