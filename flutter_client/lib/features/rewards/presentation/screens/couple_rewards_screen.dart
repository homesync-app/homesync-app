import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/widgets/concept_icon.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../household/presentation/providers/household_provider.dart';
import '../../../stats/presentation/widgets/weekly_progress_tab.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../domain/models/couple_challenge.dart';
import '../../domain/models/reward_model.dart';
import '../providers/reward_provider.dart';
import '../utils/reward_localization.dart';
import '../widgets/couple_challenge_card.dart';

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
    with SingleTickerProviderStateMixin {
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
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          ref
              .read(parejaTabIndexProvider.notifier)
              .setIndex(_tabController.index);
          if (_tabController.index == 1 && !_hasOpenedRewardsTab && mounted) {
            setState(() => _hasOpenedRewardsTab = true);
          }
        }
      });
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
        _tabController.addListener(() {
          if (!_tabController.indexIsChanging) {
            ref
                .read(parejaTabIndexProvider.notifier)
                .setIndex(_tabController.index);
            if (_tabController.index == 1 && !_hasOpenedRewardsTab && mounted) {
              setState(() => _hasOpenedRewardsTab = true);
            }
          }
        });
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

  Future<void> _loadDuelStats() async {
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
      final admin = ref.read(adminProvider);
      late final List<dynamic> mainResults;
      late final Future<dynamic> duelHistoryFuture;

      if (admin.isAdminUser) {
        final client = ref.read(supabaseClientProvider);
        mainResults = await Future.wait<dynamic>([
          client.rpc(
            'qa_admin_get_task_stats_by_category',
            params: {'p_household_id': widget.householdId},
          ),
          client.rpc(
            'qa_admin_get_member_activity_stats',
            params: {'p_household_id': widget.householdId},
          ),
          client.rpc(
            'qa_admin_get_weekly_ranking',
            params: {'p_household_id': widget.householdId},
          ),
        ]);
        duelHistoryFuture = client.rpc(
          'qa_admin_get_weekly_duel_history',
          params: {'p_household_id': widget.householdId},
        );
      } else {
        final rpc = ref.read(rpcServiceProvider);
        mainResults = await Future.wait<dynamic>([
          rpc.getTaskStatsByCategory(),
          rpc.getMemberActivityStats(),
          rpc.getWeeklyRanking(),
        ]);
        duelHistoryFuture = rpc.getWeeklyDuelHistory();
      }

      if (!mounted) return;
      setState(() {
        _taskStats = _mapList(mainResults[0]);
        _memberStats = _mapList(mainResults[1]);
        _weeklyRanking = _mapList(mainResults[2]);
        _isStatsLoading = false;
      });

      final duelHistory = await duelHistoryFuture;
      if (!mounted) return;
      setState(() => _duelHistory = _mapList(duelHistory));
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

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is List) {
      return List<Map<String, dynamic>>.from(value);
    }
    return const [];
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
      onRefresh: _loadDuelStats,
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
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ShimmerLoading(
          child: Container(
            height: 98,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const SizedBox(height: 14),
        ShimmerLoading(
          child: Container(
            height: 98,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(24),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
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
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
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
        final totalChallenges = CoupleChallenge.allChallenges.length;
        return CoupleChallengeCard(
          challenge: challenge,
          challengeNumber: challengeIndex + 1,
          totalChallenges: totalChallenges,
          onComplete: () => _handleChallengeCompletion(challenge, householdId),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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
          padding: const EdgeInsets.only(bottom: 24),
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
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
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
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: accent.withValues(alpha: 0.18),
            ),
            boxShadow: theme.cardShadow,
          ),
          padding: const EdgeInsets.all(16),
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
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
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
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
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
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                Text(
                  '$availableCoins coins',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Disponibles para canjear ahora',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Saldo',
              style: TextStyle(
                color: AppColors.accentGold,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.55),
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmRedeem(reward, canAfford),
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                top: -4,
                right: 2,
                child: IconButton(
                  tooltip: 'Eliminar recompensa',
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
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            style: TextStyle(
                              color: buttonAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.15,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          const AppEmptyState(
            title: 'Boutique vacia',
            subtitle: 'Todavia no hay premios cargados en esta casa.',
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                ref.read(rewardsProvider.notifier).cloneTemplates(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.10),
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Cargar premios sugeridos',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _showCreateRewardSheet,
            child: const Text(
              'O crear un premio personalizado',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = context.theme;
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Querés sumar un deseo nuevo?',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Proponelo y tu compañero podrá aprobarlo para que aparezca en la tienda.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showSuggestRewardSheet,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text(
                'Proponer un deseo nuevo',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.isDarkMode
                    ? theme.primary
                    : AppColors.sage.withValues(alpha: 0.16),
                foregroundColor:
                    theme.isDarkMode ? Colors.white : AppColors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 17),
                side: BorderSide(
                  color: theme.isDarkMode
                      ? theme.primary.withValues(alpha: 0.42)
                      : AppColors.sage.withValues(alpha: 0.22),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleChallengeCompletion(
    CoupleChallenge challenge,
    String householdId,
  ) async {
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(t.rewardsChallengeCompletePrompt),
        content: Text(
          t.rewardsChallengeCompleteBody(challenge.coinReward),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              t.rewardsNotYet,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(t.rewardsYesWeDid),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _executeChallengeCompletion(challenge, householdId);
    }
  }

  Future<void> _executeChallengeCompletion(
    CoupleChallenge challenge,
    String householdId,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final t = AppLocalizations.of(context);
    try {
      final members = ref.read(householdMembersProvider).value ?? [];
      final userIds = members.map((m) => m.userId).toList();
      final currentUserId = ref.read(currentUserIdProvider);
      if (userIds.isEmpty && currentUserId != null) {
        userIds.add(currentUserId);
      }

      final challengeTitle = challenge.localizedTitle(t);
      final challengeDescription = challenge.localizedDescription(t);
      final challengeCategory = challenge.localizedCategory(t);
      final taskRpc = ref.read(taskRpcServiceProvider);
      final newTaskId = await taskRpc.createTask(
        title: t.rewardsChallengeTitle(challengeTitle),
        description: challengeDescription,
        category: challengeCategory,
        coinReward: challenge.coinReward,
        xpReward: 10,
        type: 'one_time',
      );

      final rpc = ref.read(rpcServiceProvider);
      await rpc.completeTaskTransaction(
        taskId: newTaskId,
        taskTitle: t.rewardsChallengeTitle(challengeTitle),
        xpReward: 10,
        coinReward: challenge.coinReward,
        householdId: householdId,
        userIds: userIds,
      );

      if (!mounted) return;
      Navigator.pop(context);
      SuccessCelebration.show(
        context,
        title: t.rewardsChallengeCompleted,
        message: t.rewardsChallengeCompletedBody(challenge.coinReward),
        icon: '\u2728',
      );
      ref.invalidate(userBalanceProvider);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.rewardsChallengeError(e.toString())),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteReward(RewardModel reward) async {
    final t = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.rewardsDeletePrompt),
        content: Text(t.rewardsDeleteBody(reward.title)),
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(rewardsProvider.notifier).deleteReward(reward.id);
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
      builder: (dialogCtx) => _RedeemRewardDialog(
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
    showModalBottomSheet(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                      borderRadius: BorderRadius.circular(999),
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
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Motivo para aprobarlo',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description.trim(),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.rewardsCostLabel(reward.cost),
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref
                              .read(rewardsProvider.notifier)
                              .deleteReward(reward.id);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Quitar',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref
                              .read(rewardsProvider.notifier)
                              .approveReward(reward.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Aprobar',
                          style: TextStyle(fontWeight: FontWeight.w900),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final theme = context.theme;
          OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
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
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: theme.divider,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Text(
                      isSuggestion
                          ? 'Proponer un deseo'
                          : 'Nuevo premio de la casa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'TITULO',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: titleController,
                      validator: (value) {
                        final title = value?.trim() ?? '';
                        if (title.isEmpty)
                          return 'Escribe el nombre del deseo.';
                        if (title.length < 3)
                          return 'Usa al menos 3 caracteres.';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Ej: Masaje de 20 minutos',
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
                      isSuggestion ? 'NOTA (OPCIONAL)' : 'DESCRIPCION',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: isSuggestion
                            ? 'Agregá un detalle si querés (opcional)'
                            : 'Un detalle corto para describir el premio',
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
                      'COSTO',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final cost = int.tryParse((value ?? '').trim());
                        if (cost == null) return 'Ingresa un costo valido.';
                        if (cost <= 0) return 'Debe costar al menos 1 coin.';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Costo en coins',
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
                      'CATEGORIA',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
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
                      'ICONO',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
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
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withValues(alpha: 0.10)
                                    : theme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 30),
                              ),
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
                                  ? 'Enviar propuesta'
                                  : 'Crear premio',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuggestion ? 'Propuesta enviada.' : 'Premio creado con exito.',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

class _RedeemRewardDialog extends StatelessWidget {
  const _RedeemRewardDialog({
    required this.title,
    required this.icon,
    required this.cost,
    required this.onCancel,
    required this.onConfirm,
  });

  final String title;
  final String icon;
  final int cost;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 18),
            Text(
              t.rewardsRedeemPrompt,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.rewardsRedeemDialogBody(title, cost),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      t.commonCancel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      t.rewardsRedeem,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 140.ms, curve: Curves.easeOutCubic).scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1, 1),
            duration: 210.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
