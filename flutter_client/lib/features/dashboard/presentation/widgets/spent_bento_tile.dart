import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';
import 'package:intl/intl.dart';

/// Hero spending tile of the home bento grids (solo personal spend, family
/// shared spend). Renders the monthly amount over the hero gradient with a
/// month + running-daily-average footer and an arrow affordance.
///
/// States: `amount == null` → shimmer (loading must never masquerade as a
/// real $0); `amount == 0` → friendly empty message; otherwise the animated
/// amount. All currency inside the tile uses the symbol-prefix convention
/// (`inputPrefix()`), same as every hero amount in the app.
class SpentBentoTile extends ConsumerWidget {
  /// Eyebrow label, already localized (e.g. "Gastado este mes",
  /// "Gasto compartido del mes").
  final String label;
  final double? amount;
  final VoidCallback? onTap;

  const SpentBentoTile({
    super.key,
    required this.label,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final now = DateTime.now();
    final monthName = _capitalize(DateFormat.MMMM(t.localeName).format(now));
    final spent = amount;

    // The footer earns its slot: month name alone when empty, month plus the
    // running daily average once there is spending. The average uses the same
    // symbol-prefix convention as the hero amount right above it (inputPrefix,
    // like every hero amount in the app) — mixing it with the locale-suffix
    // `format()` style put two currency grammars inside one tile.
    final footerLabel = (spent != null && spent > 0)
        ? t.homeSoloSpentDailyAvg(
            monthName,
            '${currency.inputPrefix()}${NumberFormat.decimalPattern(currency.locale).format((spent / math.max(now.day, 1)).round())}',
          )
        : monthName;

    return Semantics(
      button: true,
      child: AnimatedPress(
        onTap: onTap,
        scale: 0.98,
        haptic: AppPressHaptic.selection,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.heroGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.xxl),
            border: Border.all(color: theme.border.withValues(alpha: 0.5)),
          ),
          child: Stack(
            children: [
              // Decorative soft orbs, echoes the rings/chips of the sibling
              // bento tiles.
              Positioned(
                right: -38,
                top: -38,
                child: _DecorOrb(
                  size: 110,
                  color: theme.primary.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                right: 16,
                bottom: -46,
                child: _DecorOrb(
                  size: 84,
                  color: theme.primary.withValues(alpha: 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(
                        fontSize: 10.5,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildAmount(theme, t, currency, spent),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            footerLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmount(
    AppThemeColors theme,
    AppLocalizations t,
    AppCurrency currency,
    double? spent,
  ) {
    // Loading: shimmer placeholder so a transient $0 never masquerades as a
    // real amount.
    if (spent == null) {
      return ShimmerLoading(
        child: Container(
          width: 120,
          height: 34,
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppRadii.xs),
          ),
        ),
      );
    }

    // True zero: a giant w900 $0 reads like broken data, greet it instead.
    if (spent == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          t.homeSoloSpentEmpty,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 17,
            color: theme.textSecondary,
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: AnimatedAmount(
        value: spent,
        locale: currency.locale,
        prefix: currency.inputPrefix(),
        style: TextStyle(
          color: theme.textPrimary,
          fontSize: 32,
          fontWeight: AppTypography.hero,
          letterSpacing: AppTypography.heroLetterSpacing,
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _DecorOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
