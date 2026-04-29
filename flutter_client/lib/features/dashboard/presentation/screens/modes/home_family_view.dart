import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/debt_settlement_section.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_activity_feed_item.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/family_dashboard_screen.dart';
import 'package:homesync_client/features/tasks/presentation/screens/weekly_family_summary_screen.dart';
import 'package:intl/intl.dart';
import 'family_finance_section.dart';
import 'family_tasks_section.dart';

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
  MemberModel? get _currentMember {
    final membersAsync = ref.read(householdMembersNotifierProvider);
    final currentUserId = ref.read(currentUserIdProvider) ?? '';
    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    return members.where((m) => m.userId == currentUserId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChild = currentMember?.isChild ?? false;
    final isTeen = currentMember?.isTeen ?? false;
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
              delayMs: 40,
              child: _buildChildHero(theme, currentMember),
            ),
            const SizedBox(height: 22),
            if (caps.showTasks) ...[
              _buildStaggeredSection(
                delayMs: 60,
                child: FamilyTasksSection(
                  caps: caps,
                  currentMember: currentMember,
                  isChild: true,
                ),
              ),
            ],
            const SizedBox(height: 26),
            _buildStaggeredSection(
              delayMs: 120,
              child: _buildActivitySection(theme, title: 'Mis logros'),
            ),
          ] else if (isTeen) ...[
            _buildStaggeredSection(
              delayMs: 60,
              child: _buildAdultHomeWelcome(theme),
            ),
            const SizedBox(height: 28),
            _buildStaggeredSection(
              delayMs: 80,
              child: _buildPersonalFinanceCard(theme),
            ),
            if (caps.showTasks)
              _buildStaggeredSection(
                delayMs: 140,
                child: FamilyTasksSection(
                  caps: caps,
                  currentMember: currentMember,
                  isChild: false,
                ),
              ),
            const SizedBox(height: 28),
            _buildStaggeredSection(
              delayMs: 200,
              child: _buildShoppingSection(theme),
            ),
            const SizedBox(height: 28),
            _buildStaggeredSection(
              delayMs: 260,
              child:
                  _buildActivitySection(theme, title: 'Movimientos del hogar'),
            ),
          ] else ...[
            _buildStaggeredSection(
              delayMs: 60,
              child: _buildAdultHomeWelcome(theme),
            ),
            const SizedBox(height: 28),
            const SizedBox(height: 28),
            _buildStaggeredSection(
              delayMs: 140,
              child: FamilyFinanceSection(
                caps: caps,
                currentMember: currentMember,
              ),
            ),
            const SizedBox(height: 20),
            _buildStaggeredSection(
              delayMs: 160,
              child: _buildDebtSettlement(theme),
            ),
            if (caps.showTasks)
              _buildStaggeredSection(
                delayMs: 180,
                child: FamilyTasksSection(
                  caps: caps,
                  currentMember: currentMember,
                  isChild: false,
                ),
              ),
            if (ref.watch(parentModeAvailableProvider)) ...[
              const SizedBox(height: 20),
              _buildStaggeredSection(
                delayMs: 210,
                child: _buildParentModeShortcuts(theme),
              ),
            ],
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
                  isChild: currentMember?.isChild ?? false,
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
          child: Transform.translate(
            offset: const Offset(6, 0),
            child: SizedBox(
              width: 96,
              height: 58,
              child: OverflowBox(
                alignment: Alignment.topRight,
                maxWidth: 122,
                maxHeight: 132,
                child: CustomUserAvatar(
                  avatarUrl: currentMember?.avatarUrl,
                  radius: 26,
                  showBorder: true,
                  isAnimated: true,
                ),
              ),
            ),
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
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 22,
          ),
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

  Widget _buildParentModeShortcuts(AppThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seguimiento familiar',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildParentModeShortcut(
                icon: Icons.groups_rounded,
                label: 'Vista por miembro',
                color: AppColors.accentBlue,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FamilyDashboardScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildParentModeShortcut(
                icon: Icons.celebration_rounded,
                label: 'Resumen semanal',
                color: AppColors.accentPurple,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WeeklyFamilySummaryScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParentModeShortcut({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(minHeight: 62),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChildHero(AppThemeColors theme, MemberModel? currentMember) {
    final balanceAsync = ref.watch(userBalanceProvider);
    final coins =
        balanceAsync.whenOrNull(data: (balance) => balance?['coins'] as int?) ??
            0;
    final xp =
        balanceAsync.whenOrNull(data: (balance) => balance?['xp'] as int?) ?? 0;
    final firstName = currentMember?.displayName ?? 'vos';
    final caps = ref.watch(householdCapabilitiesProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF2DF),
            Color(0xFFFFF8F0),
            Color(0xFFEAF7F4),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFD7B3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF08B49).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFF08B49),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aventura de hoy',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: -0.55,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$firstName, cada mision aprobada suma coins para la tienda.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChildHeroMetric(
                  icon: Icons.monetization_on_rounded,
                  label: 'Coins',
                  value: '$coins',
                  color: AppColors.sage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChildHeroMetric(
                  icon: Icons.star_rounded,
                  label: 'XP',
                  value: '$xp',
                  color: const Color(0xFFE8943A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mira que premios podes alcanzar.',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton.icon(
                onPressed: () {
                  final index = indexForMainTab(
                    caps,
                    MainTab.shopping,
                    currentMember: currentMember,
                  );
                  if (index >= 0) {
                    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                  }
                },
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text('Tienda'),
              ),
            ],
          ),
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
                  final index = indexForMainTab(
                    caps,
                    MainTab.shopping,
                    currentMember: _currentMember,
                  );
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
                          final index = indexForMainTab(
                            caps,
                            MainTab.shopping,
                            currentMember: _currentMember,
                          );
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

  Widget _buildPersonalFinanceCard(AppThemeColors theme) {
    final balanceAsync = ref.watch(userBalanceProvider);
    final coins =
        balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0;
    final xp = balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.surface, theme.elevatedSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.68),
          width: 1.05,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase.withValues(alpha: 0.048),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInlineMetric(
              context,
              icon: Icons.monetization_on_rounded,
              label: 'Monedas',
              value: '$coins',
              color: AppColors.accentGold,
            ),
          ),
          Container(
            width: 1,
            height: 48,
            color: theme.border.withValues(alpha: 0.32),
          ),
          Expanded(
            child: _buildInlineMetric(
              context,
              icon: Icons.star_rounded,
              label: 'XP',
              value: '$xp',
              color: AppColors.accentPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _firstName(String? fullName) {
    if (fullName == null) return null;
    return fullName.trim().split(' ').first;
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
    bool isChild = false,
  }) {
    final firstName = _firstName(currentMemberName);
    if (isChild) {
      return TextSpan(
        children: [
          TextSpan(
            text: 'Hola, ',
            style: TextStyle(color: theme.textPrimary),
          ),
          TextSpan(
            text: firstName ?? 'campeon',
            style: TextStyle(
              color: theme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }
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

class _ChildHeroMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ChildHeroMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
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
