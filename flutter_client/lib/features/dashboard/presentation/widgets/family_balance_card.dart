import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class FamilyBalanceCard extends StatelessWidget {
  final List<HouseholdBalanceModel> balances;
  final String title;
  final String? currentUserId;

  const FamilyBalanceCard({
    super.key,
    required this.balances,
    required this.title,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isSingleMember = balances.length == 1;
    final visibleBalances = currentUserId == null
        ? balances
        : balances.where((item) => item.userId != currentUserId).toList();
    final myBalance = currentUserId == null
        ? null
        : balances.where((item) => item.userId == currentUserId).firstOrNull;
    final settledCount = balances.where((item) => item.isSettled).length;
    final pendingCount = balances.length - settledCount;
    final balanceValue = myBalance?.balance ?? 0.0;
    final isNegative = balanceValue < -0.01;
    final isPositive = balanceValue > 0.01;
    final isSettled = !isNegative && !isPositive;
    final statusColor = isNegative
        ? AppColors.accentOrange
        : (isPositive ? AppColors.sage : AppColors.primary);
    final statusLabel = myBalance == null
        ? 'Balance compartido'
        : isSettled
            ? ''
            : (isNegative ? 'Te toca acomodar tu saldo' : 'Quedó a tu favor');
    final headline = myBalance == null
        ? '${pendingCount == 0 ? '0' : pendingCount} movimientos'
        : '${isNegative ? '-' : isPositive ? '+' : ''}\$${balanceValue.abs().toStringAsFixed(2)}';
    final statusBadge =
        isSettled ? 'Al día' : (isNegative ? 'Debes' : 'A favor');
    final openBalancesLabel = pendingCount == 0
        ? 'Todo al día'
        : pendingCount == 1
            ? 'Saldo abierto'
            : 'Saldos abiertos';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.surface,
            theme.elevatedSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.68),
          width: 1.05,
        ),
        boxShadow: [
          ...theme.cardShadow,
          BoxShadow(
            color: AppColors.accentTeal.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: theme.textSecondary,
                letterSpacing: 1.05,
              ),
            ),
            if (statusLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 6),
            ] else
              const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: TextStyle(
                          color: isSettled ? theme.textPrimary : statusColor,
                          fontSize: isSingleMember ? 33 : 35,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.1,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSettled
                            ? Icons.check_rounded
                            : (isNegative
                                ? Icons.balance_rounded
                                : Icons.trending_up_rounded),
                        color: statusColor,
                        size: 18,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusBadge,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isSingleMember)
              _buildSingleMemberFooter(
                balance: balances.first,
                theme: theme,
              )
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 14),
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
                        theme,
                        icon: Icons.group_rounded,
                        label:
                            balances.length == 1 ? 'Integrante' : 'Integrantes',
                        value: '${balances.length}',
                        color: AppColors.accentTeal,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: theme.border.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildInlineMetric(
                        theme,
                        icon: pendingCount == 0
                            ? Icons.check_circle_outline_rounded
                            : Icons.sync_alt_rounded,
                        label: openBalancesLabel,
                        value: '$pendingCount',
                        color: pendingCount == 0
                            ? AppColors.sage
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...visibleBalances.asMap().entries.map(
                    (entry) => Column(
                      children: [
                        _buildMemberBalance(entry.value, theme),
                        if (entry.key != visibleBalances.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Divider(
                              height: 1,
                              indent: 8,
                              endIndent: 8,
                              color: theme.divider.withValues(alpha: 0.06),
                            ),
                          ),
                      ],
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSingleMemberFooter({
    required HouseholdBalanceModel balance,
    required AppThemeColors theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          CustomUserAvatar(
            avatarUrl: balance.avatarUrl,
            name: balance.displayName,
            radius: 18,
            forceCircular: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cuando sumes más integrantes, acá vas a ver cómo queda el balance compartido.',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineMetric(
    AppThemeColors theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 15.5,
          ),
        ),
        const SizedBox(width: 9),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$value\n',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberBalance(
    HouseholdBalanceModel balance,
    AppThemeColors theme,
  ) {
    final bool isNegative = balance.balance < -0.01;
    final bool isPositive = balance.balance > 0.01;
    final rowTint = isNegative
        ? AppColors.accentOrange
        : (isPositive ? AppColors.sage : AppColors.accentTeal);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: rowTint.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CustomUserAvatar(
            avatarUrl: balance.avatarUrl,
            name: balance.displayName,
            radius: 18,
            forceCircular: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              balance.displayName,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}\$${balance.balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: isNegative
                      ? AppColors.error
                      : (isPositive ? AppColors.success : theme.textPrimary),
                  letterSpacing: -0.25,
                ),
              ),
              Text(
                isNegative ? 'Debe' : (isPositive ? 'A favor' : 'Al día'),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
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
