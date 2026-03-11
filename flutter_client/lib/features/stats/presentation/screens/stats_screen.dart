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

  int get _totalTasksCompleted => _taskStats.fold(
      0, (s, e) => s + ((e['completed_count'] as num?)?.toInt() ?? 0));

  int get _totalXpEarned =>
      _taskStats.fold(0, (s, e) => s + ((e['total_xp'] as num?)?.toInt() ?? 0));

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
        // Tab bar
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Semana'),
              Tab(text: 'Progreso'),
              Tab(text: 'Categorías'),
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
                    CategoriesTab(
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
