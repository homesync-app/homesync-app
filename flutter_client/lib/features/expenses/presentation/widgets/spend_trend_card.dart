import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/presentation/providers/trend_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:intl/intl.dart';

/// Mini gráfico de barras con el gasto de los últimos 6 meses y el delta
/// contra el mes anterior. Se oculta solo hasta tener al menos dos meses con
/// datos (recién instalada la app no aporta nada).
class SpendTrendCard extends ConsumerWidget {
  const SpendTrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(monthlySpendTrendProvider);
    final points = trendAsync.value;
    if (points == null) return const SizedBox.shrink();

    final monthsWithData = points.where((p) => p.spent > 0).length;
    if (monthsWithData < 2) return const SizedBox.shrink();

    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final currency = ref.watch(currencyProvider);
    final localeTag = Localizations.localeOf(context).toString();

    final current = points.last;
    final previous = points[points.length - 2];
    final maxSpent = points
        .map((p) => p.spent)
        .fold<double>(0, (max, v) => v > max ? v : max);

    String? deltaText;
    Color deltaColor = theme.textSecondary;
    IconData? deltaIcon;
    if (previous.spent > 0 && current.spent > 0) {
      final pct =
          (((current.spent - previous.spent) / previous.spent) * 100).round();
      final rawMonth = DateFormat.MMMM(localeTag).format(previous.month);
      final monthName = rawMonth.isEmpty
          ? rawMonth
          : rawMonth[0].toUpperCase() + rawMonth.substring(1);
      if (pct <= -1) {
        deltaText = t.trendDeltaDown(pct.abs(), monthName);
        deltaColor = AppColors.success;
        deltaIcon = Icons.trending_down_rounded;
      } else if (pct >= 1) {
        deltaText = t.trendDeltaUp(pct, monthName);
        deltaColor = AppColors.warning;
        deltaIcon = Icons.trending_up_rounded;
      } else {
        deltaText = t.trendDeltaFlat(monthName);
        deltaIcon = Icons.trending_flat_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppInsets.screenHorizontal,
        AppSpacing.md,
        AppInsets.screenHorizontal,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.border.withValues(alpha: 0.55)),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.trendTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10.5,
                      color: theme.textSecondary.withValues(alpha: 0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (deltaText != null) ...[
                  Icon(deltaIcon, size: 14, color: deltaColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      deltaText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: deltaColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points) ...[
                    Expanded(
                      child: _TrendBar(
                        point: point,
                        maxSpent: maxSpent,
                        localeTag: localeTag,
                      ),
                    ),
                    if (point != points.last) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.trendCurrentMonthLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textMuted,
                  ),
                ),
                AnimatedAmount(
                  value: current.spent.roundToDouble(),
                  locale: localeTag,
                  format: (value) => currency.format(value.round()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                    fontFeatures: kTabularFigures,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendBar extends StatelessWidget {
  final MonthlySpendPoint point;
  final double maxSpent;
  final String localeTag;

  const _TrendBar({
    required this.point,
    required this.maxSpent,
    required this.localeTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isCurrent = point.isCurrentMonth;
    final ratio = maxSpent <= 0 ? 0.0 : (point.spent / maxSpent).clamp(0.0, 1.0);
    final barColor = isCurrent
        ? theme.primary
        : theme.textMuted.withValues(alpha: 0.28);

    final rawLabel = DateFormat.MMM(localeTag).format(point.month);
    final label = rawLabel.isEmpty
        ? rawLabel
        : rawLabel[0].toUpperCase() +
            rawLabel.substring(1).replaceAll('.', '');

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                heightFactor: value == 0 ? 0.04 : (0.08 + value * 0.92),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
            color: isCurrent ? theme.primary : theme.textMuted,
          ),
        ),
      ],
    );
  }
}
