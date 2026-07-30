import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/solo_progress_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_editorial_header.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_header_avatar.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_shopping_preview_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/solo_activity_tile.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/solo_bento_grid.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_completion_flow_mixin.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_feed_entry_motion.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';

/// Solo-mode home. Visually it leads with the user's day, not the household:
/// an editorial header (date eyebrow + time-of-day greeting + oversized name)
/// followed by a bento summary grid and the day's tasks/activity.
///
/// The header intentionally has NO task-count status line and the bento has
/// no "today" tile: the tasks section one glance below is the single source
/// of truth for the day's workload (three indicators of the same number was
/// pure redundancy).
class HomeSoloView extends ConsumerStatefulWidget {
  final Future<void> Function() onRefresh;
  final String householdId;
  final VoidCallback? onAvatarTap;

  const HomeSoloView({
    super.key,
    required this.onRefresh,
    required this.householdId,
    this.onAvatarTap,
  });

  @override
  ConsumerState<HomeSoloView> createState() => _HomeSoloViewState();
}

class _HomeSoloViewState extends ConsumerState<HomeSoloView>
    with TaskCompletionFlowMixin<HomeSoloView> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: theme.primary,
      edgeOffset: 20,
      child: ListView(
        // Se adjunta al PrimaryScrollController del tab (re-tap sube al tope).
        primary: true,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildBentoSummary(),
          const SizedBox(height: AppSpacing.lg),
          if (caps.showTasks)
            _buildTasksSection(theme)
          else
            const HomeShoppingPreviewCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 64),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;

    return HomeEditorialHeader(
      firstName: _firstName(currentMember?.displayName),
      trailing: HomeHeaderAvatar(
        name: currentMember?.displayName,
        avatarUrl: currentMember?.avatarUrl,
        onTap: widget.onAvatarTap,
        premiumOffset: const Offset(6, 2),
        premiumMaxWidth: 140,
        premiumMaxHeight: 140,
      ).animateScaleIn(delay: 70),
    );
  }

  String? _firstName(String? name) {
    if (name == null) return null;
    return name.trim().split(' ').first;
  }

  // ── Bento summary ───────────────────────────────────────────────────────

  Widget _buildBentoSummary() {
    final summaryAsync = ref.watch(personalFinanceSummaryProvider);
    final progress = ref.watch(soloProgressSnapshotProvider);

    final monthlySpent = summaryAsync.whenOrNull(
      data: (s) => (s['expense'] as num?)?.toDouble(),
    );

    return SoloBentoGrid(
      monthlySpent: monthlySpent,
      progress: progress,
      onSpentTap: () => _goToTab(MainTab.expenses),
    ).animateEntrance(delay: 120);
  }

  void _goToTab(MainTab tab) {
    final caps = ref.read(householdCapabilitiesProvider);
    final index = indexForMainTab(caps, tab);
    if (index >= 0) {
      ref.read(bottomNavIndexProvider.notifier).setIndex(index);
    }
  }

  // ── Tasks ───────────────────────────────────────────────────────────────

  Widget _buildTasksSection(AppThemeColors theme) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final t = AppLocalizations.of(context);
    final pendingCount = tasksAsync.whenOrNull(data: (tasks) => tasks.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t.homeSoloTasksTitle,
              style: AppTypography.sectionTitle.copyWith(
                color: theme.textPrimary,
              ),
            ),
            if (pendingCount != null && pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  '$pendingCount',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            TextButton(
              onPressed: () => _goToTab(MainTab.tasks),
              child: Text(
                t.homeViewWeekButton,
                style: AppTypography.bodyStrong.copyWith(
                  color: theme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(theme),
          error: (e, _) => Text(t.commonErrorWithDetails(e.toString())),
          data: (tasks) {
            if (tasks.isEmpty) {
              return _buildEmptyState(
                message: t.homeAllDoneToday,
                theme: theme,
                icon: Icons.task_alt_rounded,
                actionLabel: t.homeSoloAddTaskButton,
                onAction: () => _goToTab(MainTab.tasks),
              );
            }
            const taskPreviewLimit = 5;
            final visibleTasks =
                tasks.take(taskPreviewLimit).toList(growable: false);
            return Column(
              children: [
                for (var index = 0; index < visibleTasks.length; index++) ...[
                  if (index > 0) const SizedBox(height: 8),
                  _buildTaskCard(visibleTasks[index], theme)
                      .animateStaggered(index),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, AppThemeColors theme) {
    return DashboardTaskCard(
      task: task,
      isCompleting: completingTaskIds.contains(task.id),
      onTap: () => _completeTask(task),
    );
  }

  // Shared flow lives in TaskCompletionFlowMixin. The optimistic feed entry is
  // added centrally by Tasks.completeTask (with the server activity_id), so the
  // view must NOT add it again — that caused a duplicate row in the feed.
  Future<void> _completeTask(TaskModel task) => runTaskCompletion(task);

  // ── Activity ────────────────────────────────────────────────────────────

  Widget _buildActivitySection(AppThemeColors theme) {
    final activityAsync = ref.watch(recentActivityProvider);
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.homeSoloActivityTitle,
          style: AppTypography.sectionTitle.copyWith(
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        activityAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: AppLoader()),
          ),
          error: (e, _) => Text(t.commonErrorWithDetails(e.toString())),
          data: (activities) {
            if (activities.isEmpty) {
              return _buildEmptyState(
                message: t.homeNoActivityYet,
                theme: theme,
                icon: Icons.history_rounded,
                isQuiet: true,
              );
            }
            return Column(
              children: activities
                  .map(
                    (activity) => AppFeedEntryMotion(
                      key: ValueKey(_activityStableKey(activity)),
                      direction: AppFeedEntryDirection.fromRight,
                      distance: 18,
                      beginScale: 0.98,
                      child: SoloActivityTile(activity: activity),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  String _activityStableKey(Map<String, dynamic> activity) {
    final type = activity['type']?.toString() ?? 'unknown';
    // Prefer the REAL server activity id (optimistic rows carry it in
    // data['activity_id']) so the optimistic→real swap reuses the same widget
    // and the feed-entry animation does not replay. See HomeCoupleView for the
    // full rationale.
    final data = (activity['data'] as Map<String, dynamic>?) ?? {};
    final activityId = data['activity_id']?.toString();
    if (activityId != null && activityId.isNotEmpty) {
      return '$type-$activityId';
    }
    final id = activity['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return '$type-$id';
    }
    return [
      activity['created_at'],
      data['task_id'],
      data['expense_id'],
    ].whereType<Object>().join('-');
  }

  // ── Shared bits ─────────────────────────────────────────────────────────

  Widget _buildTasksShimmer(AppThemeColors theme) {
    return Column(
      children: List.generate(
        2,
        (_) => ShimmerLoading(
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String message,
    required AppThemeColors theme,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
    bool isQuiet = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18,
        vertical: isQuiet ? 18 : 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surfaceVariant.withValues(alpha: isQuiet ? 0.25 : 0.4),
            theme.surface.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: theme.border.withValues(alpha: isQuiet ? 0.18 : 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: isQuiet ? 40 : 52,
            height: isQuiet ? 40 : 52,
            decoration: BoxDecoration(
              color: isQuiet
                  ? theme.textMuted.withValues(alpha: 0.08)
                  : theme.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isQuiet
                  ? theme.textMuted.withValues(alpha: 0.68)
                  : theme.primary,
              size: isQuiet ? 19 : 25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyStrong.copyWith(
              color: theme.textPrimary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionLabel),
              style: TextButton.styleFrom(
                foregroundColor: theme.primary,
                backgroundColor: theme.primary.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                textStyle: AppTypography.bodyStrong,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
