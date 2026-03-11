import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/faceoff_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'stats_shared_widgets.dart';
import 'personal_metric_card.dart';
import 'category_widgets.dart';

class WeeklyTab extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyRanking;
  final List<Map<String, dynamic>> memberStats;
  final List<Map<String, dynamic>> duelHistory;
  final String weekRange;
  final int totalTasks;
  final int totalXp;
  final int totalCoins;
  final Future<void> Function() onRefresh;

  const WeeklyTab({
    super.key,
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
          SectionLabel(label: 'Duelo Semanal ($weekRange)', icon: '⚔️'),
          const SizedBox(height: 16),

          if (weeklyRanking.isNotEmpty) ...[
            AIFaceoffWidget(weeklyRanking: weeklyRanking),
            const SizedBox(height: 28),
          ],

          // ── Summary row (Global context) ──────────────────────────────────
          const SectionLabel(label: 'Contexto del hogar', icon: '🏠'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniStatCard(
                  icon: '✅',
                  value: '$totalTasks',
                  label: 'Tareas',
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniStatCard(
                  icon: '⭐',
                  value: '$totalXp',
                  label: 'Total XP',
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniStatCard(
                  icon: '🪙',
                  value: '$totalCoins',
                  label: 'Coins',
                  color: AppColors.accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Duel History ─────────────────────────────────────────────────
          if (duelHistory.isNotEmpty) ...[
            const SectionLabel(label: 'Historial de duelos', icon: '🏆'),
            const SizedBox(height: 16),
            DuelHistoryWidget(duelHistory: duelHistory),
            const SizedBox(height: 28),
          ],

          // ── Activity History (Home-like) ──────────────────────────────
          const SectionLabel(label: 'Actividad reciente', icon: '🕒'),
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

class ProgressTab extends StatefulWidget {
  final List<Map<String, dynamic>> xpHistory;
  final List<Map<String, dynamic>> coinHistory;
  final List<Map<String, dynamic>> memberStats;
  final Future<void> Function() onRefresh;

  const ProgressTab({
    super.key,
    required this.xpHistory,
    required this.coinHistory,
    required this.memberStats,
    required this.onRefresh,
  });

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
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
          const SectionLabel(label: 'Tu evolución personal', icon: '📈'),
          const SizedBox(height: 16),
          
          // ── XP / Coins toggle ────────────────────────────────────────────
          Row(
            children: [
              XPToggleButton(
                label: 'XP',
                isSelected: _showXp,
                color: AppColors.accentGold,
                onTap: () => setState(() => _showXp = true),
              ),
              const SizedBox(width: 12),
              XPToggleButton(
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
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌱', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 12),
                        Text(
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
                          dotData: const FlDotData(show: true),
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
              const Expanded(
                child: PersonalMetricCard(
                  icon: '🔥',
                  label: 'Racha',
                  value: '7 días',
                  color: Colors.orange,
                  subtitle: '¡Vas con todo!',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PersonalMetricCard(
                  icon: '📈',
                  label: 'Nivel',
                  value: '${((currentUserStats['xp_earned'] as num? ?? 0) / 1000).floor() + 1}',
                  color: AppColors.primary,
                  subtitle: '${1000 - ((currentUserStats['xp_earned'] as num? ?? 0) % 1000).toInt()} XP para subir',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Privacy assurance ───────────────────────────────────────────
          const PrivacyBadge(
            text: 'Tus datos de progreso son privados y solo vos podés ver este historial detallado.',
          ),
        ],
      ),
    );
  }
}

class CategoriesTab extends StatelessWidget {
  final List<Map<String, dynamic>> taskStats;
  final Future<void> Function() onRefresh;

  const CategoriesTab({
    super.key,
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
          const SectionLabel(label: 'Tus preferencias', icon: '🏷️'),
          const SizedBox(height: 16),

          // ── Horizontal bar chart ─────────────────────────────────────────
          CategoryBarChart(taskStats: taskStats),
          const SizedBox(height: 32),

          // ── Detailed list ────────────────────────────────────────────────
          const SectionLabel(label: 'Desglose por categoría', icon: '📋'),
          const SizedBox(height: 16),
          ...taskStats.map((stat) => CategoryDetailCard(stat: stat)),
          
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
