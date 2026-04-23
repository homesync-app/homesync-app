import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final int coins;
  final int xp;
  final double? userBalance;
  final bool isDark;
  final VoidCallback? onSettle;
  final String? partnerName;

  const BalanceCard({
    super.key,
    required this.coins,
    required this.xp,
    this.userBalance,
    this.isDark = false,
    this.onSettle,
    this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    final balance = userBalance ?? 0.0;
    final isPositive = balance > 0.01;
    final isNegative = balance < -0.01;
    final isBalanced = !isPositive && !isNegative;
    final theme = context.theme;

    final statusColor = isNegative ? AppColors.accentOrange : AppColors.sage;
    final balanceMessage = partnerName == null
        ? 'Mi presupuesto'
        : (isBalanced
            ? 'Balance en calma'
            : (isNegative ? 'Hace falta equilibrar' : 'Quedó a tu favor'));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.surface,
            theme.elevatedSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.68),
          width: 1.05,
        ),
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBalanced ? 'Balance en calma' : balanceMessage,
                        style: TextStyle(
                          color: isBalanced
                              ? statusColor.withValues(alpha: 0.88)
                              : statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isBalanced
                                ? '\$ '
                                : (isNegative ? '- \$ ' : '+ \$ '),
                            style: TextStyle(
                              color:
                                  isBalanced ? theme.textPrimary : statusColor,
                              fontSize: isBalanced ? 16 : 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          _AnimatedDigitCounter(
                            value: balance.abs(),
                            style: TextStyle(
                              color: isBalanced
                                  ? theme.textPrimary.withValues(alpha: 0.94)
                                  : statusColor,
                              fontSize: isBalanced ? 31 : 35,
                              fontWeight: isBalanced
                                  ? FontWeight.w800
                                  : FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isNegative && onSettle != null)
                  AnimatedPress(
                    onTap: onSettle!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.14),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.045),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            color: statusColor,
                            size: 15,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Equilibrar',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animatePulse()
                else if (isBalanced)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.sage.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.sage,
                      size: 24,
                    ),
                  ).animateScaleIn(),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.border.withValues(alpha: 0.32),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInlineMetric(
                      context,
                      icon: Icons.star_rounded,
                      label: 'XP',
                      value: NumberFormat.decimalPattern('es_AR').format(xp),
                      color: const Color(0xFFE8943A),
                      subdued: isBalanced && xp == 0,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.border
                        .withValues(alpha: isBalanced ? 0.14 : 0.22),
                  ),
                  Expanded(
                    child: _buildInlineMetric(
                      context,
                      icon: Icons.monetization_on_rounded,
                      label: 'coins',
                      value: NumberFormat.decimalPattern('es_AR').format(coins),
                      color: AppColors.sage,
                      subdued: isBalanced && coins == 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animateEntrance(delay: 200);
  }

  Widget _buildInlineMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool subdued = false,
  }) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: subdued ? 0.045 : 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: subdued ? color.withValues(alpha: 0.82) : color,
            size: 14.5,
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: subdued
                      ? theme.textPrimary.withValues(alpha: 0.86)
                      : theme.textPrimary,
                  fontSize: 14.5,
                  fontWeight: subdued ? FontWeight.w700 : FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              TextSpan(
                text: label == 'XP' ? ' XP' : ' coins',
                style: TextStyle(
                  color: subdued
                      ? theme.textSecondary.withValues(alpha: 0.82)
                      : theme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedDigitCounter extends StatelessWidget {
  final double value;
  final TextStyle style;

  const _AnimatedDigitCounter({
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutExpo,
      builder: (context, val, child) {
        final formatted =
            NumberFormat.decimalPattern('es_AR').format(val.round());
        return Text(formatted, style: style);
      },
    );
  }
}
