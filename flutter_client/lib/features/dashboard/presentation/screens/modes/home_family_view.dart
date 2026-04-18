import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_activity_feed_item.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/debt_settlement_section.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_task_card.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
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
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChild = currentMember?.isChild ?? false;
    final membersLoaded = membersAsync.hasValue && !membersAsync.isLoading;
    final memberNotFound = membersLoaded && currentMember == null;
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
          _buildStaggeredSection(
            delayMs: 0,
            child: _buildHeader(theme, caps),
          ),
          const SizedBox(height: 24),
          if (memberNotFound)
            _buildStaggeredSection(
              delayMs: 10,
              child: _buildMemberNotFoundBanner(theme),
            ),
          if (memberNotFound) const SizedBox(height: 16),
          if (isChild) ...[
            _buildStaggeredSection(
              delayMs: 60,
              child: _buildChildWallet(theme),
            ),
            if (caps.showStats) ...[
              const SizedBox(height: 24),
              _buildStaggeredSection(
                delayMs: 120,
                child: _buildWeeklySummaryBlock(theme, statsAsync),
              ),
              const SizedBox(height: 24),
              _buildStaggeredSection(
                delayMs: 150,
                child: _buildWeeklyRankingBlock(theme, statsAsync),
              ),
            ],
            if (caps.showTasks) ...[
              const SizedBox(height: 32),
              _buildStaggeredSection(
                delayMs: 180,
                child: _buildTasksSection(theme, caps, isChild: true),
              ),
            ],
            const SizedBox(height: 32),
            _buildStaggeredSection(
              delayMs: 240,
              child: _buildShoppingSection(theme),
            ),
            const SizedBox(height: 32),
            _buildStaggeredSection(
              delayMs: 300,
              child: _buildActivitySection(theme),
            ),
          ] else ...[
            _buildStaggeredSection(
              delayMs: 60,
              child: _buildAdultHomeWelcome(theme),
            ),
            const SizedBox(height: 28),
            if (caps.showStats) ...[
              _buildStaggeredSection(
                delayMs: 100,
                child: _buildWeeklySummaryBlock(theme, statsAsync),
              ),
              const SizedBox(height: 24),
              _buildStaggeredSection(
                delayMs: 130,
                child: _buildWeeklyRankingBlock(theme, statsAsync),
              ),
            ],
            const SizedBox(height: 28),
            _buildStaggeredSection(
              delayMs: 140,
              child: _buildFinanceSection(theme, caps),
            ),
            const SizedBox(height: 20),
            _buildStaggeredSection(
              delayMs: 160,
              child: _buildDebtSettlement(theme),
            ),
            if (caps.showTasks)
              _buildStaggeredSection(
                delayMs: 180,
                child: _buildTasksSection(theme, caps, isChild: false),
              ),
            const SizedBox(height: 28),
            _buildStaggeredSection(
              delayMs: 240,
              child:
                  _buildActivitySection(theme, title: 'Movimientos del hogar'),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme, HouseholdCapabilities caps) {
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;

    return Row(
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
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 6),
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
        ),
        const SizedBox(width: 12),
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
    );
  }

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

  Widget _buildStaggeredSection({
    required int delayMs,
    required Widget child,
  }) {
    return _SectionReveal(
      delay: Duration(milliseconds: delayMs),
      child: child,
    );
  }

  Widget _buildMemberNotFoundBanner(AppThemeColors theme) {
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
          Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No encontramos tu perfil en este hogar.',
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
              ref.invalidate(householdMembersNotifierProvider);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Reintentar', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdultHomeWelcome(AppThemeColors theme) {
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
        ).animate().fadeIn(delay: 80.ms),
        Text(
          'del hogar',
          style: TextStyle(
            color: theme.textPrimary.withValues(alpha: 0.7),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 160.ms),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 24,
              height: 1.5,
              color: theme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'organizado para ',
              style: TextStyle(color: theme.textSecondary, fontSize: 14),
            ),
            Text(
              'la familia',
              style: TextStyle(
                color: theme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 240.ms),
      ],
    );
  }

  Widget _buildWeeklySummaryBlock(
    AppThemeColors theme,
    AsyncValue<StatsData?> statsAsync,
  ) {
    if (statsAsync.isLoading) {
      return _buildWeeklySummaryLoading(theme);
    }

    final stats = statsAsync.valueOrNull;

    final completedTasks = stats?.taskStats
            .fold(0, (sum, cat) => sum + (cat['count'] as int? ?? 0)) ??
        0;
    final totalXp = stats?.weeklyRanking.fold(
            0,
            (sum, member) =>
                sum + (member['xp_earned'] as num? ?? 0).toInt()) ??
        0;

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
                value: totalXp.toString(),
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

  Widget _buildWeeklySummaryLoading(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.surface.withValues(alpha: 0.98),
            theme.elevatedSurface.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.62),
        ),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              ShimmerLoading(height: 14, width: 136, borderRadius: 10),
              Spacer(),
              ShimmerLoading(height: 18, width: 18, borderRadius: 9),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(height: 48, borderRadius: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerLoading(height: 48, borderRadius: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerLoading(height: 48, borderRadius: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider(AppThemeColors theme) {
    return Container(
      width: 1,
      height: 24,
      color: theme.divider.withValues(alpha: 0.1),
    );
  }

  Widget _buildWeeklyRankingBlock(
    AppThemeColors theme,
    AsyncValue<StatsData?> statsAsync,
  ) {
    if (statsAsync.isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(height: 18, width: 132, borderRadius: 10),
          const SizedBox(height: 16),
          _buildRankingLoadingState(theme),
        ],
      );
    }

    final stats = statsAsync.valueOrNull;
    final members =
        ref.watch(householdMembersNotifierProvider).valueOrNull ?? [];

    final ranking = stats?.weeklyRanking ?? [];

    final displayRanking = ranking.isNotEmpty
        ? ranking
        : members
            .where((m) => m.isAdult || m.isChild)
            .map(
              (m) => <String, dynamic>{
                'user_name': m.fullDisplayName,
                'xp_earned': 0,
                'user_id': m.userId,
                'member_type': m.type.name,
                'avatar_url': m.avatarUrl,
                'tasks_completed': 0,
              },
            )
            .toList();

    final isLive = ranking.any((r) => ((r['xp_earned'] as num?) ?? 0) > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ranking Semanal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            if (!isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Esta semana',
                  style: TextStyle(fontSize: 10, color: theme.textSecondary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _RankingCategoryFilter(
          ranking: displayRanking,
          isLive: isLive,
        ),
      ],
    );
  }

  Widget _buildRankingLoadingState(AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
      ),
      child: const Column(
        children: [
          _RankingLoadingRow(),
          SizedBox(height: 12),
          _RankingLoadingRow(),
          SizedBox(height: 12),
          _RankingLoadingRow(),
        ],
      ),
    );
  }

  Widget _buildDebtSettlement(AppThemeColors theme) {
    final balancesAsync = ref.watch(expenseBalancesProvider);

    return balancesAsync.when(
      data: (balances) {
        if (balances.length < 3) return const SizedBox.shrink();
        return DebtSettlementSection(balances: balances);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildFinanceSection(
    AppThemeColors theme,
    HouseholdCapabilities caps,
  ) {
    final balancesAsync = ref.watch(expenseBalancesProvider);
    final walletAsync = ref.watch(userBalanceProvider);
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';

    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final isChild = currentMember?.isChild ?? false;
    final adultMembers = members.where((m) => m.isAdult).toList();
    final shouldShowSection =
        currentMember != null && !isChild && adultMembers.length > 1;
    final sectionTitle =
        adultMembers.length == 2 ? 'Balance del hogar' : 'Finanzas familiares';

    final isLoading = membersAsync.isLoading ||
        balancesAsync.isLoading ||
        walletAsync.isLoading;
    final hasError = membersAsync.hasError || balancesAsync.hasError;

    Widget child;
    if (!isLoading && !shouldShowSection) {
      child = const SizedBox.shrink(key: ValueKey('finance-hidden'));
    } else if (hasError) {
      child = Column(
        key: const ValueKey('finance-error'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinanceHeader(theme, sectionTitle),
          const SizedBox(height: 12),
          _buildFinanceEmptyState(
            theme,
            'No pudimos cargar las finanzas del hogar por ahora.',
          ),
          const SizedBox(height: 28),
        ],
      );
    } else if (isLoading) {
      child = Column(
        key: const ValueKey('finance-loading'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderLoading(),
          const SizedBox(height: 12),
          _buildFinanceLoadingState(theme),
          const SizedBox(height: 28),
        ],
      );
    } else {
      final walletCoins = walletAsync.valueOrNull?['coins'] as int? ?? 0;
      final walletXp = walletAsync.valueOrNull?['xp'] as int? ?? 0;
      final balances = balancesAsync.valueOrNull ?? const [];

      child = Column(
        key: ValueKey('finance-ready-${adultMembers.length}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinanceHeader(theme, sectionTitle),
          const SizedBox(height: 12),
          _buildFinanceReadyState(
            theme,
            caps,
            adultMembers: adultMembers,
            currentUserId: currentUserId,
            balances: balances,
            walletCoins: walletCoins,
            walletXp: walletXp,
          ),
          const SizedBox(height: 28),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildFinanceReadyState(
    AppThemeColors theme,
    HouseholdCapabilities caps, {
    required List<MemberModel> adultMembers,
    required String currentUserId,
    required List<HouseholdBalanceModel> balances,
    required int walletCoins,
    required int walletXp,
  }) {
    if (balances.isEmpty) {
      if (adultMembers.length == 2) {
        final partner = adultMembers
            .where((member) => member.userId != currentUserId)
            .firstOrNull;
        return BalanceCard(
          coins: walletCoins,
          xp: walletXp,
          userBalance: 0,
          partnerName: partner?.displayName,
        );
      }

      return _buildFinanceEmptyState(
        theme,
        'Todavia no hay balances del hogar para mostrar.',
      );
    }

    final adultIds = adultMembers.map((member) => member.userId).toSet();
    final adultBalances =
        balances.where((balance) => adultIds.contains(balance.userId)).toList();

    if (adultBalances.isEmpty) {
      if (adultMembers.length == 2) {
        final partner = adultMembers
            .where((member) => member.userId != currentUserId)
            .firstOrNull;
        return BalanceCard(
          coins: walletCoins,
          xp: walletXp,
          userBalance: 0,
          partnerName: partner?.displayName,
        );
      }

      return _buildFinanceEmptyState(
        theme,
        'Todavia no hay balances del hogar para mostrar.',
      );
    }

    if (adultMembers.length == 2) {
      final partner = adultMembers
          .where((member) => member.userId != currentUserId)
          .firstOrNull;
      final myBalance = adultBalances
          .where((balance) => balance.userId == currentUserId)
          .firstOrNull
          ?.balance;

      return BalanceCard(
        coins: walletCoins,
        xp: walletXp,
        userBalance: myBalance,
        partnerName: partner?.displayName,
      );
    }

    return FamilyBalanceCard(
      balances: adultBalances,
      title: caps.balanceMessage,
    );
  }

  Widget _buildFinanceHeader(AppThemeColors theme, String title) {
    final caps = ref.watch(householdCapabilitiesProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () {
            final index = indexForMainTab(caps, MainTab.expenses);
            if (index >= 0) {
              ref.read(bottomNavIndexProvider.notifier).setIndex(index);
            }
          },
          child: const Text('Ver todos'),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderLoading() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerLoading(height: 18, width: 136, borderRadius: 10),
        ShimmerLoading(height: 34, width: 72, borderRadius: 999),
      ],
    );
  }

  Widget _buildSectionStateSwitcher({
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildShoppingLoadingState(AppThemeColors theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          _ShoppingLoadingTile(),
          _ShoppingLoadingTile(),
          _ShoppingLoadingTile(),
        ],
      ),
    );
  }

  Widget _buildFinanceLoadingState(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.surface.withValues(alpha: 0.98),
            theme.elevatedSurface.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.62),
        ),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              ShimmerLoading(height: 14, width: 120, borderRadius: 10),
              Spacer(),
              ShimmerLoading(height: 44, width: 44, borderRadius: 22),
            ],
          ),
          SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: ShimmerLoading(height: 42, width: 170, borderRadius: 14),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(height: 56, borderRadius: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ShimmerLoading(height: 56, borderRadius: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceEmptyState(AppThemeColors theme, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: theme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin resumen financiero todavía',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: theme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(
    AppThemeColors theme,
    HouseholdCapabilities caps, {
    required bool isChild,
  }) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final sectionTitle = isChild ? 'Tareas de hoy' : 'Hoy en casa';
    final ctaLabel = isChild ? 'Ver panel' : 'Ver semana';
    return _buildSectionStateSwitcher(
      child: tasksAsync.when(
        loading: () => KeyedSubtree(
          key: const ValueKey('tasks-loading'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderLoading(),
              const SizedBox(height: 12),
              _buildTasksLoadingState(theme),
            ],
          ),
        ),
        error: (_, __) => const SizedBox.shrink(key: ValueKey('tasks-error')),
        data: (tasks) {
          final reviewTasks = !isChild
              ? tasks.where((task) => task.isPendingApproval).toList()
              : <TaskModel>[];
          final todayTasks = tasks
              .where((task) => task.isPending && !task.isPendingApproval)
              .where((task) => task.isDueToday)
              .toList()
            ..sort((a, b) {
              final aAssigned = a.assignedTo != null;
              final bAssigned = b.assignedTo != null;
              if (aAssigned != bAssigned) {
                return aAssigned ? -1 : 1;
              }
              return a.createdAt.compareTo(b.createdAt);
            });
          final overdueTasks = tasks
              .where((task) => task.isPending && !task.isPendingApproval)
              .where((task) => task.isOverdue)
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          final visibleOverdueTasks = overdueTasks.take(4).toList();
          final remainingOverdueCount =
              overdueTasks.length - visibleOverdueTasks.length;

          final visibleTasks = <TaskModel>[
            ...reviewTasks,
            ...visibleOverdueTasks,
            ...todayTasks,
          ];

          final header = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.7,
                ),
              ),
              TextButton(
                onPressed: () {
                  final index = indexForMainTab(caps, MainTab.tasks);
                  if (index >= 0) {
                    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                  }
                },
                child: Text(ctaLabel),
              ),
            ],
          );

          if (visibleTasks.isEmpty) {
            return KeyedSubtree(
              key: const ValueKey('tasks-empty'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 12),
                  _buildEmptyState(
                    theme,
                    isChild
                        ? 'No hay tareas para hoy.'
                        : 'No hay tareas programadas para hoy.',
                  ),
                ],
              ),
            );
          }
          return KeyedSubtree(
            key: ValueKey(
              'tasks-data-${visibleTasks.length}-${overdueTasks.length}',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = visibleTasks[index];
                    return _buildTaskItem(task, theme);
                  },
                ),
                if (remainingOverdueCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.divider.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: theme.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            remainingOverdueCount == 1
                                ? 'Hay 1 tarea atrasada más pendiente.'
                                : 'Hay $remainingOverdueCount tareas atrasadas más pendientes.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksLoadingState(AppThemeColors theme) {
    return Column(
      children: [
        _buildTaskLoadingCard(theme),
        const SizedBox(height: 12),
        _buildTaskLoadingCard(theme),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.surfaceContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.divider.withValues(alpha: 0.08),
            ),
          ),
          child: const ShimmerLoading(height: 14, borderRadius: 10),
        ),
      ],
    );
  }

  Widget _buildTaskLoadingCard(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.divider.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            children: [
              ShimmerLoading(height: 44, width: 44, borderRadius: 14),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(height: 15, width: 150, borderRadius: 10),
                    SizedBox(height: 8),
                    ShimmerLoading(height: 12, width: 110, borderRadius: 10),
                  ],
                ),
              ),
              SizedBox(width: 10),
              ShimmerLoading(height: 34, width: 34, borderRadius: 12),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(height: 32, borderRadius: 999),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ShimmerLoading(height: 32, borderRadius: 999),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, AppThemeColors theme) {
    final members = ref.watch(householdMembersNotifierProvider).valueOrNull ??
        const <MemberModel>[];
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChildView = currentMember?.isChild ?? false;
    final isAdultView = currentMember?.isAdult ?? false;
    final assignedMember =
        members.where((member) => member.userId == task.assignedTo).firstOrNull;
    final completedMember = members
        .where((member) => member.userId == task.completedBy)
        .firstOrNull;
    final isOpenTask = task.assignedTo == null;
    final isAssignedToCurrentUser = task.assignedTo == currentUserId;

    IconData actionIcon;
    VoidCallback? onTap;
    var isActionEnabled = true;

    if (task.isPendingApproval) {
      if (isAdultView) {
        actionIcon = Icons.fact_check_rounded;
        onTap = () => _showApprovalActions(task, members);
      } else {
        actionIcon = Icons.hourglass_top_rounded;
        isActionEnabled = false;
        onTap = null;
      }
    } else if (isOpenTask) {
      actionIcon = Icons.check_rounded;
      onTap = () {
        if (isChildView) {
          _confirmOpenTaskCompletion(task, isChildView: true);
        } else {
          _completeTask(task);
        }
      };
    } else if (isAssignedToCurrentUser) {
      if (isChildView) {
        actionIcon = Icons.send_rounded;
        onTap = () => _submitTaskForApproval(task);
      } else {
        actionIcon = Icons.check_rounded;
        onTap = () => _completeTask(task);
      }
    } else {
      if (isAdultView) {
        actionIcon = Icons.check_rounded;
        onTap = () => _confirmAdultTakeoverCompletion(task, assignedMember);
      } else {
        actionIcon = Icons.lock_outline_rounded;
        isActionEnabled = false;
        onTap = () => _showTaskLockedMessage(assignedMember);
      }
    }

    return FamilyTaskCard(
      task: task,
      isCompleting: _completedTaskIds.contains(task.id),
      isChildView: isChildView,
      assignedMember: assignedMember,
      completedMember: completedMember,
      currentUserId: currentUserId,
      actionIcon: actionIcon,
      isActionEnabled: isActionEnabled,
      onTap: onTap,
    );
  }

  Future<void> _confirmOpenTaskCompletion(
    TaskModel task, {
    required bool isChildView,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final members = ref.read(householdMembersNotifierProvider).valueOrNull ??
        const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final actorName = currentMember?.displayName ?? 'vos';

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Marcar tarea'),
            content: Text(
              isChildView
                  ? 'Se va a marcar "${task.title}" como realizada por $actorName y se enviará a revisión.'
                  : 'Se va a marcar "${task.title}" como realizada por $actorName.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    if (isChildView) {
      await _submitTaskForApproval(task);
    } else {
      await _completeTask(task);
    }
  }

  Future<void> _confirmAdultTakeoverCompletion(
    TaskModel task,
    MemberModel? assignedMember,
  ) async {
    final ownerName = assignedMember?.displayName ?? 'otro integrante';
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Completar tarea'),
            content: Text(
              'Esta tarea estaba asignada a $ownerName. Si seguís, se va a marcar como realizada por vos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Completar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final takeoverUserIds =
        assignedMember != null ? [assignedMember.userId] : null;
    await _completeTask(task, userIds: takeoverUserIds);
  }

  void _showTaskLockedMessage(MemberModel? assignedMember) {
    final ownerName = assignedMember?.displayName ?? 'otra persona';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Esta tarea le toca a $ownerName.'),
      ),
    );
  }

  Future<void> _submitTaskForApproval(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).submitTaskForApproval(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviada para revisión de un adulto.'),
        ),
      );
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos enviar la tarea: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _showApprovalActions(
    TaskModel task,
    List<MemberModel> members,
  ) async {
    final performer = members
        .where((member) => member.userId == task.completedBy)
        .firstOrNull;
    final performerName = performer?.displayName ?? 'este integrante';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = context.theme;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisar tarea',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$performerName marcó "${task.title}" como realizada.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _approvePendingTask(task);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aprobar tarea'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _rejectPendingTask(task);
                    },
                    icon: const Icon(Icons.reply_rounded),
                    label: const Text('Devolver para corregir'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _approvePendingTask(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      final result =
          await ref.read(tasksProvider.notifier).approvePendingTask(task);
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos aprobar la tarea.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea aprobada.')),
        );
        ref.invalidate(tasksProvider);
        ref.invalidate(todayTasksProvider);
        ref.invalidate(recentActivityProvider);
        ref.invalidate(statsControllerProvider);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos aprobar la tarea: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _rejectPendingTask(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).rejectPendingTask(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La tarea volvió a quedar pendiente.')),
      );
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos devolver la tarea: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _completeTask(
    TaskModel task, {
    List<String>? userIds,
  }) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      log.d('[family] completing task id=${task.id} title=${task.title}');
      final result = await ref
          .read(tasksProvider.notifier)
          .completeTask(task, userIds: userIds);

      if (!mounted) return;

      if (result == null) {
        log.w('[family] task completion returned null id=${task.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos completar la tarea. Intenta de nuevo.'),
          ),
        );
        return;
      }

      log.i(
        '[family] task completion success id=${task.id} queued=${result.queued} message=${result.message}',
      );
      ref.invalidate(statsControllerProvider);
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      log.e('[family] task completion threw id=${task.id}', error: e);
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
    final caps = ref.watch(householdCapabilitiesProvider);
    return _buildSectionStateSwitcher(
      child: shoppingAsync.when(
        loading: () => KeyedSubtree(
          key: const ValueKey('shopping-loading'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderLoading(),
              const SizedBox(height: 12),
              _buildShoppingLoadingState(theme),
            ],
          ),
        ),
        error: (_, __) =>
            const SizedBox.shrink(key: ValueKey('shopping-error')),
        data: (items) {
          final pending = items.where((item) => !item.completed).toList();
          final header = Row(
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
                  final index = indexForMainTab(caps, MainTab.shopping);
                  if (index >= 0) {
                    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                  }
                },
                child: const Text('Ver lista'),
              ),
            ],
          );

          if (pending.isEmpty) {
            return KeyedSubtree(
              key: const ValueKey('shopping-empty'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 12),
                  Container(
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
                  ),
                ],
              ),
            );
          }

          return KeyedSubtree(
            key: ValueKey('shopping-data-${pending.length}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 12),
                Container(
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
                        subtitle:
                            quantityLabel != null && quantityLabel.isNotEmpty
                                ? Text(quantityLabel)
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
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivitySection(
    AppThemeColors theme, {
    String title = 'Actividad Reciente',
  }) {
    final activitiesAsync = ref.watch(recentActivityProvider);

    return _buildSectionStateSwitcher(
      child: activitiesAsync.when(
        loading: () => KeyedSubtree(
          key: const ValueKey('activity-loading'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerLoading(height: 18, width: 168, borderRadius: 10),
              const SizedBox(height: 16),
              _buildActivityLoadingState(theme),
            ],
          ),
        ),
        error: (_, __) =>
            const SizedBox.shrink(key: ValueKey('activity-error')),
        data: (activities) {
          final header = Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          );

          if (activities.isEmpty) {
            return KeyedSubtree(
              key: const ValueKey('activity-empty'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 16),
                  _buildActivityEmptyState(theme),
                ],
              ),
            );
          }

          return KeyedSubtree(
            key: ValueKey('activity-data-${activities.length.clamp(0, 4)}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (activities.length > 4) ? 4 : activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return FamilyActivityFeedItem(
                      activity: activities[index],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityLoadingState(AppThemeColors theme) {
    return Column(
      children: [
        _buildActivityLoadingCard(theme),
        const SizedBox(height: 12),
        _buildActivityLoadingCard(theme),
      ],
    );
  }

  Widget _buildActivityLoadingCard(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.divider.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            children: [
              ShimmerLoading(height: 40, width: 40, borderRadius: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(height: 14, width: 170, borderRadius: 10),
                    SizedBox(height: 8),
                    ShimmerLoading(height: 12, width: 120, borderRadius: 10),
                  ],
                ),
              ),
              SizedBox(width: 12),
              ShimmerLoading(height: 28, width: 28, borderRadius: 14),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(height: 30, borderRadius: 999),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ShimmerLoading(height: 30, borderRadius: 999),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ShimmerLoading(height: 30, borderRadius: 999),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityEmptyState(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.divider.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.timeline_rounded,
              size: 18,
              color: theme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todavía no hay actividad reciente',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Cuando alguien complete una tarea, registre un gasto o marque una compra, lo vas a ver acá.',
                  style: TextStyle(
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
                const SizedBox(height: 2),
                Text(
                  'Tus tareas suman monedas para canjear premios.',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _firstName(String? fullName) {
    if (fullName == null) return null;
    return fullName.trim().split(' ').first;
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
  }) {
    final firstName = _firstName(currentMemberName);
    final welcome = firstName != null
        ? (_looksFeminineName(firstName) ? 'Bienvenida' : 'Bienvenido')
        : 'Bienvenido';

    return TextSpan(
      children: [
        TextSpan(
          text: '$welcome, ',
          style: TextStyle(color: theme.textPrimary),
        ),
        TextSpan(
          text: firstName ?? 'Familia',
          style: TextStyle(
            color: theme.primary,
            fontWeight: FontWeight.w900,
          ),
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
}

extension _StringExtension on String {
  String _capitalize() {
    if (isEmpty) return this;
    final trimmed = trim();
    if (trimmed.isEmpty) return this;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }
}

class _RankingLoadingRow extends StatelessWidget {
  const _RankingLoadingRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ShimmerLoading(height: 28, width: 28, borderRadius: 14),
        SizedBox(width: 12),
        Expanded(
          child: ShimmerLoading(height: 14, width: 120, borderRadius: 10),
        ),
        SizedBox(width: 12),
        ShimmerLoading(height: 24, width: 52, borderRadius: 12),
      ],
    );
  }
}

class _RankingCategoryFilter extends StatefulWidget {
  final List<Map<String, dynamic>> ranking;
  final bool isLive;

  const _RankingCategoryFilter({
    required this.ranking,
    required this.isLive,
  });

  @override
  State<_RankingCategoryFilter> createState() => _RankingCategoryFilterState();
}

class _RankingCategoryFilterState extends State<_RankingCategoryFilter> {
  int _selectedTab = 0;
  static const _tabs = ['Todos', 'Adultos', 'Peques'];

  List<Map<String, dynamic>> _filteredRanking() {
    if (_selectedTab == 0) return widget.ranking;
    final targetType = _selectedTab == 1 ? 'adult' : 'child';
    return widget.ranking
        .where((item) => (item['member_type'] as String?) == targetType)
        .toList();
  }

  String _displayName(Map<String, dynamic> item) {
    final name = item['user_name'] as String? ?? '';
    if (name.isNotEmpty) {
      return name.split(' ').first;
    }
    return 'Integrante';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeColors>()!;
    final filtered = _filteredRanking();
    final hasAdults = widget.ranking.any((i) => i['member_type'] == 'adult');
    final hasChildren = widget.ranking.any((i) => i['member_type'] == 'child');
    final showTabs = hasAdults && hasChildren;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          if (showTabs) ...[
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = _selectedTab == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          _tabs[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color:
                                selected ? theme.primary : theme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 14,
                    color: theme.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedTab == 0
                        ? 'Completen tareas para sumar puntos'
                        : 'Nadie sumó puntos en ${_tabs[_selectedTab]} todavía',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filtered.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isFirst = index == 0;
              final xp = (item['xp_earned'] as num?)?.toInt() ?? 0;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < filtered.length - 1 && index < 4 ? 12 : 0,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isFirst && xp > 0
                          ? AppColors.accentGold
                          : theme.divider.withValues(alpha: 0.1),
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFirst && xp > 0
                              ? Colors.black
                              : theme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _displayName(item),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isFirst && xp > 0
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: xp > 0
                            ? theme.primary.withValues(alpha: 0.1)
                            : theme.divider.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        xp > 0 ? '$xp pts' : '— pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: xp > 0 ? theme.primary : theme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (!widget.isLive && !showTabs) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 14,
                  color: theme.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Completen tareas para sumar puntos',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ShoppingLoadingTile extends StatelessWidget {
  const _ShoppingLoadingTile();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShimmerLoading(height: 24, width: 24, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: ShimmerLoading(height: 14, borderRadius: 10),
          ),
          SizedBox(width: 12),
          ShimmerLoading(height: 16, width: 16, borderRadius: 8),
        ],
      ),
    );
  }
}

class _SectionReveal extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _SectionReveal({
    required this.delay,
    required this.child,
  });

  @override
  State<_SectionReveal> createState() => _SectionRevealState();
}

class _SectionRevealState extends State<_SectionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.045),
      end: Offset.zero,
    ).animate(curve);
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (_started) return;
    _started = true;
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (!mounted) return;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
