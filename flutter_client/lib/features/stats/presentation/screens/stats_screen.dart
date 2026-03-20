import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/stats/presentation/widgets/widgets.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['Semana', 'Evolucion', 'Logros'];

  late TabController _tabController;

  bool _isLoading = true;
  List<Map<String, dynamic>> _taskStats = [];
  List<Map<String, dynamic>> _memberStats = [];
  List<Map<String, dynamic>> _weeklyRanking = [];
  List<Map<String, dynamic>> _xpHistory = [];
  List<Map<String, dynamic>> _coinHistory = [];
  List<Map<String, dynamic>> _duelHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final rpc = ref.read(rpcServiceProvider);
      final results = await Future.wait([
        rpc.getTaskStatsByCategory(),
        rpc.getMemberActivityStats(),
        rpc.getWeeklyRanking(),
        rpc.getXpHistory(),
        rpc.getCoinHistory(),
        rpc.getWeeklyDuelHistory(),
      ]);

      if (mounted) {
        setState(() {
          _taskStats = results[0];
          _memberStats = results[1];
          _weeklyRanking = results[2];
          _xpHistory = results[3];
          _coinHistory = results[4];
          _duelHistory = results[5];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _totalTasksCompleted {
    final fromTasks = _taskStats.fold(
      0,
      (s, e) => s + ((e['completed_count'] as num?)?.toInt() ?? 0),
    );
    if (fromTasks > 0) {
      return fromTasks;
    }

    return _memberStats.fold(
      0,
      (s, e) => s + ((e['tasks_completed'] as num?)?.toInt() ?? 0),
    );
  }

  int get _totalXpEarned {
    final fromTasks = _taskStats.fold(
      0,
      (s, e) => s + ((e['total_xp'] as num?)?.toInt() ?? 0),
    );
    if (fromTasks > 0) {
      return fromTasks;
    }

    return _memberStats.fold(
      0,
      (s, e) => s + ((e['xp_earned'] as num?)?.toInt() ?? 0),
    );
  }

  int get _totalCoinsEarned => _memberStats.fold(
        0,
        (s, e) => s + ((e['coins_earned'] as num?)?.toInt() ?? 0),
      );

  String _getWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.day}/${monday.month} - ${sunday.day}/${sunday.month}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProfileProvider, (previous, next) {
      if (next.hasValue && previous?.value != next.value) {
        _loadStats();
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: AppSegmentedTabs(
            controller: _tabController,
            labels: _tabs,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    WeeklyProgressTab(
                      weeklyRanking: _weeklyRanking,
                      memberStats: _memberStats,
                      duelHistory: _duelHistory,
                      weekRange: _getWeekRange(),
                      totalTasks: _totalTasksCompleted,
                      totalXp: _totalXpEarned,
                      totalCoins: _totalCoinsEarned,
                      onRefresh: _loadStats,
                    ),
                    ProgressTab(
                      xpHistory: _xpHistory,
                      coinHistory: _coinHistory,
                      memberStats: _memberStats,
                      onRefresh: _loadStats,
                    ),
                    AchievementsTab(
                      memberStats: _memberStats,
                      taskStats: _taskStats,
                      onRefresh: _loadStats,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
