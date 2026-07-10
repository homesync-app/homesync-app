import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/domain/models/category_budget_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/budget_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/budget_manage_sheet.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_data.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/expressive/expressive.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

/// Fila de presupuestos por categoría bajo el summary card de Movimientos.
///
/// Premium: carrusel horizontal de tarjetas con progreso ondulado; el color
/// pasa a ámbar al 80% y a rojo al pasarse. Free: teaser de una línea que
/// abre el paywall. Sin presupuestos: CTA para crear el primero.
class BudgetSection extends ConsumerWidget {
  const BudgetSection({super.key});

  static const double _cardWidth = 168;
  static const double _cardHeight = 118;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final isPremium = ref.watch(premiumProvider).value ?? false;

    if (!isPremium) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppInsets.screenHorizontal,
          AppSpacing.md,
          AppInsets.screenHorizontal,
          0,
        ),
        child: _TeaserCard(
          onTap: () => PremiumPaywall.show(context),
        ),
      );
    }

    final statusesAsync = ref.watch(categoryBudgetStatusesProvider);

    return statusesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(
          AppInsets.screenHorizontal,
          AppSpacing.md,
          AppInsets.screenHorizontal,
          0,
        ),
        child: ShimmerLoading(height: 64, borderRadius: AppRadii.xl),
      ),
      // No es contenido crítico: ante error dejamos la pantalla limpia.
      error: (_, __) => const SizedBox.shrink(),
      data: (statuses) {
        if (statuses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppInsets.screenHorizontal,
              AppSpacing.md,
              AppInsets.screenHorizontal,
              0,
            ),
            child: _EmptyCta(
              onTap: () => BudgetManageSheet.show(context),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppInsets.screenHorizontal,
                AppSpacing.lg,
                AppInsets.screenHorizontal,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      size: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.budgetsSectionTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: theme.textSecondary.withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => BudgetManageSheet.show(context),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      t.budgetsManageAction,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: _cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppInsets.screenHorizontal,
                ),
                itemCount: statuses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) =>
                    _BudgetCard(status: statuses[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final CategoryBudgetStatus status;

  const _BudgetCard({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final currency = ref.watch(currencyProvider);

    final categories = buildExpenseCategories();
    final category = categories.firstWhere(
      (c) => c['id'] == status.budget.category,
      orElse: () => categories.last,
    );

    final Color accent;
    if (status.isOverLimit) {
      accent = AppColors.error;
    } else if (status.isNearLimit) {
      accent = AppColors.warning;
    } else {
      accent = category['color'] as Color;
    }

    final footer = status.isOverLimit
        ? t.budgetsOverBy(currency.format((-status.remaining).round()))
        : t.budgetsRemaining(currency.format(status.remaining.round()));

    return AnimatedPress(
      onTap: () => BudgetManageSheet.show(context, editBudget: status.budget),
      scale: 0.97,
      child: Container(
        width: BudgetSection._cardWidth,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: status.isOverLimit
                ? accent.withValues(alpha: 0.35)
                : theme.border.withValues(alpha: 0.55),
          ),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category['icon'] as String,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    localizedExpenseCategoryName(t, status.budget.category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            AppWavyProgress.compact(
              value: status.progress,
              color: accent,
              semanticsLabel: localizedExpenseCategoryName(
                t,
                status.budget.category,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.budgetsSpentOf(
                currency.format(status.spent.round()),
                currency.format(status.budget.monthlyLimit.round()),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              footer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: status.isOverLimit || status.isNearLimit
                    ? accent
                    : theme.textPrimary.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeaserCard extends StatelessWidget {
  final VoidCallback onTap;

  const _TeaserCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    const gold = Color(0xFFF59E0B);

    return AnimatedPress(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: gold.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: const Icon(
                Icons.pie_chart_rounded,
                size: 17,
                color: gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.budgetsTeaserTitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    t.budgetsTeaserSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.lock_rounded, size: 16, color: gold),
          ],
        ),
      ),
    );
  }
}

class _EmptyCta extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return AnimatedPress(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: theme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline_rounded,
                size: 20, color: theme.primary,),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.budgetsEmptyCta,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: theme.primary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: theme.primary.withValues(alpha: 0.7),),
          ],
        ),
      ),
    );
  }
}
