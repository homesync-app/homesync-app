import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/faceoff_widget.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';

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

  void _showLoveNoteDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeColors theme,
  ) {
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
            const Icon(Icons.favorite, color: Color(0xFFEF4444)),
            const SizedBox(width: 12),
            Text(
              t.loveNoteDialogTitle,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
              ),
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
            fillColor: const Color(0xFFEF4444).withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              t.commonCancel,
              style: TextStyle(color: theme.textMuted),
            ),
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
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            AIFaceoffWidget(weeklyRanking: weeklyRanking),
            const SizedBox(height: AppSpacing.xl),
          ],
          SectionLabel(label: t.statsHouseholdSummary, icon: '•'),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: theme.border.withValues(alpha: 0.45)),
              boxShadow: theme.cardShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: '🔥',
                    value: '$totalTasks',
                    label: t.statsTasks,
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
                borderRadius: BorderRadius.circular(32),
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
                    padding: const EdgeInsets.all(12),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isPremium
                                ? (theme.isDarkMode
                                        ? const Color(0xFFFECACA)
                                        : const Color(0xFFB91C1C))
                                    .withValues(
                                        alpha: theme.isDarkMode ? 0.82 : 0.7,)
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
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.statsWeeklyProgressTitle,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.statsWeeklyProgressSubtitle,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
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
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${t.statsCurrentWeek} · $weekRange',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
