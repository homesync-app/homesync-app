import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

import '../../domain/models/couple_challenge.dart';
import '../../domain/models/reward_model.dart';
import '../providers/reward_provider.dart';
import '../widgets/couple_challenge_card.dart';
import '../../../household/presentation/providers/household_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../stats/presentation/widgets/weekly_progress_tab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoupleRewardsScreen extends ConsumerStatefulWidget {
  final String householdId;

  const CoupleRewardsScreen({
    super.key,
    required this.householdId,
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: ref.read(parejaTabIndexProvider),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(parejaTabIndexProvider.notifier)
            .setIndex(_tabController.index);
      }
    });
    _loadDuelStats();
  }

  @override
  void didUpdateWidget(covariant CoupleRewardsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.householdId != widget.householdId) {
      _taskStats = [];
      _memberStats = [];
      _weeklyRanking = [];
      _duelHistory = [];
      _loadDuelStats();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDuelStats() async {
    if (mounted) {
      setState(() => _isStatsLoading = true);
    }

    try {
      final admin = ref.read(adminProvider);
      late final List<dynamic> results;

      if (admin.isAdminUser) {
        final client = Supabase.instance.client;
        results = await Future.wait<dynamic>([
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
          client.rpc(
            'qa_admin_get_weekly_duel_history',
            params: {'p_household_id': widget.householdId},
          ),
        ]);
      } else {
        final rpc = ref.read(rpcServiceProvider);
        results = await Future.wait<dynamic>([
          rpc.getTaskStatsByCategory(),
          rpc.getMemberActivityStats(),
          rpc.getWeeklyRanking(),
          rpc.getWeeklyDuelHistory(),
        ]);
      }

      if (!mounted) return;
      setState(() {
        _taskStats = _mapList(results[0]);
        _memberStats = _mapList(results[1]);
        _weeklyRanking = _mapList(results[2]);
        _duelHistory = _mapList(results[3]);
        _isStatsLoading = false;
      });
    } catch (_) {
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
    ref.listen<int>(parejaTabIndexProvider, (previous, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    final rewardsAsync = ref.watch(rewardsProvider);
    final currentUserId = ref.read(currentUserIdProvider);
    final theme = context.theme;

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
                labels: const ['Duelo', 'Premios'],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDuelTab(),
                  rewardsAsync.when(
                    data: (rewards) {
                      final activeRewards =
                          rewards.where((r) => r.isActive).toList();
                      final availableCoins =
                          ref.watch(userBalanceProvider).value?['coins'] ?? 0;
                      final approvedRewards =
                          activeRewards.where((r) => r.isApproved == true).toList();
                      final suggestions =
                          activeRewards.where((r) => r.isApproved == false).toList();

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () =>
                            ref.read(rewardsProvider.notifier).refresh(),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            2,
                            AppSpacing.lg,
                            132,
                          ),
                          children: [
                            _buildChallengeSection(widget.householdId),
                            const SizedBox(height: 18),
                            _buildCoinsDivider(availableCoins),
                            const SizedBox(height: 32),
                            if (approvedRewards.isEmpty)
                              _buildEmptyState()
                            else
                              _buildGroupedRewards(approvedRewards),
                            if (suggestions.isNotEmpty) ...[
                              const SizedBox(height: 28),
                              _buildPendingProposalsSection(
                                  suggestions, currentUserId),
                            ],
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                          ],
                        ),
                      );
                    },
                    loading: () =>
                        const AppLoadingState(message: 'Cargando premios...'),
                    error: (e, _) => AppErrorState(
                      message: 'No pudimos cargar premios.\n$e',
                      onRetry: () => ref.invalidate(rewardsProvider),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuelTab() {
    if (_isStatsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
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
                        _getCategoryDisplayTitle(category),
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
      List<RewardModel> suggestions, String? currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Propuestas',
          subtitle:
              'Deseos pendientes de aprobacion. Toca una propuesta para revisarla.',
          action: _buildCountPill('${suggestions.length}'),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width - (AppSpacing.lg * 2);
            final columns = viewportWidth >= 280 ? 2 : 1;
            final cardWidth = (viewportWidth - (12 * (columns - 1)))
                    .clamp(0, double.infinity) /
                columns;
            final cardHeight = columns == 2 ? 208.0 : 220.0;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: suggestions
                  .map(
                    (reward) => SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildProposalCard(reward, currentUserId),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProposalCard(RewardModel reward, String? currentUserId) {
    final theme = context.theme;
    final isMine = reward.createdBy == currentUserId;
    final accent = isMine ? AppColors.primary : AppColors.accentPurple;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildHeroPill(
                      icon: isMine
                          ? Icons.hourglass_top_rounded
                          : Icons.mark_email_unread_outlined,
                      label: isMine ? 'Pendiente' : 'Revisar',
                      color: accent,
                      background: accent.withValues(alpha: 0.10),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        reward.icon,
                        style: const TextStyle(fontSize: 23),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reward.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (reward.description ?? 'Esperando una decision de tu pareja.')
                      .trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? theme.surfaceVariant
                        : AppColors.accentPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isMine
                        ? '${reward.cost} coins - esperando respuesta'
                        : '${reward.cost} coins - toca para aprobar o quitar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isMine ? theme.textSecondary : AppColors.accentPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinsDivider(int availableCoins) {
    final theme = context.theme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
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
          Text(
            '$availableCoins coins disponibles',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
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
    final userBalance = ref.watch(userBalanceProvider).value?['coins'] ?? 0;
    final canAfford = userBalance >= reward.cost;
    final buttonAccent = canAfford ? theme.primary : theme.textMuted;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surface,
            AppColors.surfaceVariant,
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
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        reward.icon,
                        style: const TextStyle(fontSize: 29),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: Text(
                          reward.title,
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
                            '${reward.cost} coins',
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
        gradient: const LinearGradient(
          colors: [
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
                backgroundColor: AppColors.sage.withValues(alpha: 0.16),
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 17),
                side: BorderSide(
                  color: AppColors.sage.withValues(alpha: 0.22),
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
      CoupleChallenge challenge, String householdId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Completaron el desafío?'),
        content: Text(
          'Qué alegría. Al confirmar, ambos recibirán ${challenge.coinReward} coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Aún no',
              style: TextStyle(color: AppColors.textSecondary),
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
            child: const Text('Sí, lo hicimos'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _executeChallengeCompletion(challenge, householdId);
    }
  }

  Future<void> _executeChallengeCompletion(
      CoupleChallenge challenge, String householdId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final members = ref.read(householdMembersNotifierProvider).value ?? [];
      final userIds = members.map((m) => m.userId).toList();
      final currentUserId = ref.read(currentUserIdProvider);
      if (userIds.isEmpty && currentUserId != null) {
        userIds.add(currentUserId);
      }

      final taskRpc = TaskRpcService();
      final newTaskId = await taskRpc.createTask(
        title: 'Desafío: ${challenge.title}',
        description: challenge.description,
        category: 'Conexión',
        coinReward: challenge.coinReward,
        xpReward: 10,
        type: 'one_time',
      );

      final rpc = ref.read(rpcServiceProvider);
      await rpc.completeTaskTransaction(
        taskId: newTaskId,
        taskTitle: 'Desafío: ${challenge.title}',
        xpReward: 10,
        coinReward: challenge.coinReward,
        householdId: householdId,
        userIds: userIds,
      );

      if (!mounted) return;
      Navigator.pop(context);
      SuccessCelebration.show(
        context,
        title: 'Desafío completado',
        message:
            'Ambos ganaron ${challenge.coinReward} coins. Sigan cultivando su conexión.',
        icon: '✨',
      );
      ref.invalidate(userBalanceProvider);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al completar el desafío: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteReward(RewardModel reward) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar premio?'),
        content: Text('Se eliminará "${reward.title}" de la boutique.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(rewardsProvider.notifier).deleteReward(reward.id);
    }
  }

  void _confirmRedeem(RewardModel reward, bool canAfford) {
    if (!canAfford) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coins insuficientes. A completar tareas.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Canjear este premio?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reward.icon, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              reward.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ref.read(rewardsProvider.notifier).redeem(reward.id).then((_) {
                if (!mounted) return;
                ref.invalidate(userBalanceProvider);
                _showSuccessAnim(reward);
              }).catchError((e) {
                if (!mounted) return;
                final errStr = e.toString().replaceFirst('Exception: ', '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $errStr'),
                    backgroundColor: AppColors.error,
                  ),
                );
                ref.invalidate(userBalanceProvider);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Canjear'),
          ),
        ],
      ),
    );
  }

  void _showSuccessAnim(RewardModel reward) {
    SuccessCelebration.show(
      context,
      title: 'Premio canjeado',
      message:
          'Disfruta de "${reward.title}". El amor también vive en los pequeños detalles.',
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
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        reward.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reward.title,
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
                  (reward.description ?? 'Sin motivo adicional.').trim(),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Costo: ${reward.cost} coins',
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
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    String selectedIcon = '??';
    String selectedCategory = 'mimos';
    bool isSubmitting = false;
    const icons = [
      '??',
      '??',
      '??',
      '??',
      '??',
      '??',
      '??',
      '??',
      '??',
      '???',
    ];
    const categories = ['mimos', 'momentos', 'libertades', 'experiencias'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: context.theme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
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
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    isSuggestion
                        ? 'Proponer un deseo'
                        : 'Nuevo premio de la casa',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'TITULO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                      if (title.isEmpty) return 'Escribe el nombre del deseo.';
                      if (title.length < 3) return 'Usa al menos 3 caracteres.';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Ej: Masaje de 20 minutos',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isSuggestion ? 'POR QUE DEBERIA APROBARLO' : 'DESCRIPCION',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 2,
                    validator: (value) {
                      if (!isSuggestion) return null;
                      final description = value?.trim() ?? '';
                      if (description.length < 8) {
                        return 'Cuenta un poco mas para que sea facil evaluarlo.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: isSuggestion
                          ? 'Explica por que tu pareja deberia aprobar este deseo'
                          : 'Un detalle corto para describir el premio',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'COSTO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CATEGORIA',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                        label: Text(_getCategoryDisplayTitle(category)),
                        selected: selected,
                        onSelected: isSubmitting
                            ? null
                            : (_) => setModalState(
                                () => selectedCategory = category),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.14),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
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
                  const Text(
                    'ICONO',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                              : () => setModalState(() => selectedIcon = icon),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.10)
                                  : context.theme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(icon,
                                style: const TextStyle(fontSize: 30)),
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
                                  description:
                                      descriptionController.text.trim().isEmpty
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
                      backgroundColor: AppColors.textPrimary,
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
                            isSuggestion ? 'Enviar propuesta' : 'Crear premio',
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
        ),
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

  String _getCategoryDisplayTitle(String category) {
    switch (category) {
      case 'mimos':
        return 'Mimos';
      case 'momentos':
        return 'Momentos juntos';
      case 'libertades':
        return 'Libertades';
      case 'experiencias':
        return 'Experiencias grandes';
      default:
        return 'Otros';
    }
  }
}
