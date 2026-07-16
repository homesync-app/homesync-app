import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/core/widgets/concept_icon.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../household/presentation/providers/household_provider.dart';
import '../../../stats/presentation/widgets/weekly_progress_tab.dart';
import '../../domain/models/couple_challenge.dart';
import '../../domain/models/reward_model.dart';
import '../providers/couple_challenge_provider.dart';
import '../providers/couple_duel_stats_provider.dart';
import '../providers/reward_provider.dart';
import '../utils/reward_localization.dart';
import '../widgets/couple_challenge_card.dart';
import '../widgets/couple_challenge_completion_mixin.dart';
import '../widgets/pending_redemptions_section.dart';
import '../widgets/redeem_reward_dialog.dart';

class CoupleRewardsScreen extends ConsumerStatefulWidget {
  final String householdId;
  final bool showDuel;

  const CoupleRewardsScreen({
    super.key,
    required this.householdId,
    this.showDuel = true,
  });

  @override
  ConsumerState<CoupleRewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<CoupleRewardsScreen>
    with
        SingleTickerProviderStateMixin,
        CoupleChallengeCompletionMixin<CoupleRewardsScreen> {
  late TabController _tabController;

  bool _isStatsLoading = true;
  List<Map<String, dynamic>> _taskStats = [];
  List<Map<String, dynamic>> _memberStats = [];
  List<Map<String, dynamic>> _weeklyRanking = [];
  List<Map<String, dynamic>> _duelHistory = [];
  late bool _hasOpenedRewardsTab;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.showDuel ? 2 : 1,
      vsync: this,
      initialIndex: widget.showDuel ? ref.read(parejaTabIndexProvider) : 0,
    );
    _hasOpenedRewardsTab = !widget.showDuel || _tabController.index == 1;
    if (widget.showDuel) {
      _tabController.addListener(_onTabChanged);
      _loadDuelStats();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    ref.read(parejaTabIndexProvider.notifier).setIndex(_tabController.index);
    if (_tabController.index == 1 && !_hasOpenedRewardsTab && mounted) {
      setState(() => _hasOpenedRewardsTab = true);
    }
    if (_tabController.index == 0) {
      // Al volver al duelo, revalidar en silencio si la caché quedó vieja
      // (los datos cacheados siguen visibles mientras tanto).
      _loadDuelStats();
    }
  }

  @override
  void didUpdateWidget(covariant CoupleRewardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDuel != widget.showDuel) {
      _tabController.dispose();
      _tabController = TabController(
        length: widget.showDuel ? 2 : 1,
        vsync: this,
        initialIndex: widget.showDuel ? ref.read(parejaTabIndexProvider) : 0,
      );
      _hasOpenedRewardsTab = !widget.showDuel || _tabController.index == 1;
      if (widget.showDuel) {
        _tabController.addListener(_onTabChanged);
        _loadDuelStats();
      }
    }
    if (oldWidget.householdId != widget.householdId) {
      _taskStats = [];
      _memberStats = [];
      _weeklyRanking = [];
      _duelHistory = [];
      _hasOpenedRewardsTab = !widget.showDuel || _tabController.index == 1;
      if (widget.showDuel) {
        _loadDuelStats();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDuelStats({bool forceRefresh = false}) async {
    if (mounted) {
      final hasCachedDuelData = _weeklyRanking.isNotEmpty ||
          _memberStats.isNotEmpty ||
          _taskStats.isNotEmpty ||
          _duelHistory.isNotEmpty;
      if (!hasCachedDuelData) {
        setState(() => _isStatsLoading = true);
      }
    }

    try {
      // Las stats viven en coupleDuelStatsProvider (keepAlive): el primer load
      // aprovecha la caché calentada en segundo plano desde el Home, así el tab
      // abre al instante. El pull-to-refresh fuerza datos frescos.
      if (forceRefresh) {
        ref.invalidate(coupleDuelStatsProvider);
        ref.invalidate(weeklyXpByDayProvider);
      }
      var stats = await ref.read(coupleDuelStatsProvider.future);
      // Revalidación silenciosa: la caché keepAlive solo se invalida desde
      // esta pantalla, así que después de completar tareas (o al cruzar el
      // lunes) quedaría congelada. Si los datos están viejos, refrescamos
      // mientras la copia cacheada sigue visible.
      if (!forceRefresh && _isDuelDataStale(stats.fetchedAt)) {
        ref.invalidate(coupleDuelStatsProvider);
        ref.invalidate(weeklyXpByDayProvider);
        stats = await ref.read(coupleDuelStatsProvider.future);
      }
      if (!mounted) return;
      setState(() {
        _taskStats = stats.taskStats;
        _memberStats = stats.memberStats;
        _weeklyRanking = stats.weeklyRanking;
        _duelHistory = stats.duelHistory;
        _isStatsLoading = false;
      });
    } catch (error, stackTrace) {
      log.w(
        'CoupleRewardsScreen failed to load duel stats',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isStatsLoading = false);
    }
  }

  /// Vieja si tiene más de 2 minutos o si se trajo antes del lunes de la
  /// semana en curso (el duelo es semanal: datos de la semana pasada no
  /// sirven como "actuales").
  bool _isDuelDataStale(DateTime? fetchedAt) {
    if (fetchedAt == null) return false;
    final now = DateTime.now();
    if (now.difference(fetchedAt) > const Duration(minutes: 2)) return true;
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return fetchedAt.isBefore(monday);
  }

  int get _totalTasksCompleted {
    final fromTasks = _taskStats.fold(
      0,
      (sum, item) => sum + ((item['completed_count'] as num?)?.toInt() ?? 0),
    );
    if (fromTasks > 0) {
      return fromTasks;
    }

    return _memberStats.fold(
      0,
      (sum, item) => sum + ((item['tasks_completed'] as num?)?.toInt() ?? 0),
    );
  }

  int get _totalXpEarned {
    final fromTasks = _taskStats.fold(
      0,
      (sum, item) => sum + ((item['total_xp'] as num?)?.toInt() ?? 0),
    );
    if (fromTasks > 0) {
      return fromTasks;
    }

    return _memberStats.fold(
      0,
      (sum, item) => sum + ((item['xp_earned'] as num?)?.toInt() ?? 0),
    );
  }

  int get _totalCoinsEarned => _memberStats.fold(
        0,
        (sum, item) => sum + ((item['coins_earned'] as num?)?.toInt() ?? 0),
      );

  String _getWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.day}/${monday.month} - ${sunday.day}/${sunday.month}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showDuel) {
      ref.listen<int>(parejaTabIndexProvider, (previous, next) {
        if (_tabController.index != next) {
          _tabController.animateTo(next);
          if (next == 1 && !_hasOpenedRewardsTab) {
            setState(() => _hasOpenedRewardsTab = true);
          }
        }
      });
    }

    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final List<String> tabLabels = widget.showDuel
        ? [t.rewardsTabDuel, t.rewardsTabPrizes]
        : [t.rewardsTabPrizes];
    final tabViews = [
      if (widget.showDuel) _buildDuelTab(),
      _hasOpenedRewardsTab ? _buildRewardsTab() : const SizedBox.shrink(),
    ];

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                6,
                AppSpacing.lg,
                10,
              ),
              child: AppSegmentedTabs(
                controller: _tabController,
                labels: tabLabels,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: tabViews,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab() {
    final rewardsAsync = ref.watch(rewardsProvider);
    final currentUserId = ref.read(currentUserIdProvider);
    final t = AppLocalizations.of(context);

    return rewardsAsync.when(
      // Keep the current list visible while recomputing after a mutation
      // (create/edit/approve/delete) instead of flashing the full-page loader.
      skipLoadingOnReload: true,
      data: (rewards) {
        final activeRewards = rewards.where((r) => r.isActive).toList();
        final availableCoins =
            ref.watch(userBalanceProvider).value?['coins'] ?? 0;
        final approvedRewards =
            activeRewards.where((r) => r.isApproved == true).toList();
        final suggestions =
            activeRewards.where((r) => r.isApproved == false).toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(rewardsProvider.notifier).refresh(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              2,
              AppSpacing.lg,
              132,
            ),
            children: [
              _buildCoinsDivider(availableCoins),
              const SizedBox(height: 18),
              _buildChallengeSection(widget.householdId),
              const SizedBox(height: 28),
              const PendingRedemptionsSection(
                margin: EdgeInsets.only(bottom: 28),
              ),
              if (approvedRewards.isEmpty)
                _buildEmptyState()
              else
                _buildGroupedRewards(approvedRewards),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 28),
                _buildPendingProposalsSection(suggestions, currentUserId),
              ],
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        );
      },
      loading: () => AppLoadingState(message: t.rewardsLoading),
      error: (e, _) => AppErrorState(
        message: t.rewardsLoadError(e.toString()),
        onRetry: () => ref.invalidate(rewardsProvider),
      ),
    );
  }

  Widget _buildDuelTab() {
    if (_isStatsLoading) {
      return _buildDuelLoadingState();
    }

    return WeeklyProgressTab(
      weeklyRanking: _weeklyRanking,
      memberStats: _memberStats,
      duelHistory: _duelHistory,
      weekRange: _getWeekRange(),
      totalTasks: _totalTasksCompleted,
      totalXp: _totalXpEarned,
      totalCoins: _totalCoinsEarned,
      showHeader: false,
      onRefresh: () => _loadDuelStats(forceRefresh: true),
    );
  }

  Widget _buildDuelLoadingState() {
    final theme = context.theme;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        2,
        AppSpacing.lg,
        132,
      ),
      children: [
        ShimmerLoading(
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.modal),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ShimmerLoading(
          child: Container(
            height: 98,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ShimmerLoading(
          child: Container(
            height: 98,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.xl),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildChallengeSection(String? householdId) {
    if (householdId == null) {
      return const SizedBox.shrink();
    }

    final householdAsync = ref.watch(householdProvider);

    return householdAsync.when(
      data: (household) {
        final challenge =
            CoupleChallenge.currentWeeklyChallenge(household?.createdAt);
        final challengeIndex =
            CoupleChallenge.currentWeeklyChallengeIndex(household?.createdAt);
        final weekIndex =
            CoupleChallenge.currentWeekIndex(household?.createdAt);
        final totalChallenges = CoupleChallenge.allChallenges.length;
        final isCompleted = ref
                .watch(
                  coupleChallengeCompletedProvider(
                    (householdId: householdId, weekIndex: weekIndex),
                  ),
                )
                .value ??
            false;
        return CoupleChallengeCard(
          challenge: challenge,
          challengeNumber: challengeIndex + 1,
          totalChallenges: totalChallenges,
          isCompleted: isCompleted,
          onComplete: () => handleCoupleChallengeCompletion(
            challenge,
            householdId,
            weekIndex,
          ),
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle, Widget? action}) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.sectionTitle.copyWith(
                  fontSize: 22,
                  color: theme.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    height: 1.35,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 12),
          action,
        ],
      ],
    );
  }

  Widget _buildGroupedRewards(List<RewardModel> rewards) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final grouped = <String, List<RewardModel>>{};
    for (final reward in rewards) {
      final normalized = _getNormalizedCategory(reward.category);
      grouped.putIfAbsent(normalized, () => []).add(reward);
    }

    const order = ['mimos', 'momentos', 'libertades', 'experiencias', 'otros'];
    final categories = grouped.keys.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

    return Column(
      children: categories.map((category) {
        final catRewards = grouped[category] ?? const <RewardModel>[];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: theme.border.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizedRewardCategoryByKey(t, null, category),
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    _buildCountPill('${catRewards.length}'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildRewardsGrid(catRewards),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingProposalsSection(
    List<RewardModel> suggestions,
    String? currentUserId,
  ) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          t.rewardsProposalsSection,
          subtitle: t.rewardsPendingApproval,
          action: _buildCountPill('${suggestions.length}'),
        ),
        const SizedBox(height: 14),
        Column(
          children: [
            for (var i = 0; i < suggestions.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _buildProposalCard(suggestions[i], currentUserId),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProposalCard(RewardModel reward, String? currentUserId) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final isMine = reward.createdBy == currentUserId;
    final accent = isMine ? AppColors.primary : AppColors.accentPurple;
    final title = localizedRewardTitle(t, reward);
    final description = localizedRewardDescription(t, reward) ??
        t.rewardsWaitingPartnerDecision;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isMine ? null : () => _showProposalDecisionSheet(reward),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(
              color: accent.withValues(alpha: 0.18),
            ),
            boxShadow: theme.cardShadow,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon tile
              SizedBox(
                width: 52,
                height: 52,
                child: Center(
                  child: ConceptIcon(emoji: reward.icon, size: 46),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroPill(
                      icon: isMine
                          ? Icons.hourglass_top_rounded
                          : Icons.mark_email_unread_outlined,
                      label: isMine
                          ? t.rewardsStatusPending
                          : t.rewardsStatusReview,
                      color: accent,
                      background: accent.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        height: 1.3,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 15,
                          color: accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.cost}',
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isMine
                                ? t.rewardsWaitingPartnerDecision
                                : t.rewardsStatusReview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isMine) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: accent.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsDivider(int availableCoins) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase.withValues(
              alpha: theme.isDarkMode ? 0.14 : 0.03,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // TweenAnimationBuilder retargets from the currently shown
                // value whenever the balance changes, so redemptions and
                // bonuses count up/down instead of jumping.
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: availableCoins.toDouble(),
                    end: availableCoins.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 620),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedCoins, _) => Text(
                    t.rewardsCoinsAvailableShort(animatedCoins.round()),
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.25,
                      height: 1.05,
                      fontFeatures: kTabularFigures,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.rewardsCoinsAvailableToRedeem,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              t.rewardsBalance,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsGrid(List<RewardModel> rewards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - (AppSpacing.lg * 2);
        final columns = viewportWidth >= 280 ? 2 : 1;
        final cardWidth =
            (viewportWidth - (12 * (columns - 1))).clamp(0, double.infinity) /
                columns;
        final cardHeight = columns == 2 ? 186.0 : 198.0;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: rewards
              .map(
                (reward) => SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: _buildRewardCard(reward),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildRewardCard(RewardModel reward) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final balanceData = ref.watch(userBalanceProvider).value;
    final userBalance = (balanceData?['coins'] as num?) ?? 0;
    final canAfford = userBalance >= reward.cost;
    final buttonAccent = canAfford ? theme.primary : theme.textMuted;
    final title = localizedRewardTitle(t, reward);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surface,
            theme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.55),
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmRedeem(reward, canAfford),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Stack(
            children: [
              Positioned(
                top: -4,
                right: 2,
                child: IconButton(
                  tooltip: t.rewardsDeleteTooltip,
                  onPressed: () => _confirmDeleteReward(reward),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: theme.textMuted.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: Center(
                        child: ConceptIcon(emoji: reward.icon, size: 46),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.14,
                            color: theme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? theme.primary.withValues(alpha: 0.12)
                            : theme.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: canAfford
                              ? theme.primary.withValues(alpha: 0.18)
                              : theme.border.withValues(alpha: 0.65),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.monetization_on_rounded,
                            size: 13,
                            color: buttonAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.rewardsPrizeCostCoins(reward.cost),
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: buttonAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          AppEmptyState(
            title: t.rewardsEmptyBoutique,
            subtitle: t.rewardsEmptyNoPrizes,
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _seedDefaultCatalog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: Text(
              t.rewardsLoadSuggested,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _showCreateRewardSheet,
            child: Text(
              t.rewardsOrCreateCustom,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seedDefaultCatalog() async {
    final t = AppLocalizations.of(context);
    final result = await ref.read(rewardsProvider.notifier).seedDefaults();
    if (!mounted) return;
    result.fold(
      (failure) {
        AppHaptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (count) {
        if (count == 0) {
          // Ya había filas (por ejemplo propuestas pendientes): avisar en vez
          // de dejar un botón que aparenta no hacer nada.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.rewardsSeedNothingNew)),
          );
        }
      },
    );
  }

  Widget _buildActionButtons() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.isDarkMode
              ? [
                  theme.elevatedSurface,
                  theme.surface,
                ]
              : const [
                  Color(0xFFFFFBF7),
                  Color(0xFFFFF4EB),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.rewardsAddNewDesirePrompt,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.rewardsAddNewDesireHint,
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              height: 1.35,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showSuggestRewardSheet,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: Text(
                t.rewardsSuggestNewDesire,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteReward(RewardModel reward) async {
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: Text(t.rewardsDeletePrompt),
        content: Text(t.rewardsDeleteBody(localizedRewardTitle(t, reward))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              t.commonCancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      AppHaptics.warning();
      final result =
          await ref.read(rewardsProvider.notifier).deleteReward(reward.id);
      if (!mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        ),
        (_) {},
      );
    }
  }

  Future<void> _confirmRedeem(RewardModel reward, bool canAfford) async {
    final t = AppLocalizations.of(context);
    final title = localizedRewardTitle(t, reward);

    if (!canAfford) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.rewardsInsufficientCoins),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => RedeemRewardDialog(
        title: title,
        icon: reward.icon,
        cost: reward.cost,
        onCancel: () => Navigator.pop(dialogCtx, false),
        onConfirm: () => Navigator.pop(dialogCtx, true),
      ),
    );

    if (confirmed != true || !mounted) return;
    await _redeemReward(reward, title);
  }

  Future<void> _redeemReward(RewardModel reward, String title) async {
    final result = await ref.read(rewardsProvider.notifier).redeem(reward.id);
    if (!mounted) return;

    await result.fold(
      (failure) async {
        AppHaptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
        _refreshRewardState();
      },
      (_) async {
        _applyRewardRedemptionLocally(reward, title);
        _refreshRewardState();
        if (!mounted) return;
        _showSuccessAnim(reward, title);
      },
    );
  }

  void _applyRewardRedemptionLocally(RewardModel reward, String title) {
    final currentBalance = ref.read(userBalanceProvider).value;
    final householdId = ref.read(householdIdProvider).value;
    if (currentBalance != null && householdId != null) {
      final currentCoins = (currentBalance['coins'] as num?)?.toInt() ?? 0;
      ref.read(userBalanceOverrideProvider.notifier).state = {
        ...currentBalance,
        '_household_id': householdId,
        'coins': (currentCoins - reward.cost).clamp(0, 1 << 31),
      };
    }

    ref.read(optimisticRecentActivityProvider.notifier).addRewardRedeemed(
          title: title,
          icon: reward.icon,
          cost: reward.cost,
        );
  }

  void _refreshRewardState() {
    ref.invalidate(rewardsProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(recentActivityProvider);
  }

  void _showSuccessAnim(RewardModel reward, String title) {
    final t = AppLocalizations.of(context);
    SuccessCelebration.show(
      context,
      title: t.rewardsRedeemed,
      message: t.rewardsRedeemedBody(title),
      icon: reward.icon,
    );
  }

  void _showCreateRewardSheet() {
    _showRewardEditor(isSuggestion: false);
  }

  void _showSuggestRewardSheet() {
    _showRewardEditor(isSuggestion: true);
  }

  void _showProposalDecisionSheet(RewardModel reward) {
    AppSheet.show(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = context.theme;
        final t = AppLocalizations.of(context);
        final title = localizedRewardTitle(t, reward);
        final description = localizedRewardDescription(t, reward) ??
            t.rewardsWaitingPartnerDecision;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: ConceptIcon(emoji: reward.icon, size: 42),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.sectionTitle.copyWith(
                          height: 1.1,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  t.rewardsApprovalReason,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description.trim(),
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.rewardsCostLabel(reward.cost),
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resolveProposal(reward, approve: false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                        ),
                        child: Text(
                          t.rewardsRemove,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resolveProposal(reward, approve: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                        ),
                        child: Text(
                          t.rewardsApprove,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _resolveProposal(
    RewardModel reward, {
    required bool approve,
  }) async {
    final t = AppLocalizations.of(context);
    final title = localizedRewardTitle(t, reward);
    final notifier = ref.read(rewardsProvider.notifier);
    final result = approve
        ? await notifier.approveReward(reward.id)
        : await notifier.deleteReward(reward.id);
    if (!mounted) return;
    result.fold(
      (failure) {
        AppHaptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {
        if (approve) {
          AppHaptics.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.rewardsApprovedSnack(title))),
          );
        }
      },
    );
  }

  void _showRewardEditor({required bool isSuggestion}) {
    final t = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    String selectedIcon = '💝';
    String selectedCategory = 'mimos';
    bool isSubmitting = false;
    const icons = [
      '💝',
      '💆',
      '🍫',
      '🎬',
      '🍷',
      '🛁',
      '🌅',
      '🎁',
      '☕',
      '✨',
      '🍽️',
      '💌',
    ];
    const categories = ['mimos', 'momentos', 'libertades', 'experiencias'];

    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = context.theme;
          OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                borderSide: BorderSide(color: color),
              );

          return Container(
            padding: EdgeInsets.only(
              left: 28,
              right: 28,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.viewPaddingOf(context).bottom +
                  32,
            ),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.divider,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                    ),
                    Text(
                      isSuggestion
                          ? t.rewardsSuggestTitle
                          : t.rewardsNewHouseReward,
                      textAlign: TextAlign.center,
                      style: AppTypography.sectionTitle.copyWith(
                        fontSize: 22,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      t.rewardsTitleLabel,
                      style: AppTypography.eyebrow.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: titleController,
                      validator: (value) {
                        final title = value?.trim() ?? '';
                        if (title.isEmpty) {
                          return t.rewardsTitleRequiredError;
                        }
                        if (title.length < 3) {
                          return t.rewardsTitleMinLengthError;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: t.rewardsTitleHint,
                        filled: true,
                        fillColor: theme.surface,
                        border:
                            inputBorder(theme.border.withValues(alpha: 0.4)),
                        enabledBorder:
                            inputBorder(theme.border.withValues(alpha: 0.42)),
                        focusedBorder:
                            inputBorder(theme.primary.withValues(alpha: 0.72)),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isSuggestion
                          ? t.rewardsNoteOptionalLabel
                          : t.rewardsDescriptionLabel,
                      style: AppTypography.eyebrow.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: isSuggestion
                            ? t.rewardsDescriptionSuggestionHint
                            : t.rewardsDescriptionPrizeHint,
                        filled: true,
                        fillColor: theme.surface,
                        border:
                            inputBorder(theme.border.withValues(alpha: 0.4)),
                        enabledBorder:
                            inputBorder(theme.border.withValues(alpha: 0.42)),
                        focusedBorder:
                            inputBorder(theme.primary.withValues(alpha: 0.72)),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.rewardsCostFieldLabel,
                      style: AppTypography.eyebrow.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final cost = int.tryParse((value ?? '').trim());
                        if (cost == null) return t.rewardsCostValidationInvalid;
                        if (cost <= 0) return t.rewardsCostValidationMin;
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: t.rewardsCostHint,
                        prefixIcon: const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.sage,
                        ),
                        filled: true,
                        fillColor: theme.surface,
                        border:
                            inputBorder(theme.border.withValues(alpha: 0.4)),
                        enabledBorder:
                            inputBorder(theme.border.withValues(alpha: 0.42)),
                        focusedBorder:
                            inputBorder(theme.primary.withValues(alpha: 0.72)),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.rewardsCategoryFieldLabel,
                      style: AppTypography.eyebrow.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final selected = selectedCategory == category;
                        return ChoiceChip(
                          label: Text(
                            localizedRewardCategoryByKey(
                              t,
                              null,
                              category,
                            ),
                          ),
                          selected: selected,
                          onSelected: isSubmitting
                              ? null
                              : (_) => setModalState(
                                    () => selectedCategory = category,
                                  ),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.14),
                          backgroundColor: theme.surface,
                          labelStyle: TextStyle(
                            color:
                                selected ? theme.primary : theme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : Colors.transparent,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      t.rewardsIconLabel.toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: icons.map((icon) {
                          final selected = selectedIcon == icon;
                          return GestureDetector(
                            onTap: isSubmitting
                                ? null
                                : () =>
                                    setModalState(() => selectedIcon = icon),
                            child: Container(
                              margin:
                                  const EdgeInsets.only(right: AppSpacing.sm),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.10)
                                    : theme.surface,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ConceptIcon(emoji: icon, size: 34),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final isValid =
                                  formKey.currentState?.validate() ?? false;
                              if (!isValid) return;

                              final cost =
                                  int.tryParse(costController.text.trim()) ?? 0;

                              setModalState(() => isSubmitting = true);
                              final result = await ref
                                  .read(rewardsProvider.notifier)
                                  .suggestReward(
                                    title: titleController.text.trim(),
                                    description: descriptionController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : descriptionController.text.trim(),
                                    cost: cost,
                                    icon: selectedIcon,
                                    category: selectedCategory,
                                  );

                              if (!mounted) return;

                              result.fold(
                                (failure) {
                                  setModalState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(failure.message),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                },
                                (_) {
                                  Navigator.pop(context);
                                  _showSentToast(isSuggestion);
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isSuggestion
                                  ? t.rewardsSendProposal
                                  : t.rewardsCreatePrize,
                              style: AppTypography.cardTitle.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSentToast(bool isSuggestion) {
    final t = AppLocalizations.of(context);
    AppHaptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuggestion ? t.rewardsProposalSentToast : t.rewardsPrizeCreatedToast,
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    );
  }

  String _getNormalizedCategory(String? category) {
    final lower = (category ?? 'otros').toLowerCase().trim();
    if (lower == 'mimos' || lower == 'caricias') return 'mimos';
    if (lower == 'momentos' || lower == 'momentos juntos' || lower == 'ocio') {
      return 'momentos';
    }
    if (lower == 'libertades' || lower == 'favores' || lower == 'comodidades') {
      return 'libertades';
    }
    if (lower == 'experiencias' || lower == 'experiencias grandes') {
      return 'experiencias';
    }
    return 'otros';
  }
}
