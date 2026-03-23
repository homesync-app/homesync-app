import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_balance_card.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

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
    final theme = Theme.of(context).extension<AppThemeColors>()!;
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
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember = members.where((m) => m.userId == currentUserId).firstOrNull;

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
              DateFormat('EEEE, d MMM', 'es_AR').format(DateTime.now())._capitalize(),
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
    final membersAsync = ref.watch(householdMembersProvider);

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
    return Column(
      children: [
        CustomUserAvatar(
          avatarUrl: member.avatarUrl,
          radius: 28,
          showBorder: true,
        ),
        const SizedBox(height: 8),
        Text(
          member.firstName ?? '?',
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
            // TODO: Mostrar invitación
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

  Widget _buildFinanceSummary(AppThemeColors theme, HouseholdCapabilities caps) {
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
              onPressed: () {},
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
              onPressed: () {},
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

  Widget _buildTaskItem(dynamic task, AppThemeColors theme) {
    final isCompleting = _completedTaskIds.contains(task.id);

    return AnimatedPress(
      onPressed: () => _completeTask(task),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: theme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getCategoryIcon(task.category), color: theme.primary.withValues(alpha: 0.6), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.category ?? 'Hogar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${task.xpReward} XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: isCompleting
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.check_rounded, size: 16, color: theme.primary),
            ),
          ],
        ),
      ),
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

  Widget _buildActivityItem(Map<String, dynamic> activity, AppThemeColors theme) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final data = activity['data'] as Map<String, dynamic>? ?? {};
    final creatorId = activity['creator_id'] as String?;
    final isMe = creatorId == currentUserId;
    final timestamp = activity['created_at'] != null ? DateTime.parse(activity['created_at'] as String) : DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CustomUserAvatar(
              avatarUrl: data['avatar_url'] ?? data['creator_avatar_url'],
              name: data['user_name'],
              radius: 18,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: theme.cardShadow,
                border: Border.all(
                  color: isMe ? theme.primary.withValues(alpha: 0.1) : theme.divider.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Icon(_getCategoryIcon(data['category'] as String?), size: 16, color: theme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['title'] ?? data['description'] ?? 'Realiz\u00f3 una acci\u00f3n',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: theme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(timestamp),
                        style: TextStyle(fontSize: 11, color: theme.textMuted, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      if (data['xp_reward'] != null)
                        _buildSmallPill(
                          label: '${data['xp_reward']} XP',
                          color: const Color(0xFFF97316),
                          icon: Icons.star_rounded,
                          theme: theme,
                        ),
                      const SizedBox(width: 6),
                      if (data['coins_reward'] != null)
                        _buildSmallPill(
                          label: '${data['coins_reward']} coins',
                          color: const Color(0xFF64748B),
                          icon: Icons.monetization_on_rounded,
                          theme: theme,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CustomUserAvatar(
              avatarUrl: data['avatar_url'] ?? data['creator_avatar_url'],
              name: data['user_name'],
              radius: 18,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallPill({required String label, required Color color, required IconData icon, required AppThemeColors theme}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'cocina': return Icons.restaurant_rounded;
      case 'limpieza': return Icons.cleaning_services_rounded;
      case 'compras': return Icons.shopping_cart_rounded;
      case 'finanzas': return Icons.payments_rounded;
      default: return Icons.task_alt_rounded;
    }
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
