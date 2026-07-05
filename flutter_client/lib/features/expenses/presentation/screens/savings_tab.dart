import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/amount_input.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/widgets/concept_icon.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_split_builder.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/design/app_section_header.dart';
import 'package:homesync_client/shared/widgets/edge_fade.dart';
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
      error: (e, _) => Center(child: Text(t.savingsLoadError(e.toString()))),
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
                const SizedBox(height: 64),
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
          child: EdgeFade(
            fadeStart: false,
            fadeEnd: true,
            child: ListView(
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
                    style: TextStyle(
                      color: context.theme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
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
            child:
                Text(icon, style: const TextStyle(fontSize: 48)).animatePulse(),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Text(
              subtitle ?? fallbackSubtitle ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
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
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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
    final currentAmount = currency.format(goal.currentAmount);
    final targetAmount = currency.format(goal.targetAmount);
    final progressPercent = (progress * 100).toInt();

    return AnimatedPress(
      onTap: perms.canContribute && !reached
          ? () => _showContributionDialog(context, goal, ref)
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
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          height: 1.02,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        t.savingsGoalTarget(targetAmount),
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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
                            style: TextStyle(
                              color: theme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (perms.canManage) _GoalMenu(goal: goal, reached: reached),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentAmount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: theme.textPrimary,
                          fontSize: 24,
                          height: 0.98,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.savingsGoalSavedOf(targetAmount),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (reached)
                  _CompletedBadge(
                    color: goalColor,
                    label: t.savingsCompletedBadge,
                  )
                else
                  Text(
                    '$progressPercent%',
                    style: TextStyle(
                      color: goalColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: goalColor.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation(goalColor),
                minHeight: 8,
              ),
            ),
            if (perms.canContribute && !reached) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.savingsGoalContributeAction,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            _ContributionHistory(goalId: goal.id),
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
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
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
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: theme.divider,
                      valueColor: AlwaysStoppedAnimation(goalColor),
                    ),
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
}

/// Split mode the contributor picks before adding money to a goal.
enum _ContributionSplit { solo, shared }
