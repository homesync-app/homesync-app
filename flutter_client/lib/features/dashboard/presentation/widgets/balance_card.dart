import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:intl/intl.dart';

class BalanceCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = userBalance ?? 0.0;
    final bool isPositive = balance > 0.01;
    final bool isNegative = balance < -0.01;
    final bool isBalanced = !isPositive && !isNegative;
    final theme = context.theme;

    final statusColor = isNegative
        ? AppColors.accentOrange // Using orange instead of aggressive red
        : (isBalanced ? AppColors.sage : AppColors.sage);

    final String balanceMessage = isBalanced
        ? '¡Todo en orden! El amor es lo único que cuenta hoy 💕'
        : (isNegative ? 'Debes' : 'Te deben');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.04), // Very subtle shadow
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        balanceMessage,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isBalanced ? '\$ ' : (isNegative ? '- \$ ' : '+ \$ '),
                            style: TextStyle(
                              color: isBalanced ? theme.textPrimary : statusColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          _AnimatedDigitCounter(
                            value: balance.abs(),
                            style: TextStyle(
                              color: isBalanced ? theme.textPrimary : statusColor,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
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
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payment_rounded, color: statusColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Saldar',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animatePulse()
                else if (isBalanced)
                  const Icon(Icons.check_circle_rounded, color: AppColors.sage, size: 36).animateScaleIn()
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: theme.border.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AnimatedPress(
                    onTap: () =>
                        ref.read(bottomNavIndexProvider.notifier).setIndex(4),
                    child: _buildCleanMetric(
                      context,
                      label: 'Experiencia',
                      value: '${NumberFormat.decimalPattern('es_AR').format(xp)} XP',
                      icon: Icons.star_rounded,
                      color: const Color(0xFFE8943A),
                    ),
                  ),
                ),
                Container(width: 1, height: 32, color: theme.border.withValues(alpha: 0.4)),
                Expanded(
                  child: AnimatedPress(
                    onTap: () =>
                        ref.read(bottomNavIndexProvider.notifier).setIndex(3),
                    child: _buildCleanMetric(
                      context,
                      label: 'Coins',
                      value: NumberFormat.decimalPattern('es_AR').format(coins),
                      icon: Icons.monetization_on_rounded,
                      color: AppColors.sage,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animateEntrance(delay: 200);
  }

  Widget _buildCleanMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = context.theme;
    return Container(
      color: Colors.transparent, // allows the entire area to be tap-able
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, size: 16, color: theme.textMuted.withValues(alpha: 0.5)),
        ],
      ),
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
