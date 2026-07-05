import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Editorial home header shared by the solo and family (adult) dashboards:
/// date eyebrow, time-of-day greeting and the user's first name oversized
/// with a primary-colored full stop. The avatar (or any other ornament) is
/// injected via [trailing] because each mode tunes its own avatar geometry.
///
/// Gender-neutral by design — the time-of-day greeting replaced the old
/// "Bienvenido/a" + feminine-name heuristic.
class HomeEditorialHeader extends StatelessWidget {
  final String? firstName;
  final Widget trailing;

  const HomeEditorialHeader({
    super.key,
    required this.firstName,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final dateLabel = DateFormat.MMMMEEEEd(t.localeName).format(now);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel.toUpperCase(),
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ).animateEntrance(),
              const SizedBox(height: 8),
              Text(
                _greetingForHour(now.hour, t),
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ).animateEntrance(delay: 40),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: firstName ?? t.commonUserFallback),
                    TextSpan(
                      text: '.',
                      style: TextStyle(color: theme.primary),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 33,
                  fontWeight: AppTypography.hero,
                  letterSpacing: AppTypography.heroLetterSpacing,
                  height: 1.05,
                ),
              ).animateEntrance(delay: 80),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        trailing,
      ],
    );
  }

  String _greetingForHour(int hour, AppLocalizations t) {
    if (hour >= 5 && hour < 13) return t.homeGreetingMorning;
    if (hour >= 13 && hour < 20) return t.homeGreetingAfternoon;
    return t.homeGreetingEvening;
  }
}
