import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// rpc accessed via rpcServiceProvider
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/faceoff_widget.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                    _WeeklyTab(
                      weeklyRanking: _weeklyRanking,
                      memberStats: _memberStats,
                      duelHistory: _duelHistory,
                      weekRange: _getWeekRange(),
                      totalTasks: _totalTasksCompleted,
                      totalXp: _totalXpEarned,
                      totalCoins: _totalCoinsEarned,
                      onRefresh: _loadStats,
                    ),
                    _ProgressTab(
                      xpHistory: _xpHistory,
                      coinHistory: _coinHistory,
                      memberStats: _memberStats,
                      onRefresh: _loadStats,
                    ),
                    _CategoriesTab(
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

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — Semana: Ranking semanal + resumen de actividad
// ═════════════════════════════════════════════════════════════════════════════

class _WeeklyTab extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyRanking;
  final List<Map<String, dynamic>> memberStats;
  final List<Map<String, dynamic>> duelHistory;
  final String weekRange;
  final int totalTasks;
  final int totalXp;
  final int totalCoins;
  final Future<void> Function() onRefresh;

  const _WeeklyTab({
    required this.weeklyRanking,
    required this.memberStats,
    required this.duelHistory,
    required this.weekRange,
    required this.totalTasks,
    required this.totalXp,
    required this.totalCoins,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          // ── Weekly Duel ──────────────────────────────────────────────────
          _SectionLabel(label: 'Duelo Semanal ($weekRange)', icon: '⚔️'),
          const SizedBox(height: 16),

          if (weeklyRanking.isNotEmpty) ...[
            AIFaceoffWidget(weeklyRanking: weeklyRanking),
            const SizedBox(height: 28),
          ],

          // ── Summary row (Global context) ──────────────────────────────────
          const _SectionLabel(label: 'Contexto del hogar', icon: '🏠'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: _MiniStatCard(
                    icon: '✅',
                    value: '$totalTasks',
                    label: 'Tareas',
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: _MiniStatCard(
                    icon: '⭐',
                    value: '$totalXp',
                    label: 'Total XP',
                    color: AppColors.accentGold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 700),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: _MiniStatCard(
                    icon: '🪙',
                    value: '$totalCoins',
                    label: 'Coins',
                    color: AppColors.accentTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Duel History ─────────────────────────────────────────────────
          if (duelHistory.isNotEmpty) ...[
            const _SectionLabel(label: 'Historial de duelos', icon: '🏆'),
            const SizedBox(height: 16),
            _DuelHistoryWidget(duelHistory: duelHistory),
            const SizedBox(height: 28),
          ],

          // ── Activity History (Home-like) ──────────────────────────────
          const _SectionLabel(label: 'Actividad reciente', icon: '🕒'),
          const SizedBox(height: 16),
          Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(24),
               border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
             ),
             child: const Center(
               child: Text(
                 'Revisá el muro para ver la actividad detallada',
                 style: TextStyle(color: AppColors.textMuted, fontSize: 13),
               ),
             ),
          ),
        ],
      ),
    );
  }
}

// Eliminated _UserSummaryCard as requested by the user.

// Weekly duel bar chart
class _WeeklyDuelCard extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyRanking;
  const _WeeklyDuelCard({required this.weeklyRanking});

  @override
  Widget build(BuildContext context) {
    final maxXp = weeklyRanking.fold<double>(
      0,
      (max, p) => math.max(max, (p['xp_earned'] as num?)?.toDouble() ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text('🏆', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DUELO DE LA SEMANA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentGold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'XP acumulados esta semana',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxXp <= 0 ? 10 : maxXp * 1.3,
                barGroups: weeklyRanking.asMap().entries.map((e) {
                  final idx = e.key;
                  final xp = (e.value['xp_earned'] as num?)?.toDouble() ?? 0;
                  final isLeader = idx == 0;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: xp <= 0 ? 0.5 : xp,
                        width: 40,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        gradient: LinearGradient(
                          colors: isLeader
                              ? [AppColors.primary, AppColors.accentTeal]
                              : [
                                  AppColors.textMuted.withValues(alpha: 0.5),
                                  AppColors.textMuted.withValues(alpha: 0.3),
                                ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= weeklyRanking.length) {
                          return const SizedBox.shrink();
                        }
                        final xp = weeklyRanking[idx]['xp_earned'] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '$xp XP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: idx == 0
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= weeklyRanking.length) {
                          return const SizedBox.shrink();
                        }
                        final name =
                            weeklyRanking[idx]['user_name'] as String? ??
                                'P${idx + 1}';
                        final short = name.split(' ').first;
                        final isLeader = idx == 0;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              if (isLeader)
                                const Text('👑',
                                    style: TextStyle(fontSize: 14)),
                              Text(
                                short,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isLeader
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isLeader
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border.withValues(alpha: 0.3),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — Progreso: Línea temporal de XP + Coins
// ═════════════════════════════════════════════════════════════════════════════

class _ProgressTab extends StatefulWidget {
  final List<Map<String, dynamic>> xpHistory;
  final List<Map<String, dynamic>> coinHistory;
  final List<Map<String, dynamic>> memberStats;
  final Future<void> Function() onRefresh;

  const _ProgressTab({
    required this.xpHistory,
    required this.coinHistory,
    required this.memberStats,
    required this.onRefresh,
  });

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  bool _showXp = true; // toggle between XP and Coins

  List<FlSpot> _buildSpots(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return [const FlSpot(0, 0)];
    final last14 = history.take(14).toList().reversed.toList();
    return last14.asMap().entries.map((e) {
      final value = (e.value['amount'] as num?)?.toDouble() ?? 0;
      return FlSpot(e.key.toDouble(), value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spots = _showXp
        ? _buildSpots(widget.xpHistory)
        : _buildSpots(widget.coinHistory);
    final maxY = spots.fold<double>(0, (m, s) => math.max(m, s.y)) * 1.3;
    final color = _showXp ? AppColors.accentGold : AppColors.accentTeal;

    final currentUserStats = widget.memberStats.firstWhere(
      (m) => m['user_id'] == Supabase.instance.client.auth.currentUser?.id,
      orElse: () => {},
    );

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          // ── Header ───────────────────────────────────────────────────────
          const _SectionLabel(label: 'Tu evolución personal', icon: '📈'),
          const SizedBox(height: 16),
          
          // ── XP / Coins toggle ────────────────────────────────────────────
          Row(
            children: [
              _XPToggleButton(
                label: 'XP',
                isSelected: _showXp,
                color: AppColors.accentGold,
                onTap: () => setState(() => _showXp = true),
              ),
              const SizedBox(width: 12),
              _XPToggleButton(
                label: 'Coins',
                isSelected: !_showXp,
                color: AppColors.accentTeal,
                onTap: () => setState(() => _showXp = false),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Chart ──────────────────────────────────────────────────────
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: spots.length < 2 || spots.every((s) => s.y == 0)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 12),
                        const Text(
                          'Empezá a completar tareas\npara ver tu progreso.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.textPrimary,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((s) {
                              return LineTooltipItem(
                                '${s.y.toInt()} ${_showXp ? 'XP' : 'Coins'}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: const FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: color,
                          barWidth: 6,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: color,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.25),
                                color.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 28),

          // ── Multi-info Cards ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: _PersonalMetricCard(
                    icon: '🔥',
                    label: 'Racha',
                    value: '7 días',
                    color: Colors.orange,
                    subtitle: '¡Vas con todo!',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 700),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: _PersonalMetricCard(
                    icon: '📈',
                    label: 'Nivel',
                    value: '${((currentUserStats['xp_earned'] as num? ?? 0) / 1000).floor() + 1}',
                    color: AppColors.primary,
                    subtitle: '${1000 - ((currentUserStats['xp_earned'] as num? ?? 0) % 1000).toInt()} XP para subir',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Privacy assurance ───────────────────────────────────────────
          const _PrivacyBadge(
            text: 'Tus datos de progreso son privados y solo vos podés ver este historial detallado.',
          ),
        ],
      ),
    );
  }
}

class _XPToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _XPToggleButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _PersonalMetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _PersonalMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyBadge extends StatelessWidget {
  final String text;
  const _PrivacyBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — Categorías: Radar + lista detallada
// ═════════════════════════════════════════════════════════════════════════════

class _CategoriesTab extends StatelessWidget {
  final List<Map<String, dynamic>> taskStats;
  final Future<void> Function() onRefresh;

  const _CategoriesTab({
    required this.taskStats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (taskStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text(
              'Sin datos de categorías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completá tareas para ver estadísticas',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          // ── Header ───────────────────────────────────────────────────────
          const _SectionLabel(label: 'Tus preferencias', icon: '🏷️'),
          const SizedBox(height: 16),

          // ── Horizontal bar chart ─────────────────────────────────────────
          _CategoryBarChart(taskStats: taskStats),
          const SizedBox(height: 32),

          // ── Detailed list ────────────────────────────────────────────────
          const _SectionLabel(label: 'Desglose por categoría', icon: '📋'),
          const SizedBox(height: 16),
          ...taskStats.map((stat) => _CategoryDetailCard(stat: stat)),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 20)),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Podés ver qué categorías dominás más para equilibrar las tareas del hogar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
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
}

class _CategoryBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> taskStats;
  const _CategoryBarChart({required this.taskStats});

  @override
  Widget build(BuildContext context) {
    final sorted = [...taskStats]..sort((a, b) =>
        ((b['completed_count'] as num?) ?? 0)
            .compareTo((a['completed_count'] as num?) ?? 0));
    final top = sorted.take(6).toList();
    final maxVal = top.fold<double>(
      1,
      (m, e) => math.max(m, (e['completed_count'] as num?)?.toDouble() ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: top.map((stat) {
          final category = stat['category'] as String? ?? 'general';
          final count = (stat['completed_count'] as num?)?.toDouble() ?? 0;
          final xp = (stat['total_xp'] as num?)?.toInt() ?? 0;
          final pct = count / maxVal;
          final color = AppColors.getCategoryColor(category);
          final icon = AppColors.categoryIcons[category] ?? '📋';
          final name = AppColors.categoryNames[category] ?? category;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${count.toInt()} · $xp XP',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.02, 1.0),
                          minHeight: 8,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryDetailCard extends StatelessWidget {
  final Map<String, dynamic> stat;
  const _CategoryDetailCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final category = stat['category'] as String? ?? 'general';
    final count = (stat['completed_count'] as num?)?.toInt() ?? 0;
    final xp = (stat['total_xp'] as num?)?.toInt() ?? 0;
    final color = AppColors.getCategoryColor(category);
    final icon = AppColors.categoryIcons[category] ?? '📋';
    final name = AppColors.categoryNames[category] ?? category;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count tareas completadas',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '⭐ $xp XP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared small widgets
// ═════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  final String icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberRankCard extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> member;

  const _MemberRankCard({required this.rank, required this.member});

  @override
  Widget build(BuildContext context) {
    final rawName = member['user_name'] as String? ??
        member['user_email'] as String? ??
        'Miembro';
    // Use full_name if available, otherwise email prefix
    final name = rawName.contains('@') ? rawName.split('@').first : rawName;
    final firstName = name.split(' ').first;

    final tasks = (member['tasks_completed'] as num?)?.toInt() ?? 0;
    final xp = (member['xp_earned'] as num?)?.toInt() ?? 0;
    final coins = (member['coins_earned'] as num?)?.toInt() ?? 0;

    const medals = ['🥇', '🥈', '🥉'];
    final medal = rank <= 3 ? medals[rank - 1] : '#$rank';
    final isTop = rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isTop ? AppColors.accentGold.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isTop
              ? AppColors.accentGold.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medal
          SizedBox(
            width: 32,
            child: Center(
              child: Text(medal, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          // Avatar
          CustomUserAvatar(
            name: firstName,
            avatarUrl: member['avatar_url'],
            radius: 20,
          ),
          const SizedBox(width: 12),
          // Name + detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName,
                  style: TextStyle(
                    fontWeight: isTop ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$tasks tareas · $xp XP · $coins coins',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // XP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '⭐ $xp',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuelHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> duelHistory;

  const _DuelHistoryWidget({required this.duelHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: duelHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final duel = entry.value;
          final isLast = index == duelHistory.length - 1;
          
          final winnerName = (duel['winner_name'] as String? ?? 'Ganador').split(' ').first;
          final loserName = (duel['loser_name'] as String? ?? 'Perdedor').split(' ').first;
          final winnerXp = (duel['winner_xp'] as num?)?.toInt() ?? 0;
          final loserXp = (duel['loser_xp'] as num?)?.toInt() ?? 0;
          final userResult = duel['user_result'] as String? ?? 'neutral';
          final weekDate = duel['week_start_date'];
          
          String weekLabel = 'Semana pasada';
          if (weekDate != null) {
            try {
              final date = DateTime.parse(weekDate.toString());
              weekLabel = '${date.day}/${date.month}';
            } catch (_) {}
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isLast ? null : Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: userResult == 'win'
                          ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
                          : userResult == 'loss'
                              ? [Colors.red.shade400, Colors.red.shade300]
                              : [AppColors.textMuted.withValues(alpha: 0.3), AppColors.textMuted.withValues(alpha: 0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userResult == 'win' ? '🏆' : userResult == 'loss' ? '😢' : '⚔️',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            winnerName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: userResult == 'win' ? AppColors.success : AppColors.textPrimary,
                            ),
                          ),
                          const Text(' vs ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text(
                            loserName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        weekLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: userResult == 'win'
                        ? AppColors.success.withValues(alpha: 0.1)
                        : userResult == 'loss'
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppColors.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userResult == 'win' ? '✓' : userResult == 'loss' ? '✗' : '=',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: userResult == 'win'
                              ? AppColors.success
                              : userResult == 'loss'
                                  ? Colors.red
                                  : AppColors.accentGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$winnerXp - $loserXp',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: userResult == 'win'
                              ? AppColors.success
                              : userResult == 'loss'
                                  ? Colors.red.shade600
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
