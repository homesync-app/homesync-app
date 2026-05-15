import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_chat_bubble.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_task_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';

class HomeFriendsView extends ConsumerStatefulWidget {
  final Future<void> Function() onRefresh;
  final String householdId;
  final VoidCallback onAvatarTap;

  const HomeFriendsView({
    super.key,
    required this.onRefresh,
    required this.householdId,
    required this.onAvatarTap,
  });

  @override
  ConsumerState<HomeFriendsView> createState() => _HomeFriendsViewState();
}

class _HomeFriendsViewState extends ConsumerState<HomeFriendsView> {
  final Set<String> _completedTaskIds = {};
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null || userId.isEmpty) return;

      final data = await ref
          .read(supabaseClientProvider)
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      final count = (data as List).length;
      if (mounted && count != _unreadNotificationCount) {
        setState(() => _unreadNotificationCount = count);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    final tasksAsync = ref.watch(todayTasksProvider);
    final shoppingAsync = ref.watch(shoppingItemsProvider);

    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final members = membersAsync.value ?? const <MemberModel>[];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final membersLoaded = membersAsync.hasValue && !membersAsync.isLoading;
    final memberNotFound = membersLoaded && currentMember == null;
    final hasTasksContent = tasksAsync.isLoading ||
        ((tasksAsync.value ?? const <TaskModel>[])
            .where((task) => task.isPending)
            .isNotEmpty);
    final hasShoppingContent = shoppingAsync.isLoading ||
        ((shoppingAsync.value ?? const [])
            .where((item) => !item.completed)
            .isNotEmpty);

    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh();
        _loadUnreadNotificationCount();
      },
      color: AppColors.primary,
      backgroundColor: theme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildHeader(theme, caps),
          if (memberNotFound) ...[
            const SizedBox(height: 16),
            _buildMemberNotFoundBanner(theme),
          ],
          const SizedBox(height: 22),
          _buildFinanceSummary(theme),
          if (caps.showTasks && hasTasksContent) ...[
            const SizedBox(height: 32),
            _buildTasksSection(theme, caps),
          ],
          if (hasShoppingContent) ...[
            const SizedBox(height: 32),
            _buildShoppingSection(theme),
          ],
          const SizedBox(height: 32),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme, HouseholdCapabilities caps) {
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final t = AppLocalizations.of(context);

    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final firstName = _firstName(currentMember?.displayName);
    final greeting = firstName == null
        ? _greetingByTime(t)
        : '${_greetingByTime(t)}, $firstName';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: widget.onAvatarTap,
          child: Hero(
            tag: 'user_avatar_main',
            child: CustomUserAvatar(
              avatarUrl: currentMember?.avatarUrl,
              radius: 26,
              showBorder: true,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.homeFriendsHeaderSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildNotificationBadge(theme),
      ],
    );
  }

  Widget _buildNotificationBadge(AppThemeColors theme) {
    return AnimatedPress(
      onPressed: () async {
        await Navigator.push(
          context,
          AppTransitions.slideHorizontal(page: const NotificationsScreen()),
        );
        _loadUnreadNotificationCount();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Icon(
              _unreadNotificationCount > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_outlined,
              color: _unreadNotificationCount > 0
                  ? AppColors.primary
                  : theme.textPrimary,
              size: 26,
            ),
            if (_unreadNotificationCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      _unreadNotificationCount > 9
                          ? '9+'
                          : '$_unreadNotificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberNotFoundBanner(AppThemeColors theme) {
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.homeFriendsMemberNotFound,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              ref.invalidate(householdMembersProvider);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(t.commonRetry, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSummary(AppThemeColors theme) {
    final balancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          title: t.homeFriendsBalancesTitle,
          subtitle: '',
        ),
        const SizedBox(height: 12),
        balancesAsync.when(
          data: (balances) {
            if (balances.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.surfaceContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.divider.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 40,
                      color: AppColors.accentTeal.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.homeFriendsBalancesEmptyTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.homeFriendsBalancesEmptyBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              );
            }
            return FamilyBalanceCard(
              balances: balances,
              title: t.homeFriendsBalanceCardTitle,
              currentUserId: currentUserId,
            );
          },
          loading: () => const ShimmerLoading(height: 140, borderRadius: 24),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTasksSection(AppThemeColors theme, HouseholdCapabilities caps) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final members = membersAsync.value ?? const <MemberModel>[];
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          title: t.homeFriendsTasksTitle,
          subtitle: t.homeFriendsTasksSubtitle,
          actionLabel: t.homeViewAllButton,
          onAction: () {
            final index = indexForMainTab(caps, MainTab.tasks);
            if (index >= 0) {
              ref.read(bottomNavIndexProvider.notifier).setIndex(index);
            }
          },
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          data: (tasks) {
            final pending = tasks.where((t) => t.isPending).toList();
            if (pending.isEmpty) {
              return const SizedBox.shrink();
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (pending.length > 3) ? 3 : pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = pending[index];
                return _buildTaskItem(task, theme, members);
              },
            );
          },
          loading: () => const ShimmerLoading(height: 60, borderRadius: 16),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTaskItem(
    TaskModel task,
    AppThemeColors theme,
    List<MemberModel> members,
  ) {
    final assignedMember =
        members.where((m) => m.userId == task.assignedTo).firstOrNull;

    if (assignedMember != null) {
      return FamilyTaskCard(
        task: task,
        isCompleting: _completedTaskIds.contains(task.id),
        isChildView: false,
        actionIcon: Icons.check_rounded,
        assignedMember: assignedMember,
        currentUserId: ref.watch(currentUserIdProvider),
        onTap: () => _completeTask(task),
      );
    }

    return DashboardTaskCard(
      task: task,
      isCompleting: _completedTaskIds.contains(task.id),
      onTap: () => _completeTask(task),
    );
  }

  Future<void> _completeTask(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      log.d('[friends] completing task id=${task.id} title=${task.title}');
      await Future<void>.delayed(const Duration(milliseconds: 360));
      final result = await ref.read(tasksProvider.notifier).completeTask(task);

      if (!mounted) return;

      if (result == null) {
        log.w('[friends] task completion returned null id=${task.id}');
        final t = AppLocalizations.of(context);
        AppSnackBar.show(
          context,
          message: t.homeFriendsTaskCompleteError,
          type: AppSnackBarType.error,
        );
        return;
      }

      log.i(
        '[friends] task completion success id=${task.id} queued=${result.queued}',
      );
      ref
          .read(optimisticRecentActivityProvider.notifier)
          .addTaskCompleted(task);
      HapticFeedback.mediumImpact();
      final t = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: t.tasksSnackCompleted,
        type: AppSnackBarType.success,
      );
      ref.invalidate(statsControllerProvider);
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      log.e('[friends] task completion threw id=${task.id}', error: e);
      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.show(
          context,
          message: t.commonErrorWithDetails(e.toString()),
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Widget _buildShoppingSection(AppThemeColors theme) {
    final shoppingAsync = ref.watch(shoppingItemsProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          title: t.homeFriendsShoppingTitle,
          subtitle: t.homeFriendsShoppingSubtitle,
          actionLabel: t.homeViewListButton,
          onAction: () {
            final index = indexForMainTab(caps, MainTab.shopping);
            if (index >= 0) {
              ref.read(bottomNavIndexProvider.notifier).setIndex(index);
            }
          },
        ),
        const SizedBox(height: 12),
        shoppingAsync.when(
          data: (items) {
            final pending = items.where((i) => !i.completed).toList();
            if (pending.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              decoration: BoxDecoration(
                color: theme.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.divider.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: pending.take(2).toList().asMap().entries.map((entry) {
                  final item = entry.value;
                  final isLast = entry.key == pending.take(2).length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                        subtitle: item.quantity != null
                            ? Text('${item.quantity} ${item.unit ?? ''}')
                            : null,
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: theme.textMuted,
                          size: 20,
                        ),
                        onTap: () {
                          final index = indexForMainTab(caps, MainTab.shopping);
                          if (index >= 0) {
                            ref
                                .read(bottomNavIndexProvider.notifier)
                                .setIndex(index);
                          }
                        },
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: theme.divider.withValues(alpha: 0.08),
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const ShimmerLoading(height: 60, borderRadius: 20),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildActivitySection(AppThemeColors theme) {
    final activitiesAsync = ref.watch(recentActivityProvider);
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          title: t.homeFriendsActivityTitle,
          subtitle: t.homeFriendsActivitySubtitle,
        ),
        const SizedBox(height: 16),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surfaceContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.divider.withValues(alpha: 0.05),
                  ),
                ),
                child: Text(
                  t.homeFriendsActivityEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textSecondary,
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (activities.length > 5) ? 5 : activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityItem(activity, theme);
              },
            );
          },
          loading: () => const ShimmerLoading(height: 70, borderRadius: 20),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    AppThemeColors theme,
  ) {
    final activityMap = activity;
    final currentUserId = ref.watch(currentUserIdProvider);
    return ActivityChatBubble(
      activity: activityMap,
      currentUserId: currentUserId,
    );
  }

  Widget _buildSectionHeader(
    AppThemeColors theme, {
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.35,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
          ],
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: theme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  String _greetingByTime(AppLocalizations t) {
    final hour = DateTime.now().hour;
    if (hour < 12) return t.commonGreetingMorning;
    if (hour < 19) return t.commonGreetingAfternoon;
    return t.commonGreetingEvening;
  }

  String? _firstName(String? fullName) {
    final trimmed = fullName?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.split(' ').first;
  }
}
