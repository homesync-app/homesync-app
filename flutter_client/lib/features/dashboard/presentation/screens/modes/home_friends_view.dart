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
          _buildMembersSection(theme),
          const SizedBox(height: 32),
          _buildFinanceSummary(theme, caps),
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
                '¡Qué onda amigos!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.textSecondary,
                ),
              ),
              Text(
                'Mi Piso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                  letterSpacing: -0.5,
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
      onPressed: () {
        // TODO: Navegar a notificaciones
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
          'Integrantes del grupo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Este listado refleja solo el escenario QA activo.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        membersAsync.when(
          data: (members) {
            if (members.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surfaceContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Todavía no hay integrantes en este grupo.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
              );
            }

            return SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final member = members[index];
                  return _buildMemberItem(member, theme);
                },
              ),
            );
          },
          loading: () => const ShimmerLoading(height: 90, borderRadius: 24),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMemberItem(dynamic member, AppThemeColors theme) {
    final displayRole =
        (member.displayRole as String?)?.trim().isNotEmpty == true
            ? member.displayRole as String
            : member.role;
    final firstName = member.displayName;

    return SizedBox(
      width: 84,
      child: Column(
        children: [
          CustomUserAvatar(
            avatarUrl: member.avatarUrl,
            name: member.displayName,
            radius: 28,
            showBorder: true,
          ),
          const SizedBox(height: 8),
          Text(
            firstName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayRole ?? 'Miembro',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
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
              'Gastos Compartidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Cuentas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        balancesAsync.when(
          data: (balances) {
            if (balances.isEmpty) return const SizedBox.shrink();
            return FamilyBalanceCard(
              balances: balances,
              title: 'Balances de convivencia',
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
              'Tareas del piso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todas'),
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
            '¡Todo limpio!',
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
          'Actividad del Piso',
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

  Widget _buildActivityItem(dynamic activity, AppThemeColors theme) {
    // Convert legacy typed object to Map if needed, or use ActivityChatBubble directly
    final activityMap = activity is Map<String, dynamic>
        ? activity
        : <String, dynamic>{
            'creator_id': activity.userId,
            'created_at': activity.timestamp?.toIso8601String(),
            'data': <String, dynamic>{
              'title': activity.description,
              'user_name': activity.userName,
              'avatar_url': activity.avatarUrl,
            },
          };
    final currentUserId = ref.watch(currentUserIdProvider);
    return ActivityChatBubble(
        activity: activityMap, currentUserId: currentUserId);
  }
}
