import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class FamilyBalanceCard extends ConsumerWidget {
  final List<dynamic> balances;
  final String title;

  const FamilyBalanceCard({
    super.key,
    required this.balances,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.divider.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          ...balances.map((b) => _buildMemberBalance(b, theme)),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.sync_alt_rounded, size: 18),
              label: const Text('Ajustar Cuentas'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberBalance(dynamic balance, AppThemeColors theme) {
    final bool isNegative = balance.balance < -0.01;
    final bool isPositive = balance.balance > 0.01;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CustomUserAvatar(
            avatarUrl: balance.avatarUrl ?? balance.userAvatar,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              balance.displayName ?? balance.userFullName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}\$${balance.balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isNegative ? AppColors.error : (isPositive ? AppColors.success : theme.textPrimary),
                ),
              ),
              Text(
                isNegative ? 'Debe' : (isPositive ? 'A favor' : 'Al día'),
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
