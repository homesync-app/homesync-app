import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:homesync_client/features/rewards/presentation/screens/family_rewards_screen.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
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
    final statsAsync = ref.watch(statsControllerProvider);

    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChild = currentMember?.isChild ?? false;
    final adultCount = members.where((member) => member.isAdult).length;
    final showFinance = !isChild && adultCount > 1;

    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh();
        await ref.read(statsControllerProvider.notifier).refresh();
      },
      color: AppColors.primary,
      backgroundColor: theme.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildHeader(theme, caps),
          const SizedBox(height: 24),
          if (isChild) ...[
            _buildChildWallet(theme),
            const SizedBox(height: 24),
          ],
          _buildWeeklySummaryBlock(theme, statsAsync.valueOrNull),
          const SizedBox(height: 24),
          _buildWeeklyRankingBlock(theme, statsAsync.valueOrNull),
          const SizedBox(height: 32),
          _buildTasksSection(theme, caps),
          const SizedBox(height: 32),
          _buildShoppingSection(theme),
          const SizedBox(height: 32),
          if (showFinance) ...[
            _buildFinanceSummary(theme, caps),
            const SizedBox(height: 32),
          ],
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

  Widget _buildWeeklySummaryBlock(AppThemeColors theme, StatsData? stats) {
    if (stats == null) {
      return _buildStatsPlaceholder(
        theme,
        title: 'Esta semana en el hogar',
        subtitle: 'Todavia no tenemos suficiente actividad para armar el resumen.',
        icon: Icons.insights_rounded,
      );
    }

    final completedTasks = stats.taskStats.fold(0, (sum, cat) => sum + (cat['count'] as int? ?? 0));
    final totalCoins = stats.weeklyRanking.fold(0, (sum, member) => sum + (member['coins'] as int? ?? 0));
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withValues(alpha: 0.15),
            theme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Esta semana en el hogar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                ),
              ),
              Icon(Icons.auto_awesome_rounded, color: theme.primary, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                theme,
                label: 'Puntos totales',
                value: totalCoins.toString(),
                icon: Icons.stars_rounded,
                color: AppColors.accentGold,
              ),
              _buildSummaryDivider(theme),
              _buildSummaryItem(
                theme,
                label: 'Tareas cerradas',
                value: completedTasks.toString(),
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              _buildSummaryDivider(theme),
              _buildSummaryItem(
                theme,
                label: 'Estado',
                value: completedTasks > 5 ? 'Activo' : 'Calma',
                icon: Icons.flash_on_rounded,
                color: AppColors.accentOrange,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummaryItem(
    AppThemeColors theme, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDivider(AppThemeColors theme) {
    return Container(
      width: 1,
      height: 24,
      color: theme.divider.withValues(alpha: 0.1),
    );
  }

  Widget _buildWeeklyRankingBlock(AppThemeColors theme, StatsData? stats) {
    if (stats == null) {
      return _buildStatsPlaceholder(
        theme,
        title: 'Ranking semanal',
        subtitle:
            'Cuando empiecen a cerrar tareas, el ranking va a aparecer acÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡.',
        icon: Icons.emoji_events_outlined,
      );
    }
    
    final ranking = stats.weeklyRanking;
    if (ranking.isEmpty) {
      return _buildPlaceholderRanking(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranking Semanal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.surfaceContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: ranking.take(3).map((item) {
              final isFirst = ranking.indexOf(item) == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isFirst ? AppColors.accentGold : theme.divider.withValues(alpha: 0.1),
                      child: Text(
                        (ranking.indexOf(item) + 1).toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFirst ? Colors.black : theme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item['display_name'] ?? 'Integrante',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isFirst ? FontWeight.w800 : FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item['coins'] ?? 0} pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: theme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderRanking(AppThemeColors theme) {
    return _buildStatsPlaceholder(
      theme,
      title: 'Comienza el ranking de la semana',
      subtitle: 'Suma puntos completando tus tareas.',
      icon: Icons.emoji_events_outlined,
    );
  }

  Widget _buildStatsPlaceholder(
    AppThemeColors theme, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.textMuted, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSummary(AppThemeColors theme, HouseholdCapabilities caps) {
    final balancesAsync = ref.watch(expenseBalancesProvider);
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final members = membersAsync.valueOrNull ?? [];
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember = members.where((m) => m.userId == currentUserId).firstOrNull;
    
    // Check if current user is child ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â Phase 2 requirement
    final isChild = currentMember?.isChild ?? false;
    
    // Hide finance section if current user is child (Phase 2) 
    // OR if there's only one adult in the household (Phase 1)
    final adultCount = members.where((m) => m.isAdult).length;
    
    if (isChild || adultCount <= 1) return const SizedBox.shrink();

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
    final tasksAsync = ref.watch(tasksProvider);

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
            final pending = tasks.where((task) => task.isPending).toList()
              ..sort((a, b) {
                if (a.isOverdue != b.isOverdue) {
                  return a.isOverdue ? -1 : 1;
                }
                if (a.isDueToday != b.isDueToday) {
                  return a.isDueToday ? -1 : 1;
                }
                return a.createdAt.compareTo(b.createdAt);
              });
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

  Future<void> _completeTask(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      debugPrint('[family] completing task id=${task.id} title=${task.title}');
      final result = await ref.read(tasksProvider.notifier).completeTask(task);

      if (!mounted) return;

      if (result == null) {
        debugPrint('[family] task completion returned null id=${task.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos completar la tarea. Intenta de nuevo.'),
          ),
        );
        return;
      }

      debugPrint(
        '[family] task completion success id=${task.id} queued=${result.queued} message=${result.message}',
      );
      ref.invalidate(statsControllerProvider);
      ref.invalidate(tasksProvider);
    } catch (e) {
      debugPrint('[family] task completion threw id=${task.id} error=$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
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
            'Todo al día',
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

  Widget _buildShoppingSection(AppThemeColors theme) {
    final shoppingAsync = ref.watch(shoppingItemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Compras del hogar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(5);
              },
              child: const Text('Ver lista'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        shoppingAsync.when(
          data: (items) {
            final pending = items.where((item) => !item.completed).toList();
            if (pending.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surfaceContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'No hay compras pendientes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textSecondary,
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: theme.surfaceContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: pending.take(3).map((item) {
                  final quantityLabel = item.quantity != null
                      ? '${item.quantity} ${item.unit ?? ''}'.trim()
                      : null;

                  return ListTile(
                    leading: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                    ),
                    subtitle: quantityLabel != null && quantityLabel.isNotEmpty
                        ? Text(quantityLabel)
                        : null,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.textMuted,
                      size: 20,
                    ),
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).setIndex(5);
                    },
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

  Widget _buildChildWallet(AppThemeColors theme) {
    final balance = ref.watch(userBalanceProvider).value?['coins'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.accentGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi Monedero',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '$balance monedas',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                AppTransitions.slideHorizontal(
                  page: const FamilyRewardsScreen(),
                ),
              );
            },
            child: const Text('Tienda'),
          ),
        ],
      ),
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
