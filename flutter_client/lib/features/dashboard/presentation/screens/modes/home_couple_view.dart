import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

class HomeCoupleView extends ConsumerStatefulWidget {
  final Future<void> Function() onRefresh;
  final String householdId;
  final VoidCallback onAvatarTap;

  const HomeCoupleView({
    super.key,
    required this.onRefresh,
    required this.householdId,
    required this.onAvatarTap,
  });

  @override
  ConsumerState<HomeCoupleView> createState() => _HomeCoupleViewState();
}

class _HomeCoupleViewState extends ConsumerState<HomeCoupleView> {
  final Set<String> _completedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: theme.primary,
      edgeOffset: 20,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildFinancialSummary(widget.householdId),
          const SizedBox(height: 32),
          _buildTasksSection(theme),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember = members.where((m) => m.userId == currentUserId).firstOrNull;
    final partnerMember = members.where((m) => m.userId != currentUserId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    _buildWelcomeGreetingSpan(
                      theme: theme,
                      currentMemberName: currentMember?.displayName,
                    ),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ).animateEntrance(),
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
            ),
            const SizedBox(width: AppSpacing.md),
            _buildProfileAvatar(currentMember).animateScaleIn(delay: 70),
          ],
        ),
        const SizedBox(height: 24),
        _buildHomeWelcome(theme: theme, partnerMember: partnerMember),
      ],
    );
  }

  Widget _buildHomeWelcome({
    required AppThemeColors theme,
    required dynamic partnerMember,
  }) {
    final partnerFirstName = _firstName(partnerMember?.displayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Todo lo importante',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.55,
          ),
        ).animate().fadeIn(delay: 100.ms),
        Text(
          'del hogar',
          style: TextStyle(
            color: theme.textPrimary.withValues(alpha: 0.7),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(width: 24, height: 1.5, color: theme.primary.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Text('con ', style: TextStyle(color: theme.textSecondary, fontSize: 14)),
            Text(partnerFirstName ?? 'tu pareja', 
              style: TextStyle(color: theme.primary, fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(width: 4),
            const Icon(Icons.favorite_rounded, size: 12, color: AppColors.accentOrange),
          ],
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  String? _firstName(String? fullName) {
    if (fullName == null) return null;
    return fullName.split(' ').first;
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
  }) {
    final firstName = _firstName(currentMemberName);
    final welcome = firstName != null ? (_looksFeminineName(firstName) ? 'Bienvenida' : 'Bienvenido') : 'Bienvenido';
    
    return TextSpan(
      children: [
        TextSpan(text: '$welcome, ', style: TextStyle(color: theme.textPrimary)),
        TextSpan(text: firstName ?? 'Usuario', style: TextStyle(color: theme.primary, fontWeight: FontWeight.w900)),
      ],
    );
  }

  bool _looksFeminineName(String name) {
    final normalized = name.trim().toLowerCase();
    const masculineExceptions = {'blas', 'luca', 'noa', 'andrea'};
    if (masculineExceptions.contains(normalized)) return false;
    return normalized.endsWith('a');
  }

  Widget _buildProfileAvatar(dynamic member) {
    return AnimatedPress(
      onTap: widget.onAvatarTap,
      child: CustomUserAvatar(name: member?.displayName, avatarUrl: member?.avatarUrl, radius: 26),
    );
  }


  Widget _buildFinancialSummary(String householdId) {
    final balanceAsync = ref.watch(userBalanceProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final expenseBalancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    double myExpenseBalance = 0;
    expenseBalancesAsync.whenData((balances) {
      final myBalanceModel = balances.where((b) => b.userId == currentUserId).firstOrNull;
      if (myBalanceModel != null) myExpenseBalance = myBalanceModel.balance;
    });

    final partner = membersAsync.whenOrNull(
      data: (members) => members.where((m) => m.userId != currentUserId).firstOrNull,
    );

    return BalanceCard(
      coins: balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0,
      xp: balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0,
      userBalance: myExpenseBalance,
      partnerName: partner?.displayName,
      onSettle: partner != null && myExpenseBalance.abs() > 10.0
          ? () => _showSettlementDialog(
                householdId: householdId,
                partnerId: partner.userId,
                partnerName: partner.displayName,
                amount: myExpenseBalance.abs(),
                isOwedByMe: myExpenseBalance < 0,
              )
          : null,
    ).animateEntrance(delay: 100);
  }

  Widget _buildTasksSection(AppThemeColors theme) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Hoy en casa', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.textPrimary, letterSpacing: -0.7)),
            TextButton(
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).setIndex(1),
              child: Text('Ver Semana', style: TextStyle(color: theme.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(theme),
          error: (e, _) => Text('Error: $e'),
          data: (tasks) {
            if (tasks.isEmpty) return _buildEmptyState('Todo listo por hoy', theme);
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _buildTaskCard(tasks.elementAt(index), theme),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, AppThemeColors theme) {
    final isCompleting = _completedTaskIds.contains(task.id);
    return AnimatedPress(
      onTap: isCompleting ? null : () => _completeTask(task),
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
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
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

  Future<void> _completeTask(TaskModel task) async {
    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).completeTask(task);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _completedTaskIds.remove(task.id));
    }
  }

  Widget _buildActivitySection(AppThemeColors theme) {
    final activityAsync = ref.watch(recentActivityProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Movimientos del hogar', 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.textPrimary, letterSpacing: -0.7)),
        const SizedBox(height: AppSpacing.md),
        activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (activities) {
            if (activities.isEmpty) return _buildEmptyState('No hay actividad aún', theme);
            return Column(
              children: activities.map((a) => _buildActivityItem(a, theme, currentUserId)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, AppThemeColors theme, String? currentUserId) {
    final creatorId = activity['creator_id'];
    final isMe = creatorId == currentUserId;
    final data = activity['data'] as Map<String, dynamic>;
    final time = DateTime.tryParse(activity['created_at'] ?? '')?.toLocal() ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CustomUserAvatar(
              name: data['user_name'],
              avatarUrl: data['avatar_url'] ?? data['creator_avatar_url'],
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
                      Icon(_getCategoryIcon(data['category']), size: 16, color: theme.primary),
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
                        _formatActivityTime(time),
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
              name: data['user_name'],
              avatarUrl: data['avatar_url'] ?? data['creator_avatar_url'],
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

  String _formatActivityTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return DateFormat('d MMM').format(time);
  }

  Widget _buildTasksShimmer(AppThemeColors theme) {
    return Column(children: List.generate(2, (_) => ShimmerLoading(child: Container(height: 70, margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(20))))));
  }

  Widget _buildEmptyState(String message, AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: theme.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(children: [Text('🐾', style: TextStyle(fontSize: 32)), const SizedBox(height: 8), Text(message, style: TextStyle(fontWeight: FontWeight.w800, color: theme.textPrimary))]),
    );
  }

  void _showSettlementDialog({required String householdId, required String partnerId, required String partnerName, required double amount, required bool isOwedByMe}) {
    // Logic to settle debt...
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
