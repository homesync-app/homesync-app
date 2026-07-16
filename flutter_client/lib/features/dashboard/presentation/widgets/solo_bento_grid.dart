import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/domain/models/solo_progress_snapshot.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/spent_bento_tile.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

/// Bento-style summary grid for the solo home dashboard.
///
/// Two tiles only — monthly spending (taps through to Finances) and XP level
/// with the progress rendered as a ring. The pending-task count deliberately
/// does NOT live here: the tasks section right below already shows the day's
/// workload, and duplicating the number gave the screen three indicators of
/// the same fact.
///
/// Solo has no second member, so there is no balance/debt and no coins
/// economy; XP levelling stays presentation-only (derived from raw XP).
class SoloBentoGrid extends StatelessWidget {
  /// Personal spend for the current month. `null` means still loading (shows
  /// a shimmer); `0` renders a friendly empty message instead of a stark $0.
  final double? monthlySpent;
  final SoloProgressSnapshot progress;
  final VoidCallback? onSpentTap;

  const SoloBentoGrid({
    super.key,
    required this.monthlySpent,
    required this.progress,
    this.onSpentTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SizedBox(
      height: 158,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 13,
            child: SpentBentoTile(
              label: t.homeSoloBalanceLabel,
              amount: monthlySpent,
              onTap: onSpentTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 9,
            child: _LevelTile(
              level: progress.level,
              xpInLevel: progress.xpInLevel,
              xpPerLevel: SoloProgressSnapshot.xpPerLevel,
              progress: progress.levelProgress,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final int xpInLevel;
  final int xpPerLevel;
  final double progress;

  const _LevelTile({
    required this.level,
    required this.xpInLevel,
    required this.xpPerLevel,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: theme.border.withValues(alpha: 0.55)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) => CustomPaint(
                painter: _LevelRingPainter(
                  progress: animatedProgress,
                  trackColor: theme.primary.withValues(alpha: 0.12),
                  startColor: theme.primary,
                  endColor: AppColors.accentGold,
                ),
                child: child,
              ),
              child: Center(
                child: Text(
                  '$level',
                  style: AppTypography.sectionTitle.copyWith(
                    fontSize: 19,
                    height: 1.0,
                    color: theme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.homeSoloLevelEyebrow.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(
              fontSize: 10.5,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$xpInLevel',
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '/$xpPerLevel ${t.balanceCardXpLabel}',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color startColor;
  final Color endColor;

  const _LevelRingPainter({
    required this.progress,
    required this.trackColor,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Apple-Fitness-style floor: any progress > 0 shows a legible arc instead
    // of a sliver.
    final sweepFraction = math.max(progress.clamp(0.0, 1.0), 0.04);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [startColor, endColor],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepFraction * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_LevelRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}
