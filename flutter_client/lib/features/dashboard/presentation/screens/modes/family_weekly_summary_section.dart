import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

class FamilyWeeklySummarySection extends ConsumerWidget {
  const FamilyWeeklySummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final statsAsync = ref.watch(statsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWeeklySummaryBlock(context, theme, statsAsync),
        const SizedBox(height: 24),
        _buildWeeklyRankingBlock(context, theme, statsAsync, ref),
      ],
    );
  }

  Widget _buildWeeklySummaryBlock(
    BuildContext context,
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
          (sum, member) => sum + (member['xp_earned'] as num? ?? 0).toInt(),
        ) ??
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
                AppLocalizations.of(context).familyWeeklyTitle,
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
                label: AppLocalizations.of(context).familyWeeklyMetricPoints,
                value: totalXp.toString(),
                icon: Icons.stars_rounded,
                color: AppColors.accentGold,
              ),
              _buildSummaryDivider(theme),
              _buildSummaryItem(
                theme,
                label: AppLocalizations.of(context).familyWeeklyMetricTasks,
                value: completedTasks.toString(),
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              _buildSummaryDivider(theme),
              _buildSummaryItem(
                theme,
                label: AppLocalizations.of(context).familyWeeklyMetricStatus,
                value: completedTasks > 5
                    ? AppLocalizations.of(context).familyWeeklyStatusActive
                    : AppLocalizations.of(context).familyWeeklyStatusCalm,
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
    BuildContext context,
    AppThemeColors theme,
    AsyncValue<StatsData?> statsAsync,
    WidgetRef ref,
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
            .where((m) => m.isAdult || m.isTeen || m.isChild)
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
              AppLocalizations.of(context).familyWeeklyRankingTitle,
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
                  AppLocalizations.of(context).familyWeeklyRankingSubtitle,
                  style: TextStyle(fontSize: 10, color: theme.textSecondary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _RankingCategoryFilter(
          ranking: displayRanking,
          isLive: isLive,
          theme: theme,
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
  final AppThemeColors theme;

  const _RankingCategoryFilter({
    required this.ranking,
    required this.isLive,
    required this.theme,
  });

  @override
  State<_RankingCategoryFilter> createState() => _RankingCategoryFilterState();
}

class _RankingCategoryFilterState extends State<_RankingCategoryFilter> {
  int _selectedTab = 0;

  List<String> _tabLabels(AppLocalizations t) => [
        t.familyWeeklyRankingTabAll,
        t.familyWeeklyRankingTabAdults,
        t.familyWeeklyRankingTabKids,
      ];

  List<Map<String, dynamic>> _filteredRanking() {
    if (_selectedTab == 0) return widget.ranking;
    if (_selectedTab == 1) {
      return widget.ranking.where((item) {
        final type = item['member_type'] as String?;
        return type == 'parent' || type == 'guardian';
      }).toList();
    }
    const targetType = 'child';
    return widget.ranking
        .where((item) => (item['member_type'] as String?) == targetType)
        .toList();
  }

  String _displayName(Map<String, dynamic> item) {
    final name = item['user_name'] as String? ?? '';
    if (name.isNotEmpty) {
      return name.split(' ').first;
    }
    return AppLocalizations.of(context).familyWeeklyRankingMemberFallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final t = AppLocalizations.of(context);
    final tabs = _tabLabels(t);
    final filtered = _filteredRanking();
    final hasAdults = widget.ranking.any((i) {
      final type = i['member_type'] as String?;
      return type == 'parent' || type == 'guardian';
    });
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
                children: List.generate(tabs.length, (i) {
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
                          tabs[i],
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
                        ? t.familyWeeklyRankingEmptyMessage
                        : t.familyWeeklyRankingTabEmptyMessage(
                            tabs[_selectedTab],
                          ),
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
                  t.familyWeeklyRankingEmptyMessage,
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
