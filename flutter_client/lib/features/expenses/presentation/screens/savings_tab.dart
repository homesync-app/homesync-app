import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/amount_input.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/widgets/concept_icon.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_split_builder.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/goal_auto_contribution_sheet.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/design/app_section_header.dart';
import 'package:homesync_client/shared/widgets/edge_fade.dart';
import 'package:homesync_client/shared/widgets/expressive/expressive.dart';
import 'package:intl/intl.dart';

part 'savings_tab_widgets.dart';

class SavingsTab extends ConsumerWidget {
  const SavingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final t = AppLocalizations.of(context);

    return goalsAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (error, stackTrace) => AppErrorState(
        message: t.commonError,
        onRetry: () => ref.invalidate(savingsGoalsProvider),
      ),
      data: (goals) {
        final perms = ref.watch(savingsPermissionsProvider);
        final activeGoals = goals.where((goal) => !goal.isReached).toList();
        final completedGoals = goals.where((goal) => goal.isReached).toList();
        if (goals.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(savingsGoalsProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppInsets.screenBottom + AppSpacing.xl,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // La sugerencia inteligente también sirve (sobre todo) cuando
                // no hay ninguna meta todavía: propone la primera. Se oculta
                // sola si el provider no tiene nada para sugerir.
                const _SavingsSuggesterCard(),
                const SizedBox(height: 28),
                _buildEmptyState(
                  context,
                  ref,
                  t.savingsEmptyTitle,
                  icon: '🎯',
                  subtitle: t.savingsEmptySubtitle,
                  fallbackSubtitle: t.savingsEmptyFallbackSubtitle,
                  showCreateAction: perms.canCreate,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savingsGoalsProvider),
          // Fade también arriba, como en Movimientos: disuelve bajo las tabs.
          child: EdgeFade(
            extent: 0.035,
            child: ListView(
              // PrimaryScrollController del tab Finanzas (re-tap sube al tope).
              primary: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppInsets.screenBottom + AppSpacing.xl,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const _SavingsSuggesterCard(),
                _TotalSavingsHeader(goals: goals),
                AppSectionHeader(
                  title: t.expensesTabGoals,
                  actionLabel: perms.canCreate ? t.expensesFabNewGoal : null,
                  actionIcon: Icons.add_rounded,
                  onAction: perms.canCreate
                      ? () => SavingsTab.showGoalSheet(context, ref)
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < activeGoals.length; i++) ...[
                  _buildGoalCard(
                    context,
                    activeGoals[i],
                    ref,
                  ).animateStaggered(i),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (completedGoals.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    t.savingsCompletedGoalsHistoryTitle.toUpperCase(),
                    style: AppTypography.eyebrow.copyWith(
                      fontSize: 12,
                      color: context.theme.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (var i = 0; i < completedGoals.length; i++) ...[
                    _buildCompletedGoalTile(
                      context,
                      completedGoals[i],
                      ref,
                    ).animateStaggered(activeGoals.length + i),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    String message, {
    String icon = '📉',
    String? subtitle,
    String? fallbackSubtitle,
    bool showCreateAction = false,
  }) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              icon,
              style: AppTypography.body.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.w400,
              ),
            ).animatePulse(),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Text(
              subtitle ?? fallbackSubtitle ?? '',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (showCreateAction) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: AppControlSizes.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => SavingsTab.showGoalSheet(context, ref),
                icon: const Icon(Icons.add_rounded),
                label: Text(t.expensesFabNewGoal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  textStyle: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animateEntrance();
  }

  static Widget _buildGoalCard(
    BuildContext context,
    SavingsGoalModel goal,
    WidgetRef ref,
  ) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final perms = ref.watch(savingsPermissionsProvider);
    final goalColor = AppColors.fromHex(goal.color);
    final progress = goal.progress.clamp(0.0, 1.0);
    final reached = goal.isReached;
    final currency = ref.read(currencyProvider);
    final targetAmount = currency.format(goal.targetAmount);
    final progressPercent = (progress * 100).toInt();
    // Con ahorro real pero <1%, "0%" parece un bug: mostramos "<1%".
    final progressLabel =
        progressPercent == 0 && progress > 0 ? '<1%' : '$progressPercent%';

    return AnimatedPress(
      onTap: perms.canContribute && !reached
          ? () => _showContributionDialog(context, goal, ref)
          : null,
      // Gestión (editar/auto/archivar/borrar) vive en el long-press: el
      // corner de la card queda libre para la acción principal (aportar).
      onLongPress: perms.canManage
          ? () => _showGoalActionsSheet(context, ref, goal, reached)
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(
            color: reached
                ? goalColor.withValues(alpha: 0.45)
                : theme.border.withValues(alpha: 0.9),
            width: reached ? 1.5 : 1,
          ),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: ConceptIcon(emoji: goal.icon, size: 54),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sectionTitle.copyWith(
                          fontSize: 22,
                          height: 1.02,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        t.savingsGoalTarget(targetAmount),
                        style: AppTypography.bodyStrong.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                      if (goal.targetDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xxs),
                          child: Text(
                            t.savingsDeadlineChip(
                              DateFormat('dd MMM yyyy')
                                  .format(goal.targetDate!),
                            ),
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Acción principal en el corner: "+" abre el aporte. El menú
                // de gestión se abre manteniendo pulsada la card; solo cae al
                // kebab cuando no hay aporte posible (meta cumplida / perms).
                if (perms.canContribute && !reached)
                  AnimatedPress(
                    scale: 0.9,
                    haptic: AppPressHaptic.light,
                    onTap: () => _showContributionDialog(context, goal, ref),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  )
                else if (perms.canManage)
                  _GoalMenu(goal: goal, reached: reached),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Solo el monto ahorrado: el objetivo ya se lee en el header
                // ("Meta: …") y la barra cuenta el avance. Rueda hacia arriba
                // al aportar (y desde 0 al entrar) con figuras tabulares.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedAmount(
                      value: goal.currentAmount.toDouble(),
                      locale: currency.locale,
                      format: currency.format,
                      style: AppTypography.heroAmount.copyWith(
                        fontSize: 24,
                        height: 0.98,
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (reached)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppShapedBadge(
                        shape: AppShapes.success,
                        color: goalColor,
                        size: 24,
                        child: const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _CompletedBadge(
                        color: goalColor,
                        label: t.savingsCompletedBadge,
                      ),
                    ],
                  )
                else
                  Text(
                    progressLabel,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: goalColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // M3 Expressive: el ahorro vivo ondula; la barra se aplana sola al
            // llegar a la meta (rampa interna del indicador). El valor crece
            // con tween al entrar y al aportar, sincronizado con el count-up.
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => AppWavyProgress(
                value: value,
                color: goalColor,
              ),
            ),
            _ContributionHistory(goalId: goal.id, accentColor: goalColor),
          ],
        ),
      ),
    );
  }

  static Widget _buildCompletedGoalTile(
    BuildContext context,
    SavingsGoalModel goal,
    WidgetRef ref,
  ) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final goalColor = AppColors.fromHex(goal.color);
    final progress = goal.progress.clamp(0.0, 1.0);
    final currency = ref.read(currencyProvider);

    return AnimatedPress(
      onTap: () => _showGoalDetailSheet(context, goal),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: goalColor.withValues(alpha: 0.28)),
          boxShadow: theme.cardShadow,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: Center(
                child: ConceptIcon(emoji: goal.icon, size: 44),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _CompletedBadge(
                        color: goalColor,
                        label: t.savingsCompletedBadge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.savingsGoalSaved(currency.format(goal.currentAmount)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppWavyProgress.compact(
                    value: progress,
                    color: goalColor,
                    trackColor: theme.divider,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // --- Public entry points used by ExpensesScreen ---

  static void showGoalSheet(
    BuildContext context,
    WidgetRef ref, {
    SavingsGoalModel? existing,
  }) {
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalFormSheet(existing: existing),
    );
  }

  static void _showContributionDialog(
    BuildContext context,
    SavingsGoalModel goal,
    WidgetRef ref,
  ) {
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ContributionSheet(goal: goal),
    );
  }

  static void _showGoalDetailSheet(
    BuildContext context,
    SavingsGoalModel goal,
  ) {
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompletedGoalDetailSheet(goal: goal),
    );
  }

  /// Menú de gestión de la meta (long-press en la card). El sheet solo
  /// devuelve la acción elegida y se resuelve acá, con el context de la card
  /// todavía vivo (el del sheet muere al hacer pop).
  static Future<void> _showGoalActionsSheet(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalModel goal,
    bool reached,
  ) async {
    final action = await AppSheet.show<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalActionsSheet(goal: goal, reached: reached),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case 'edit':
        showGoalSheet(context, ref, existing: goal);
      case 'auto':
        await GoalAutoContributionSheet.show(context, ref, goal);
      case 'archive':
        await _confirmArchiveGoal(context, ref, goal);
      case 'delete':
        await _confirmDeleteGoal(context, ref, goal);
    }
  }
}

/// Split mode the contributor picks before adding money to a goal.
enum _ContributionSplit { solo, shared }
