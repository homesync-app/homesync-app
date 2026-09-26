import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/faceoff_widget.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

import 'stats_shared_widgets.dart';

class WeeklyProgressTab extends ConsumerWidget {
  final List<Map<String, dynamic>> weeklyRanking;
  final List<Map<String, dynamic>> memberStats;
  final List<Map<String, dynamic>> duelHistory;
  final String weekRange;
  final int totalTasks;
  final int totalXp;
  final int totalCoins;
  final bool showHeader;
  final Future<void> Function() onRefresh;

  const WeeklyProgressTab({
    super.key,
    required this.weeklyRanking,
    required this.memberStats,
    required this.duelHistory,
    required this.weekRange,
    required this.totalTasks,
    required this.totalXp,
    required this.totalCoins,
    this.showHeader = true,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final caps = ref.watch(householdCapabilitiesProvider);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.jumbo,
        ),
        children: [
          if (showHeader) ...[
            _WeeklyHeaderCard(weekRange: weekRange),
            const SizedBox(height: AppSpacing.lg),
          ],
          // En pareja el reparto de la semana vive en la pestaña Pareja: acá no
          // hay duelo ni un segundo lugar donde mirar lo mismo.
          if (caps.showsWeeklyDuelCard && weeklyRanking.isNotEmpty) ...[
            AIFaceoffWidget(
              weeklyRanking: weeklyRanking,
              duelHistory: duelHistory,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          SectionLabel(label: t.statsHouseholdSummary, icon: '•'),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.modal),
              border: Border.all(color: theme.border.withValues(alpha: 0.45)),
              boxShadow: theme.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: '🔥',
                    value: '$totalTasks',
                    label: t.statsTasksLabel(totalTasks),
                    color: AppColors.primary,
                  ),
                ),
                if (caps.showsHouseholdXpTotals) ...[
                  _metricDivider(context),
                  Expanded(
                    child: _SummaryMetric(
                      icon: '✨',
                      value: '$totalXp',
                      label: t.statsXP,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
                if (caps.usesCoinEconomy) ...[
                  _metricDivider(context),
                  Expanded(
                    child: _SummaryMetric(
                      icon: '💰',
                      value: '$totalCoins',
                      label: t.statsCoins,
                      color: AppColors.accentTeal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // El historial de duelos muestra "tu XP - el de tu pareja" con un
          // ganador. Los hogares de pareja conservan filas viejas en
          // weekly_duel_history para auditoría, así que sin este gate el duelo
          // sigue a la vista aunque ya no se generen duelos nuevos.
          if (caps.showsWeeklyDuelCard && duelHistory.isNotEmpty) ...[
            SectionLabel(label: t.statsWeeklyHistory, icon: '•'),
            const SizedBox(height: AppSpacing.md),
            DuelHistoryWidget(duelHistory: duelHistory),
            const SizedBox(height: AppSpacing.xl),
          ],
          PrivacyBadge(text: t.statsPrivacyMessage),
        ],
      ),
    );
  }

  Widget _metricDivider(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: 1,
      height: 50,
      color: theme.divider.withValues(alpha: theme.isDarkMode ? 0.35 : 0.6),
    );
  }
}

class _WeeklyHeaderCard extends StatelessWidget {
  final String weekRange;

  const _WeeklyHeaderCard({required this.weekRange});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.isDarkMode
              ? [
                  theme.elevatedSurface,
                  theme.surface,
                ]
              : const [
                  Color(0xFFFFFBF7),
                  Color(0xFFFFF4EB),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.statsWeeklyProgressTitle,
            style: AppTypography.heroAmount.copyWith(
              fontSize: 24,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.statsWeeklyProgressSubtitle,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.isDarkMode
                  ? theme.surfaceVariant.withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              '${t.statsCurrentWeek} · $weekRange',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      children: [
        Text(
          icon,
          style: AppTypography.body.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.sectionTitle.copyWith(
            fontSize: 22,
            letterSpacing: -0.8,
            height: 1,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
