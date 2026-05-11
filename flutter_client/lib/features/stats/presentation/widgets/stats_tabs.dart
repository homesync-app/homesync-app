import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/faceoff_widget.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';

import 'category_widgets.dart';
import 'personal_metric_card.dart';
import 'stats_shared_widgets.dart';

class WeeklyTab extends ConsumerWidget {
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

  void _showLoveNoteDialog(
      BuildContext context, WidgetRef ref, AppThemeColors theme,) {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: theme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              t.loveNoteDialogTitle,
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: theme.textPrimary,),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: theme.textPrimary),
          decoration: InputDecoration(
            hintText: t.loveNoteHint,
            filled: true,
            fillColor: Colors.red.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.commonCancel, style: TextStyle(color: theme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = controller.text.trim();
              if (content.isEmpty) return;

              final currentUserId = ref.read(currentUserIdProvider);
              final householdId =
                  await ref.read(householdIdProvider.future);
              final members = ref
                      .read(householdMembersNotifierProvider)
                      .valueOrNull ??
                  [];
              final partner = members
                  .where((m) => m.userId != currentUserId)
                  .firstOrNull;

              if (currentUserId == null ||
                  householdId == null ||
                  partner == null) {
                return;
              }

              await ref.read(loveNotesProvider.notifier).sendNote(
                    content: content,
                    fromUserId: currentUserId,
                    toUserId: partner.userId,
                    householdId: householdId,
                  );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('💌 ${t.loveNoteSent}'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),),
            ),
            child: Text(t.commonSend),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.jumbo,),
        children: [
          // ── Weekly Duel ──────────────────────────────────────────────────
          SectionLabel(label: t.statsWeeklyDuel, icon: '⚔️'),
          const SizedBox(height: AppSpacing.md),

          if (weeklyRanking.isNotEmpty) ...[
            AIFaceoffWidget(weeklyRanking: weeklyRanking),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── Summary row (Global context) ──────────────────────────────────
          Text(
            t.statsHouseholdSummary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary.withValues(alpha: 0.9),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
              boxShadow: theme.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SummaryMetric(
                    icon: '🔥',
                    value: '$totalTasks',
                    label: t.statsTasks,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.black.withValues(alpha: 0.06),
                ),
                Expanded(
                  child: SummaryMetric(
                    icon: '✨',
                    value: '$totalXp',
                    label: t.statsXP,
                    color: AppColors.accentGold,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.black.withValues(alpha: 0.06),
                ),
                Expanded(
                  child: SummaryMetric(
                    icon: '💰',
                    value: '$totalCoins',
                    label: t.statsCoins,
                    color: AppColors.accentTeal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          GestureDetector(
            onTap: () {
              if (!isPremium) {
                PremiumPaywall.show(context);
              } else {
                HapticFeedback.lightImpact();
                _showLoveNoteDialog(context, ref, theme);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPremium
                      ? [const Color(0xFFFEE2E2), Colors.white]
                      : [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isPremium
                      ? const Color(0xFFFCA5A5).withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.04),
                ),
                boxShadow: theme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? const Color(0xFFFECACA)
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPremium ? Icons.favorite_rounded : Icons.lock_rounded,
                      color: isPremium
                          ? const Color(0xFFEF4444)
                          : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.loveNoteSendTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isPremium
                                ? const Color(0xFF991B1B)
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPremium
                              ? t.loveNoteSendSubtitle
                              : t.loveNotePremiumFeature,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isPremium
                                ? const Color(0xFFB91C1C).withValues(alpha: 0.7)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isPremium)
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColors.textMuted,),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── Duel History ─────────────────────────────────────────────────
          if (duelHistory.isNotEmpty) ...[
            SectionLabel(label: t.statsVictoryHistory, icon: '🏆'),
            const SizedBox(height: AppSpacing.md),
            DuelHistoryWidget(duelHistory: duelHistory),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ── Activity Placeholder ──────────────────────────────────────────
          PrivacyBadge(text: t.statsPrivacyFull),
        ],
      ),
    );
  }
}

class SummaryMetric extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const SummaryMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.8,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ],
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
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.jumbo,),
        children: [
          // ── Header ───────────────────────────────────────────────────────
          SectionLabel(label: t.personalEvolutionTitle, icon: '📈'),
          const SizedBox(height: AppSpacing.md),

          // ── XP / Coins toggle ────────────────────────────────────────────
          Row(
            children: [
              XPToggleButton(
                label: t.statsXP,
                isSelected: _showXp,
                color: AppColors.accentGold,
                onTap: () => setState(() => _showXp = true),
              ),
              const SizedBox(width: AppSpacing.sm),
              XPToggleButton(
                label: t.statsCoins,
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
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.md,),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: theme.cardShadow,
              border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
            ),
            child: spots.length < 2 || spots.every((s) => s.y == 0)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          t.statsNoDataMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                                '${s.y.toInt()} ${_showXp ? t.statsXP : t.statsCoins}',
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
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),),
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),),
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
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
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
                  subtitle: t.statsXPToNextLevel('${1000 - ((currentUserStats['xp_earned'] as num? ?? 0) % 1000).toInt()}'),
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
    final t = AppLocalizations.of(context);
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
                Icon(Icons.insights_outlined,
                    size: 18,
                    color: AppColors.textMuted.withValues(alpha: 0.5),),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.favorite_border_rounded,
                    size: 18,
                    color: AppColors.textMuted.withValues(alpha: 0.5),),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.auto_graph_outlined,
                    size: 18,
                    color: AppColors.textMuted.withValues(alpha: 0.5),),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              t.statsNoDataTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.statsNoDataSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm,),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),),
              ),
              child: Text(t.commonRefresh),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.jumbo,),
        children: [
          // ── Premium Dominance Header ─────────────────────────────────────
          SectionLabel(label: t.categoriesDominance, icon: '💎'),
          const SizedBox(height: AppSpacing.lg),

          // ── Horizontal bar chart (Modernized) ────────────────────────────
          CategoryBarChart(taskStats: taskStats),
          const SizedBox(height: AppSpacing.xl),

          // ── Elegant breakdown list ───────────────────────────────────────
          SectionLabel(label: t.categoriesBreakdown, icon: '✨'),
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
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
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
                      ),
                    ],
                  ),
                  child: const Text('💡', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    t.categoriesBalanceTip,
                    style: const TextStyle(
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
