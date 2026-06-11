import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:intl/intl.dart';

/// Personal summary card for the solo home dashboard.
///
/// Replaces the couple-oriented BalanceCard in solo mode. Solo has no second
/// member, so there is no balance/debt/settlement and no coins economy (coins
/// can't be spent without a reward approver). Instead this card shows the two
/// metrics that have standalone meaning for a single user:
///   - Real monthly spending ("Gastado este mes").
///   - XP as a personal progression metric, with a simple derived level.
///
/// XP levelling is presentation-only (derived from the existing XP value); no
/// backend leveling system exists yet. Coins are intentionally not shown.
class SoloSummaryCard extends ConsumerWidget {
  final double? monthlySpent;
  final int xp;

  const SoloSummaryCard({
    super.key,
    required this.monthlySpent,
    required this.xp,
  });

  /// XP required to advance one level (flat curve, presentation-only).
  static const int _xpPerLevel = 500;

  int get _level => (xp ~/ _xpPerLevel) + 1;
  int get _xpInLevel => xp % _xpPerLevel;
  double get _levelProgress => _xpInLevel / _xpPerLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final spent = monthlySpent ?? 0.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.surface, theme.elevatedSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.border.withValues(alpha: 0.68)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase.withValues(alpha: 0.036),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Monthly spending ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.homeSoloBalanceLabel.toUpperCase(),
                        style: TextStyle(
                          color: theme.textSecondary.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedAmount(
                        value: spent,
                        locale: currency.locale,
                        prefix: currency.inputPrefix(),
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _LevelBadge(level: _level),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 14),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.border.withValues(alpha: 0.32),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFE8943A),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.homeSoloXpCaption,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${NumberFormat.decimalPattern(currency.locale).format(_xpInLevel)}'
                        ' / ${NumberFormat.decimalPattern(currency.locale).format(_xpPerLevel)} '
                        '${t.balanceCardXpLabel}',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                    child: LinearProgressIndicator(
                      value: _levelProgress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                          const Color(0xFFE8943A).withValues(alpha: 0.14),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE8943A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.homeSoloLevelEyebrow.toUpperCase(),
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$level',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
