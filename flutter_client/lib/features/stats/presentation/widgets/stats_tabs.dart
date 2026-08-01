import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';

import 'personal_metric_card.dart';
import 'stats_shared_widgets.dart';

class ProgressTab extends StatefulWidget {
  final List<Map<String, dynamic>> xpHistory;
  final List<Map<String, dynamic>> coinHistory;
  final List<Map<String, dynamic>> memberStats;

  /// En pareja no hay economía de coins, así que la curva queda solo en XP y
  /// el toggle desaparece en vez de ofrecer una serie siempre en cero.
  final bool showCoins;
  final Future<void> Function() onRefresh;

  const ProgressTab({
    super.key,
    required this.xpHistory,
    required this.coinHistory,
    required this.memberStats,
    required this.onRefresh,
    this.showCoins = true,
  });

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  bool _showXpState = true; // toggle between XP and Coins

  /// Sin economía de coins la única serie posible es XP, sin importar lo que
  /// haya quedado guardado en el toggle antes de cambiar de hogar.
  bool get _showXp => widget.showCoins ? _showXpState : true;

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
    final t = AppLocalizations.of(context);
    final spots = _showXp
        ? _buildSpots(widget.xpHistory)
        : _buildSpots(widget.coinHistory);
    final maxY = spots.fold<double>(0, (m, s) => math.max(m, s.y)) * 1.3;
    final color = _showXp ? AppColors.accentGold : AppColors.accentTeal;

    final currentUserId = AppIdentityService.instance.currentUserId;
    final currentUserStats = widget.memberStats.firstWhere(
      (m) => m['user_id'] == currentUserId,
      orElse: () => {},
    );

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.jumbo,
        ),
        children: [
          // ── Header ───────────────────────────────────────────────────────
          SectionLabel(label: t.personalEvolutionTitle, icon: '📈'),
          const SizedBox(height: AppSpacing.md),

          // ── XP / Coins toggle ────────────────────────────────────────────
          if (widget.showCoins) ...[
            Row(
              children: [
                XPToggleButton(
                  label: t.statsXP,
                  isSelected: _showXp,
                  color: AppColors.accentGold,
                  onTap: () => setState(() => _showXpState = true),
                ),
                const SizedBox(width: AppSpacing.sm),
                XPToggleButton(
                  label: t.statsCoins,
                  isSelected: !_showXp,
                  color: AppColors.accentTeal,
                  onTap: () => setState(() => _showXpState = false),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Chart ──────────────────────────────────────────────────────
          Container(
            height: 240,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.modal),
              boxShadow: theme.cardShadow,
              border: Border.all(color: theme.border.withValues(alpha: 0.45)),
            ),
            child: spots.length < 2 || spots.every((s) => s.y == 0)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌱', style: AppTypography.body.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                        ),),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          t.statsNoDataMessage,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : TweenAnimationBuilder<double>(
                    // Draw-in: the line grows up from the baseline on entry
                    // and whenever the XP/coins toggle swaps the dataset.
                    key: ValueKey(_showXp),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, reveal, _) => LineChart(
                      duration: AppMotion.slow,
                      curve: AppMotion.standard,
                      LineChartData(
                        minY: 0,
                        maxY: maxY,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => theme.textPrimary,
                            tooltipBorderRadius: BorderRadius.circular(14),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((s) {
                                return LineTooltipItem(
                                  '${s.y.toInt()} ${_showXp ? t.statsXP : t.statsCoins}',
                                  TextStyle(
                                    color: theme.surface,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    fontFeatures: kTabularFigures,
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
                            color: theme.textPrimary.withValues(alpha: 0.04),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: const FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots
                                .map((s) => FlSpot(s.x, s.y * reveal))
                                .toList(),
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: color,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 4,
                                color: theme.surface,
                                strokeWidth: 3,
                                strokeColor: color,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: 0.18 * reveal),
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
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Multi-info Cards ─────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: PersonalMetricCard(
                  icon: '🔥',
                  label: t.statsStreak,
                  value: t.statsStreakDays('7'),
                  color: Colors.orange,
                  subtitle: t.statsStreakMessage,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PersonalMetricCard(
                  icon: '📈',
                  label: t.statsLevel,
                  value:
                      '${((currentUserStats['xp_earned'] as num? ?? 0) / 1000).floor() + 1}',
                  color: AppColors.primary,
                  subtitle: t.statsXPToNextLevel(
                    '${1000 - ((currentUserStats['xp_earned'] as num? ?? 0) % 1000).toInt()}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Privacy assurance ───────────────────────────────────────────
          PrivacyBadge(text: t.statsPrivacyDetailed),
        ],
      ),
    );
  }
}
