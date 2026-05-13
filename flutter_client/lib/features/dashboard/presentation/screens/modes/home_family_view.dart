import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_activity_feed_item.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
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
    final membersAsync = ref.read(householdMembersProvider);
    final currentUserId = ref.read(currentUserIdProvider) ?? '';
    final members = membersAsync.value ?? const <MemberModel>[];
    return members.where((m) => m.userId == currentUserId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final members = membersAsync.value ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChild = currentMember?.isChild ?? false;
    final isTeen = currentMember?.isTeen ?? false;
    final hasSharedAdultFinance =
        members.where((member) => member.isAdult).length > 1;
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        children: [
          _buildStaggeredSection(
            delayMs: 0,
            child: _buildHeader(theme, caps),
          ),
          SizedBox(height: isChild ? 20 : 16),
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
              child: _buildActivitySection(
                theme,
                title:
                    AppLocalizations.of(context).homeFamilyChildActivityTitle,
              ),
            ),
          ] else if (isTeen) ...[
            if (caps.showTasks)
              _buildStaggeredSection(
                delayMs: 140,
                child: FamilyTasksSection(
                  caps: caps,
                  currentMember: currentMember,
                  isChild: false,
                ),
              ),
            const SizedBox(height: 22),
            _buildStaggeredSection(
              delayMs: 200,
              child: _buildShoppingSection(theme),
            ),
            const SizedBox(height: 22),
            _buildStaggeredSection(
              delayMs: 260,
              child: _buildActivitySection(
                theme,
                title: AppLocalizations.of(context).homeFamilyActivityTitle,
              ),
            ),
          ] else ...[
            if (hasSharedAdultFinance) ...[
              _buildStaggeredSection(
                delayMs: 140,
                child: FamilyFinanceSection(
                  caps: caps,
                  currentMember: currentMember,
                ),
              ),
              const SizedBox(height: 22),
            ] else
              const SizedBox(height: 18),
            if (caps.showTasks)
              _buildStaggeredSection(
                delayMs: 180,
                child: FamilyTasksSection(
                  caps: caps,
                  currentMember: currentMember,
                  isChild: false,
                ),
              ),
            const SizedBox(height: 26),
            _buildStaggeredSection(
              delayMs: 240,
              child: _buildActivitySection(
                theme,
                title: AppLocalizations.of(context).homeFamilyActivityTitle,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme, HouseholdCapabilities caps) {
    final membersAsync = ref.watch(householdMembersProvider);
    final balanceAsync = ref.watch(userBalanceProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final showDate = currentMember?.isChild ?? false;
    final showProgress =
        (currentMember?.isTeen ?? false) || (currentMember?.isChild ?? false);
    final coins =
        balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0;
    final xp = balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0;
    final t = AppLocalizations.of(context);
    final localeTag = Localizations.localeOf(context).toString();

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
              if (showDate) ...[
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, d MMM', localeTag)
                      .format(DateTime.now())
                      ._capitalize(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
              ],
              if (showProgress) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildHeaderMetricChip(
                      icon: Icons.monetization_on_rounded,
                      label: t.homeFamilyMetricCoins,
                      value: '$coins',
                      color: AppColors.accentGold,
                    ),
                    _buildHeaderMetricChip(
                      icon: Icons.star_rounded,
                      label: 'XP',
                      value: '$xp',
                      color: AppColors.accentPurple,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
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
              t.homeFamilyMemberNotFound,
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

  Widget _buildHeaderMetricChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: context.theme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: context.theme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
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
    final t = AppLocalizations.of(context);
    final firstName =
        currentMember?.displayName ?? t.homeFamilyChildFallbackName;
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
                  t.homeFamilyChildHeroTitle,
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
            t.homeFamilyChildHeroBody(firstName),
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
                  t.homeFamilyChildRewardsPrompt,
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
                label: Text(t.mainTabShoppingChild),
              ),
            ],
          ),
        ],
      ),
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
    final t = AppLocalizations.of(context);
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
          final visiblePending = pending.take(3).toList();
          final remainingPending = pending.length - visiblePending.length;
          final header = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.homeFamilyShoppingTitle,
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
                child: Text(t.homeViewListButton),
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
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.border.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                          color: AppColors.sage.withValues(alpha: 0.78),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.homeFamilyShoppingAllDone,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                      ],
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
                    children: [
                      ...visiblePending.map((item) {
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
                      }),
                      if (remainingPending > 0)
                        InkWell(
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
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 14, 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color:
                                        theme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    size: 18,
                                    color: theme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t.homeFamilyShoppingMoreItems(
                                      remainingPending,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: theme.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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
    String? title,
  }) {
    final activitiesAsync = ref.watch(recentActivityProvider);
    final t = AppLocalizations.of(context);
    final resolvedTitle = title ?? t.homeFamilyActivityTitleDefault;

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
            resolvedTitle,
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
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.divider.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
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
                  t.homeFamilyActivityEmptyTitle,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.homeFamilyActivityEmptyBody,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.22,
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

  String? _firstName(String? fullName) {
    if (fullName == null) return null;
    return fullName.trim().split(' ').first;
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
    bool isChild = false,
  }) {
    final t = AppLocalizations.of(context);
    final firstName = _firstName(currentMemberName);
    if (isChild) {
      return TextSpan(
        children: [
          TextSpan(
            text: t.homeFamilyChildHello,
            style: TextStyle(color: theme.textPrimary),
          ),
          TextSpan(
            text: firstName ?? t.homeFamilyChildFallbackName,
            style: TextStyle(
              color: theme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }
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
          text: firstName ?? t.homeFamilyAdultFallbackName,
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
