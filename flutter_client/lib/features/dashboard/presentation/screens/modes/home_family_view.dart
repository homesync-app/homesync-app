import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_balance_card.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_chat_bubble.dart';
import 'package:homesync_client/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:homesync_client/features/household/presentation/widgets/invitation_sheet.dart';
import 'package:intl/intl.dart';

class HomeFamilyView extends ConsumerStatefulWidget {
  final Future<void> Function() onRefresh;
  final String householdId;
  final VoidCallback onAvatarTap;

  const HomeFamilyView({
    super.key,
    required this.onRefresh,
    required this.householdId,
    required this.onAvatarTap,
  });

  @override
  ConsumerState<HomeFamilyView> createState() => _HomeFamilyViewState();
}

class _HomeFamilyViewState extends ConsumerState<HomeFamilyView> {
  final Set<String> _completedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      backgroundColor: theme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildHeader(theme, caps),
          const SizedBox(height: 32),
          _buildFinanceSummary(theme, caps),
          const SizedBox(height: 32),
          _buildMembersSection(theme),
          const SizedBox(height: 32),
          _buildTasksSection(theme, caps),
          const SizedBox(height: 32),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme, HouseholdCapabilities caps) {
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${_firstName(currentMember?.displayName) ?? 'Familia'} \ud83d\udc4b',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMM', 'es_AR')
                  .format(DateTime.now())
                  ._capitalize(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationBadge(theme),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onAvatarTap,
              child: CustomUserAvatar(
                avatarUrl: currentMember?.avatarUrl,
                radius: 26,
                showBorder: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationBadge(AppThemeColors theme) {
    return AnimatedPress(
      onPressed: () {
        Navigator.push(
          context,
          AppTransitions.slideHorizontal(page: const NotificationsScreen()),
        );
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
              Icons.notifications_outlined,
              color: theme.textPrimary,
              size: 26,
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Integrantes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        membersAsync.when(
          data: (members) {
            return SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: members.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  if (index == members.length) {
                    return _buildAddMemberButton(theme);
                  }
                  final member = members[index];
                  return _buildMemberItem(member, theme);
                },
              ),
            );
          },
          loading: () => const ShimmerLoading(height: 80, borderRadius: 20),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMemberItem(dynamic member, AppThemeColors theme) {
    final firstName = member.displayName;

    return Column(
      children: [
        CustomUserAvatar(
          avatarUrl: member.avatarUrl,
          name: member.fullDisplayName,
          radius: 28,
          showBorder: true,
        ),
        const SizedBox(height: 8),
        Text(
          firstName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddMemberButton(AppThemeColors theme) {
    return Column(
      children: [
        AnimatedPress(
          onPressed: () {
            InvitationSheet.show(context);
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.divider.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: theme.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Invitar',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceSummary(
      AppThemeColors theme, HouseholdCapabilities caps) {
    final balancesAsync = ref.watch(expenseBalancesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Finanzas Familiares',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(2);
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        balancesAsync.when(
          data: (balances) {
            if (balances.isEmpty) return const SizedBox.shrink();

            // For family mode, we show a main summary or multiple cards
            return FamilyBalanceCard(
              balances: balances,
              title: caps.balanceMessage,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tareas del Hogar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(1);
              },
              child: const Text('Ver panel'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          data: (tasks) {
            final pending = tasks.where((t) => t.isPending).toList();
            if (pending.isEmpty) {
              return _buildEmptyState(theme, caps.emptyStateTasksSubtitle);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (pending.length > 3) ? 3 : pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = pending[index];
                return _buildTaskItem(task, theme);
              },
            );
          },
          loading: () => const ShimmerLoading(height: 60, borderRadius: 16),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTaskItem(TaskModel task, AppThemeColors theme) {
    return DashboardTaskCard(
      task: task,
      isCompleting: _completedTaskIds.contains(task.id),
      onTap: () => _completeTask(task),
    );
  }

  Future<void> _completeTask(dynamic task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).completeTask(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _completedTaskIds.remove(task.id));
    }
  }

  Widget _buildEmptyState(AppThemeColors theme, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
            Icons.task_alt_rounded,
            size: 48,
            color: theme.textSecondary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Todo al día!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(AppThemeColors theme) {
    final activitiesAsync = ref.watch(recentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) return const SizedBox.shrink();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (activities.length > 5) ? 5 : activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ActivityChatBubble(
                  activity: activities[index],
                  currentUserId: ref.read(currentUserIdProvider),
                );
              },
            );
          },
          loading: () => const ShimmerLoading(height: 70, borderRadius: 20),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String? _firstName(String? fullName) {
    if (fullName == null) return null;
    return fullName.trim().split(' ').first;
  }
}

extension _StringExtension on String {
  String _capitalize() {
    if (isEmpty) return this;
    final trimmed = trim();
    if (trimmed.isEmpty) return this;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }
}
