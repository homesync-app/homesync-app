import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/stats/presentation/widgets/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StatsScreen — rediseñada con fl_chart y tabs de navegación
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
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
    _tabController = TabController(length: 3, vsync: this);
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Computed values ──────────────────────────────────────────────────────

  int get _totalTasksCompleted {
    final fromTasks = _taskStats.fold(
        0, (s, e) => s + ((e['completed_count'] as num?)?.toInt() ?? 0));
    if (fromTasks > 0) return fromTasks;

    final fromMembers = _memberStats.fold(
        0, (s, e) => s + ((e['tasks_completed'] as num?)?.toInt() ?? 0));
    return fromMembers;
  }

  int get _totalXpEarned {
    final fromTasks =
        _taskStats.fold(0, (s, e) => s + ((e['total_xp'] as num?)?.toInt() ?? 0));
    if (fromTasks > 0) return fromTasks;

    final fromMembers = _memberStats.fold(
        0, (s, e) => s + ((e['xp_earned'] as num?)?.toInt() ?? 0));
    return fromMembers;
  }

  int get _totalCoinsEarned => _memberStats.fold(
      0, (s, e) => s + ((e['coins_earned'] as num?)?.toInt() ?? 0));

  String _getWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${monday.day}/${monday.month} – ${sunday.day}/${sunday.month}';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el perfil (ej. cambio de avatar) para recargar datos
    ref.listen(userProfileProvider, (previous, next) {
      if (next.hasValue && previous?.value != next.value) {
        _loadStats();
      }
    });

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary.withValues(alpha: 0.5),
            indicatorSize: TabBarIndicatorSize.label,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary,
                  width: 3.5,
                ),
              ),
            ),
            labelPadding: const EdgeInsets.only(top: 12, bottom: 8),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: -0.4,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            tabs: const [
              Tab(text: 'Duelo'),
              Tab(text: 'Evolución'),
              Tab(text: 'Logros'),
            ],
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
                    WeeklyTab(
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
