import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/domain/models/solo_progress_snapshot.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/solo_progress_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class SoloSpaceScreen extends ConsumerWidget {
  const SoloSpaceScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(soloProgressServerSnapshotProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(recentActivityRemoteProvider);
    ref.invalidate(statsControllerProvider);
    ref.invalidate(tasksProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final snapshot = ref.watch(soloProgressSnapshotProvider);
    final ritualSteps = ref.watch(soloWeeklyRitualProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.primary,
          onRefresh: () => _refresh(ref),
          child: ListView(
            // PrimaryScrollController del tab (re-tap sube al tope).
            primary: true,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              132,
            ),
            children: [
              _StageHero(snapshot: snapshot),
              const SizedBox(height: AppSpacing.md),
              _NextActionCard(
                snapshot: snapshot,
                onTap: () => _goToTab(ref, snapshot.nextActionTargetTab),
              ),
              const SizedBox(height: AppSpacing.md),
              _WeeklySignalsCard(snapshot: snapshot),
              const SizedBox(height: AppSpacing.md),
              _WeeklyRitualCard(
                completedSteps: ritualSteps,
                onToggle: (step) => _toggleRitualStep(ref, step),
              ),
              const SizedBox(height: AppSpacing.md),
              _InsightPreview(snapshot: snapshot),
              const SizedBox(height: AppSpacing.md),
              _MilestonesPreview(snapshot: snapshot),
            ],
          ),
        ),
      ),
    );
  }

  void _goToTab(WidgetRef ref, MainTab tab) {
    final caps = ref.read(householdCapabilitiesProvider);
    final index = indexForMainTab(caps, tab);
    if (index >= 0) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(index);
    }
  }

  void _toggleRitualStep(WidgetRef ref, SoloWeeklyRitualStep step) {
    final current = ref.read(soloWeeklyRitualProvider);
    final next = {...current};
    if (next.contains(step)) {
      next.remove(step);
    } else {
      next.add(step);
    }
    ref.read(soloWeeklyRitualProvider.notifier).state = next;
  }
}

class _StageHero extends StatelessWidget {
  const _StageHero({required this.snapshot});

  final SoloProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.heroGradient,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: theme.border.withValues(alpha: 0.48)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.soloSpaceEyebrow.toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(
                        fontSize: 10.5,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.stageName(t),
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 24,
                        fontWeight: AppTypography.hero,
                        letterSpacing: AppTypography.heroLetterSpacing,
                        height: 1.06,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _LevelPill(snapshot: snapshot),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            snapshot.stageSubtitle(t),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              height: 1.3,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: snapshot.levelProgress.clamp(0.0, 1.0),
              backgroundColor: theme.surface.withValues(alpha: 0.62),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.soloSpaceXpToNext(snapshot.xpToNextLevel),
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ScorePill(
                  title: t.soloSpaceOrderTitle,
                  score: snapshot.orderScore,
                  color: AppColors.sage,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ScorePill(
                  title: t.soloSpaceClarityTitle,
                  score: snapshot.clarityScore,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ScorePill(
                  title: t.soloSpaceContinuityTitle,
                  score: snapshot.continuityScore,
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.snapshot});

  final SoloProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
      ),
      child: Text(
        t.soloSpaceLevel(snapshot.level),
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.textPrimary,
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({
    required this.title,
    required this.score,
    required this.color,
  });

  final String title;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.border.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$score%',
            style: AppTypography.cardTitle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({
    required this.snapshot,
    required this.onTap,
  });

  final SoloProgressSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: theme.primary.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.soloSpaceNextTitle.toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(
                        fontSize: 10.5,
                        color: theme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.nextActionTitle(t),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      snapshot.nextActionSubtitle(t),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 12.5,
                        height: 1.25,
                        color: theme.textSecondary,
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

class _WeeklySignalsCard extends StatelessWidget {
  const _WeeklySignalsCard({required this.snapshot});

  final SoloProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return _SectionCard(
      title: t.soloSpaceSignalsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.local_fire_department_rounded,
                  label: t.soloSpaceStreakTitle,
                  value: t.soloSpaceStreakMetric(snapshot.currentStreakDays),
                  color: AppColors.accentOrange,
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.bolt_rounded,
                  label: t.soloSpaceWeeklyXpTitle,
                  value: '${snapshot.weeklyXp}',
                  color: AppColors.accentGold,
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.done_all_rounded,
                  label: t.soloSpaceWeeklyTasksTitle,
                  value: '${snapshot.weeklyTasksCompleted}',
                  color: AppColors.sage,
                ),
              ),
            ],
          ),
          if (!snapshot.hasServerSnapshot) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.soloSpaceSignalsSyncing,
              style: AppTypography.caption.copyWith(
                fontSize: 11.5,
                height: 1.25,
                color: theme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: theme.textMuted,
          ),
        ),
      ],
    );
  }
}

class _WeeklyRitualCard extends StatelessWidget {
  const _WeeklyRitualCard({
    required this.completedSteps,
    required this.onToggle,
  });

  final Set<SoloWeeklyRitualStep> completedSteps;
  final ValueChanged<SoloWeeklyRitualStep> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final total = SoloWeeklyRitualStep.values.length;
    final progress = completedSteps.length / total;

    return _SectionCard(
      title: t.soloSpaceRitualTitle,
      trailing: Text(
        t.soloSpaceRitualProgress(completedSteps.length, total),
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.textSecondary,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: theme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final step in SoloWeeklyRitualStep.values)
                    SizedBox(
                      width: itemWidth,
                      child: _RitualStepChip(
                        step: step,
                        checked: completedSteps.contains(step),
                        onTap: () => onToggle(step),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RitualStepChip extends StatelessWidget {
  const _RitualStepChip({
    required this.step,
    required this.checked,
    required this.onTap,
  });

  final SoloWeeklyRitualStep step;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: checked
                ? theme.primary.withValues(alpha: 0.06)
                : theme.surfaceContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: checked
                  ? theme.primary.withValues(alpha: 0.14)
                  : theme.border.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Icon(
                checked ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: checked ? theme.primary : theme.textMuted,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  step.title(t),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: checked ? theme.textPrimary : theme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightPreview extends StatelessWidget {
  const _InsightPreview({required this.snapshot});

  final SoloProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.insights.isEmpty) return const SizedBox.shrink();

    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final insight = snapshot.insights.first;

    return _SectionCard(
      title: t.soloSpaceInsightsTitle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.insights_rounded, color: theme.primary, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title(t),
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  insight.description(t, snapshot),
                  style: AppTypography.caption.copyWith(
                    fontSize: 12.5,
                    height: 1.3,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestonesPreview extends StatelessWidget {
  const _MilestonesPreview({required this.snapshot});

  final SoloProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final unlocked = snapshot.milestones.toSet();

    return _SectionCard(
      title: t.soloSpaceMilestonesTitle,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final milestone in SoloProgressMilestone.values)
            _MilestoneChip(
              label: milestone.title(t),
              unlocked: unlocked.contains(milestone),
            ),
        ],
      ),
    );
  }
}

class _MilestoneChip extends StatelessWidget {
  const _MilestoneChip({
    required this.label,
    required this.unlocked,
  });

  final String label;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = unlocked ? AppColors.sage : theme.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: unlocked
            ? AppColors.sage.withValues(alpha: 0.07)
            : theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: unlocked
              ? AppColors.sage.withValues(alpha: 0.16)
              : theme.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.radio_button_off,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: unlocked ? theme.textPrimary : theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.border.withValues(alpha: 0.42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
