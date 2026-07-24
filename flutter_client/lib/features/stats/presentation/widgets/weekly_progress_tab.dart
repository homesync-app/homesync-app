import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/faceoff_widget.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';

import 'love_note_dialog.dart';
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
    final isPremium = ref.watch(premiumProvider).value ?? false;

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
          if (weeklyRanking.isNotEmpty) ...[
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
                _metricDivider(context),
                Expanded(
                  child: _SummaryMetric(
                    icon: '✨',
                    value: '$totalXp',
                    label: t.statsXP,
                    color: AppColors.accentGold,
                  ),
                ),
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
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: () {
              if (!isPremium) {
                PremiumPaywall.show(context, source: 'weekly_progress');
              } else {
                AppHaptics.tap();
                showLoveNoteDialog(context: context, ref: ref);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPremium
                      ? theme.isDarkMode
                          ? [
                              const Color(0xFF3A2424),
                              const Color(0xFF2C1D1D),
                            ]
                          : [
                              const Color(0xFFFFF1F1),
                              const Color(0xFFFFFBFB),
                            ]
                      : [theme.surface, theme.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadii.modal),
                border: Border.all(
                  color: isPremium
                      ? (theme.isDarkMode
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFFCA5A5))
                          .withValues(alpha: theme.isDarkMode ? 0.18 : 0.4)
                      : theme.border.withValues(alpha: 0.45),
                ),
                boxShadow: theme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? (theme.isDarkMode
                              ? const Color(0xFF5B2B2B)
                              : const Color(0xFFFECACA))
                          : theme.textMuted.withValues(alpha: 0.12),
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
                          style: AppTypography.cardTitle.copyWith(
                            color: isPremium
                                ? (theme.isDarkMode
                                    ? const Color(0xFFFFD6D6)
                                    : const Color(0xFF991B1B))
                                : theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPremium
                              ? t.loveNoteSendSubtitle
                              : t.loveNotePremiumFeature,
                          style: AppTypography.caption.copyWith(
                            fontSize: 13,
                            color: isPremium
                                ? (theme.isDarkMode
                                        ? const Color(0xFFFECACA)
                                        : const Color(0xFFB91C1C))
                                    .withValues(
                                    alpha: theme.isDarkMode ? 0.82 : 0.7,
                                  )
                                : theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isPremium)
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (duelHistory.isNotEmpty) ...[
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
        Text(icon, style: AppTypography.body.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),),
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
