import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
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

    // Relational Colors: Sage for credit, Orange for debt, Grey for balanced
    final statusColor = isNegative
        ? AppColors.accentOrange
        : (isBalanced ? const Color(0xFF94A3B8) : AppColors.sage);

    final backgroundColor = isNegative
        ? AppColors.accentOrange.withValues(alpha: 0.08)
        : AppColors.sage.withValues(alpha: 0.08);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Partner Balance Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBalanced
                              ? '¡Equilibrio perfecto! 🤍'
                              : 'Balance de Pareja',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isPositive ? '+' : (isNegative ? '' : ''),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '\$',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.5,
                              ),
                            ),
                            _AnimatedDigitCounter(
                              value: balance.abs(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Saldar Button (Show only if negative, i.e., debtor)
                  if (isNegative && onSettle != null)
                    AnimatedPress(
                      onTap: onSettle!,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Equilibrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    )
                  else if (isBalanced)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.sage, size: 32),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  // XP Card (Clickable)
                  Expanded(
                    child: AnimatedPress(
                      onTap: () =>
                          ref.read(bottomNavIndexProvider.notifier).setIndex(4),
                      child: _buildMetricCard(
                        context,
                        label: 'XP',
                        value: xp,
                        icon: Icons.star_rounded,
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Coins Card (Clickable)
                  Expanded(
                    child: AnimatedPress(
                      onTap: () =>
                          ref.read(bottomNavIndexProvider.notifier).setIndex(3),
                      child: _buildMetricCard(
                        context,
                        label: 'Coins',
                        value: coins,
                        icon: Icons.monetization_on_rounded,
                        iconBg: AppColors.primary.withValues(alpha: 0.12),
                        iconColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _AnimatedDigitCounter(
                  value: value.toDouble(),
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: Color(0xFFCBD5E1),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDigitCounter extends StatelessWidget {
  final double value;
  final TextStyle style;
  final bool isDecimal;

  const _AnimatedDigitCounter({
    required this.value,
    required this.style,
    this.isDecimal = false,
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
