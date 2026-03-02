import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/utils/app_animations.dart';

class BalanceCard extends ConsumerWidget {
  final int coins;
  final int xp;
  final double? userBalance;
  final bool isDark;

  const BalanceCard({
    super.key,
    required this.coins,
    required this.xp,
    this.userBalance,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNegative = userBalance != null && userBalance! < -0.01;

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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sage.withValues(alpha: 0.15),
              AppColors.sage.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.sage.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.sage.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu Balance',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$',
                            style: TextStyle(
                              color: isNegative ? AppColors.accentRed : AppColors.sage,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          _AnimatedDigitCounter(
                            value: userBalance ?? 0.0,
                            style: TextStyle(
                              color: isNegative ? AppColors.accentRed : AppColors.sage,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                            ),
                            isDecimal: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.sage.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sage.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: AppColors.sage,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // XP Card (Clickable)
                  Expanded(
                    child: AnimatedPress(
                      onTap: () => ref.read(bottomNavIndexProvider.notifier).setIndex(4), // Progreso index
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
                      onTap: () => ref.read(bottomNavIndexProvider.notifier).setIndex(3), // Tienda index
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
        final formatted = isDecimal ? val.toStringAsFixed(2) : val.toInt().toString();
        return Text(formatted, style: style);
      },
    );
  }
}

