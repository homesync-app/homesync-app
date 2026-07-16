import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

class XPToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const XPToggleButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? theme.surface : theme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: isSelected ? theme.cardShadow : [],
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : theme.textMuted,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyBadge extends StatelessWidget {
  final String text;
  const PrivacyBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;
  final String icon;
  const SectionLabel({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: AppSpacing.xxs, bottom: AppSpacing.xxs),
      child: Text(
        label,
        style: AppTypography.cardTitle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        boxShadow: theme.cardShadow,
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.heroAmount.copyWith(
              fontSize: 26,
              height: 1,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: AppTypography.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),),
          ),
        ],
      ),
    );
  }
}

class DuelHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> duelHistory;

  const DuelHistoryWidget({super.key, required this.duelHistory});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(color: theme.border.withValues(alpha: 0.38)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        children: duelHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final duel = entry.value;
          final isLast = index == duelHistory.length - 1;

          final winnerName =
              (duel['winner_name'] as String? ?? 'Ganador').split(' ').first;
          final loserName =
              (duel['loser_name'] as String? ?? 'Perdedor').split(' ').first;
          final winnerXp = (duel['winner_xp'] as num?)?.toInt() ?? 0;
          final loserXp = (duel['loser_xp'] as num?)?.toInt() ?? 0;
          final userResult = duel['user_result'] as String? ?? 'neutral';
          final weekDate = duel['week_start_date'];

          String weekLabel = 'Semana pasada';
          if (weekDate != null) {
            final date = DateTime.tryParse(weekDate.toString());
            if (date != null) {
              weekLabel = '${date.day}/${date.month}';
            }
          }

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: theme.border.withValues(alpha: 0.32),
                      ),
                    ),
            ),
            child: Row(
              children: [
                _DuelResultIcon(result: userResult),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: AppTypography.bodyStrong.copyWith(
                            fontSize: 14.5,
                            color: theme.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: winnerName,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: ' vs ',
                              style: AppTypography.caption.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: theme.textMuted,
                              ),
                            ),
                            TextSpan(
                              text: loserName,
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: theme.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            weekLabel,
                            style: AppTypography.caption.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainer.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: _resultAccent(userResult).withValues(alpha: 0.16),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _resultScoreIcon(userResult),
                        size: 15,
                        color: _resultAccent(userResult),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$winnerXp - $loserXp',
                        style: AppTypography.caption.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
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

  Color _resultAccent(String result) {
    return switch (result) {
      'win' => AppColors.primary,
      'loss' => AppColors.textMuted,
      _ => AppColors.accentGold,
    };
  }

  IconData _resultScoreIcon(String result) {
    return switch (result) {
      'win' => Icons.check_rounded,
      'loss' => Icons.arrow_downward_rounded,
      _ => Icons.remove_rounded,
    };
  }
}

class _DuelResultIcon extends StatelessWidget {
  const _DuelResultIcon({required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = switch (result) {
      'win' => AppColors.primary,
      'loss' => theme.textMuted,
      _ => AppColors.accentGold,
    };
    final icon = switch (result) {
      'win' => Icons.emoji_events_rounded,
      'loss' => Icons.flag_rounded,
      _ => Icons.sports_martial_arts_rounded,
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: result == 'loss' ? 0.08 : 0.10),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Icon(icon, color: accent, size: 21),
    );
  }
}
