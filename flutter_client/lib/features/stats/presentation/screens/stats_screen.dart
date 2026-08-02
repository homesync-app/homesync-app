import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/utils/app_scroll_physics.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_space_providers.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/stats/presentation/widgets/widgets.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  List<String> _getTabs(AppLocalizations t) =>
      [t.statsTabWeek, t.statsTabEvolution, t.statsTabAchievements];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _totalTasksCompleted(
    List<Map<String, dynamic>> taskStats,
    List<Map<String, dynamic>> memberStats,
  ) {
    final fromTasks = taskStats.fold(
      0,
      (s, e) => s + ((e['completed_count'] as num?)?.toInt() ?? 0),
    );
    if (fromTasks > 0) {
      return fromTasks;
    }

    return memberStats.fold(
      0,
      (s, e) => s + ((e['tasks_completed'] as num?)?.toInt() ?? 0),
    );
  }

  int _totalXpEarned(
    List<Map<String, dynamic>> taskStats,
    List<Map<String, dynamic>> memberStats,
  ) {
    final fromTasks = taskStats.fold(
      0,
      (s, e) => s + ((e['total_xp'] as num?)?.toInt() ?? 0),
    );
    if (fromTasks > 0) {
      return fromTasks;
    }

    return memberStats.fold(
      0,
      (s, e) => s + ((e['xp_earned'] as num?)?.toInt() ?? 0),
    );
  }

  int _totalCoinsEarned(List<Map<String, dynamic>> memberStats) =>
      memberStats.fold(
        0,
        (s, e) => s + ((e['coins_earned'] as num?)?.toInt() ?? 0),
      );

  /// El reparto de la semana vive en su propio provider, así que el
  /// pull-to-refresh de la pestaña tiene que arrastrarlo también.
  Future<void> _refreshWeekly() async {
    final householdId = ref.read(householdIdProvider).value;
    if (householdId != null && householdId.isNotEmpty) {
      ref.invalidate(householdContributionProvider(householdId));
    }
    await ref.read(statsControllerProvider.notifier).refresh();
  }

  String _getWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.day}/${monday.month} - ${sunday.day}/${sunday.month}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final statsAsync = ref.watch(statsControllerProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final isSolo = caps.type == HouseholdType.solo;

    ref.listen(userProfileProvider, (previous, next) {
      if (next.hasValue && previous?.value != next.value) {
        ref.read(statsControllerProvider.notifier).refresh();
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: AppSegmentedTabs(
            controller: _tabController,
            labels: _getTabs(t),
          ),
        ),
        Expanded(
          child: statsAsync.when(
            loading: () => const Center(
              child: AppLoader(),
            ),
            error: (_, __) => Center(
              child: TextButton(
                onPressed: () =>
                    ref.read(statsControllerProvider.notifier).refresh(),
                child: Text(t.statsRetry),
              ),
            ),
            data: (stats) => TabBarView(
              controller: _tabController,
              physics: const AppSnappyPagePhysics(),
              children: [
                WeeklyProgressTab(
                  weeklyRanking: stats.weeklyRanking,
                  memberStats: stats.memberActivity,
                  duelHistory: stats.duelHistory,
                  weekRange: _getWeekRange(),
                  totalTasks: _totalTasksCompleted(
                    stats.taskStats,
                    stats.memberActivity,
                  ),
                  totalXp:
                      _totalXpEarned(stats.taskStats, stats.memberActivity),
                  totalCoins: _totalCoinsEarned(stats.memberActivity),
                  onRefresh: _refreshWeekly,
                ),
                ProgressTab(
                  xpHistory: stats.xpHistory,
                  coinHistory: stats.coinHistory,
                  memberStats: stats.memberActivity,
                  showCoins: caps.usesCoinEconomy,
                  onRefresh: ref.read(statsControllerProvider.notifier).refresh,
                ),
                AchievementsTab(
                  memberStats: stats.memberActivity,
                  taskStats: stats.taskStats,
                  isSolo: isSolo,
                  xpScopeUserId: caps.showsHouseholdXpTotals
                      ? null
                      : ref.watch(currentUserIdProvider),
                  onRefresh: ref.read(statsControllerProvider.notifier).refresh,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
