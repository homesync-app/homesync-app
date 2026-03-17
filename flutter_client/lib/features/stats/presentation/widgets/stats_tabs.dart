import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
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
    final theme = context.theme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.jumbo),
        children: [
          // ── Weekly Duel ──────────────────────────────────────────────────
          const SectionLabel(label: 'Duelo de la semana', icon: '⚔️'),
          const SizedBox(height: AppSpacing.md),
          
          if (weeklyRanking.isNotEmpty) ...[
            AIFaceoffWidget(weeklyRanking: weeklyRanking),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── Summary row (Global context) ──────────────────────────────────
          const SectionLabel(label: 'Resumen del hogar', icon: '🏠'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MiniStatCard(
                  icon: '🔥',
                  value: '$totalTasks',
                  label: 'Tareas',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MiniStatCard(
                  icon: '✨',
                  value: '$totalXp',
                  label: 'XP',
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MiniStatCard(
                  icon: '💰',
                  value: '$totalCoins',
                  label: 'Coins',
                  color: AppColors.accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Duel History ─────────────────────────────────────────────────
          if (duelHistory.isNotEmpty) ...[
            const SectionLabel(label: 'Historial de victorias', icon: '🏆'),
            const SizedBox(height: AppSpacing.md),
            DuelHistoryWidget(duelHistory: duelHistory),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── Activity Placeholder ──────────────────────────────────────────
          const SectionLabel(label: 'Detalles del hogar', icon: '🕒'),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
              boxShadow: theme.cardShadow,
            ),
            child: Column(
              children: [
                Icon(Icons.auto_awesome_outlined, color: AppColors.primary.withValues(alpha: 0.3), size: 32),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Revisá el muro para ver la\nactividad detallada minuto a minuto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const PrivacyBadge(text: 'Las estadísticas son totalmente privadas para tu hogar. Solo vos y tu pareja pueden ver estos datos.'),
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
    final theme = context.theme;
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
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.jumbo),
        children: [
          // ── Header ───────────────────────────────────────────────────────
          const SectionLabel(label: 'Tu evolución personal', icon: '📈'),
          const SizedBox(height: AppSpacing.md),
          
          // ── XP / Coins toggle ────────────────────────────────────────────
          Row(
            children: [
              XPToggleButton(
                label: 'XP',
                isSelected: _showXp,
                color: AppColors.accentGold,
                onTap: () => setState(() => _showXp = true),
              ),
              const SizedBox(width: AppSpacing.sm),
              XPToggleButton(
                label: 'Coins',
                isSelected: !_showXp,
                color: AppColors.accentTeal,
                onTap: () => setState(() => _showXp = false),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Chart ──────────────────────────────────────────────────────
          Container(
            height: 240,
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: theme.cardShadow,
              border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
            ),
            child: spots.length < 2 || spots.every((s) => s.y == 0)
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌱', style: TextStyle(fontSize: 32)),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Empezá a completar tareas\npara ver tu progreso.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
                          tooltipBorderRadius: BorderRadius.circular(12),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((s) {
                              return LineTooltipItem(
                                '${s.y.toInt()} ${_showXp ? 'XP' : 'Coins'}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
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
                          color: Colors.black.withValues(alpha: 0.03),
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
                          curveSmoothness: 0.35,
                          color: color,
                          barWidth: 5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: color,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.15),
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
          const SizedBox(height: AppSpacing.xl),

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
              const SizedBox(width: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.xl),

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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Text('📊', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insights_outlined, size: 18, color: AppColors.textMuted.withValues(alpha: 0.5)),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.textMuted.withValues(alpha: 0.5)),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.auto_graph_outlined, size: 18, color: AppColors.textMuted.withValues(alpha: 0.5)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Todavía no hay datos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Completá algunas tareas para ver\ntus áreas de dominio.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Actualizar datos'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.jumbo),
        children: [
          // ── Premium Dominance Header ─────────────────────────────────────
          const SectionLabel(label: 'Dominio de Categorías', icon: '💎'),
          const SizedBox(height: AppSpacing.lg),

          // ── Horizontal bar chart (Modernized) ────────────────────────────
          CategoryBarChart(taskStats: taskStats),
          const SizedBox(height: AppSpacing.xl),

          // ── Elegant breakdown list ───────────────────────────────────────
          const SectionLabel(label: 'Desglose detallado', icon: '✨'),
          const SizedBox(height: AppSpacing.md),
          ...taskStats.map((stat) => CategoryDetailCard(stat: stat)),
          
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Text('💡', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text(
                    'Balancear las categorías ayuda a mantener un hogar más armonioso y divertido.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
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
