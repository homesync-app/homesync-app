import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_chat_bubble.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_shopping_preview_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class HomeSoloView extends ConsumerStatefulWidget {
  final Future<void> Function() onRefresh;
  final String householdId;

  const HomeSoloView({
    super.key,
    required this.onRefresh,
    required this.householdId,
  });

  @override
  ConsumerState<HomeSoloView> createState() => _HomeSoloViewState();
}

class _HomeSoloViewState extends ConsumerState<HomeSoloView> {
  final Set<String> _completedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: theme.primary,
      edgeOffset: 20,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.md),
          _buildFinancialSummary(widget.householdId),
          const SizedBox(height: 24),
          if (caps.showTasks)
            _buildTasksSection(theme)
          else
            const HomeShoppingPreviewCard(),
          const SizedBox(height: 24),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 64),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                _buildWelcomeGreetingSpan(
                  theme: theme,
                  currentMemberName: currentMember?.displayName,
                ),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ).animateEntrance(),
            ),
            const SizedBox(width: AppSpacing.sm),
            CustomUserAvatar(
              name: currentMember?.displayName,
              avatarUrl: currentMember?.avatarUrl,
              radius: 24,
            ).animateScaleIn(delay: 70),
          ],
        ),
        const SizedBox(height: 12),
        _buildHomeWelcome(theme: theme),
      ],
    );
  }

  Widget _buildHomeWelcome({required AppThemeColors theme}) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.homeHeadlinePrimary,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ).animate().fadeIn(delay: 100.ms),
        Text(
          t.homeSoloHeadlineSecondary,
          style: TextStyle(
            color: theme.textPrimary.withValues(alpha: 0.7),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 24,
              height: 1.5,
              color: theme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              t.homeSoloFocusToday,
              style: TextStyle(color: theme.textSecondary, fontSize: 13.5),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
  }) {
    final t = AppLocalizations.of(context);
    final firstName = _firstName(currentMemberName);
    final welcome = firstName != null
        ? (_looksFeminineName(firstName)
            ? t.homeWelcomeFeminine
            : t.homeWelcomeMasculine)
        : t.homeWelcomeMasculine;

    return TextSpan(
      children: [
        TextSpan(
          text: '$welcome, ',
          style: TextStyle(color: theme.textPrimary),
        ),
        TextSpan(
          text: firstName ?? t.commonUserFallback,
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  bool _looksFeminineName(String name) {
    final normalized = name.trim().toLowerCase();
    const masculineExceptions = {'blas', 'luca', 'noa', 'andrea'};
    if (masculineExceptions.contains(normalized)) return false;
    return normalized.endsWith('a');
  }

  String? _firstName(String? name) {
    if (name == null) return null;
    return name.trim().split(' ').first;
  }

  Widget _buildFinancialSummary(String householdId) {
    final balanceAsync = ref.watch(userBalanceProvider);

    return BalanceCard(
      coins: balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0,
      xp: balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0,
      userBalance: 0.0, // In solo mode we don't show internal debt
      balancedLabel: AppLocalizations.of(context).homeSoloBalanceLabel,
      neutralLabel: AppLocalizations.of(context).homeSoloBalanceLabel,
      compact: true,
    ).animateEntrance(delay: 100);
  }

  Widget _buildTasksSection(AppThemeColors theme) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.homeSoloTasksTitle,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: 0,
              ),
            ),
            TextButton(
              onPressed: () {
                final index = indexForMainTab(caps, MainTab.tasks);
                if (index >= 0) {
                  ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                }
              },
              child: Text(
                t.homeViewWeekButton,
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
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
                onAction: () {
                  final index = indexForMainTab(caps, MainTab.tasks);
                  if (index >= 0) {
                    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                  }
                },
              );
            }
            final myTasks = tasks.toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _buildTaskCard(myTasks[index], theme),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, AppThemeColors theme) {
    return DashboardTaskCard(
      task: task,
      isCompleting: _completedTaskIds.contains(task.id),
      onTap: () => _completeTask(task),
    );
  }

  Future<void> _completeTask(TaskModel task) async {
    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).completeTask(task);
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.commonErrorWithDetails(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _completedTaskIds.remove(task.id));
    }
  }

  Widget _buildActivitySection(AppThemeColors theme) {
    final activityAsync = ref.watch(recentActivityProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.homeSoloActivityTitle,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: theme.textPrimary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
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
                    (a) => ActivityChatBubble(
                      activity: a,
                      currentUserId: currentUserId,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTasksShimmer(AppThemeColors theme) {
    return Column(
      children: List.generate(
        2,
        (_) => ShimmerLoading(
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(20),
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
        vertical: isQuiet ? 18 : 22,
      ),
      decoration: BoxDecoration(
        color: isQuiet
            ? theme.surface.withValues(alpha: 0.42)
            : theme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.border.withValues(alpha: isQuiet ? 0.18 : 0.34),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isQuiet
                ? theme.textMuted.withValues(alpha: 0.68)
                : theme.primary,
            size: isQuiet ? 24 : 30,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
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
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
