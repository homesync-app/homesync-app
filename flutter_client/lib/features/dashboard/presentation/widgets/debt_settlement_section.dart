import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/debt_simplifier.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class DebtSettlementSection extends ConsumerWidget {
  final List<HouseholdBalanceModel> balances;

  const DebtSettlementSection({super.key, required this.balances});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = DebtSimplifier.simplify(balances);

    if (debts.isEmpty) {
      return _buildAllSettledState(context);
    }

    final theme = context.theme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.08)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.accentTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldar deudas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      _subtitleText(debts),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...debts.map((debt) => _DebtRow(debt: debt)),
        ],
      ),
    );
  }

  String _subtitleText(List<SimplifiedDebt> debts) {
    if (debts.length == 1) return '1 pago necesario para equilibrar';
    return '${debts.length} pagos para equilibrar todo';
  }

  Widget _buildAllSettledState(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Todo equilibrado. Nadie le debe a nadie.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtRow extends ConsumerStatefulWidget {
  final SimplifiedDebt debt;

  const _DebtRow({required this.debt});

  @override
  ConsumerState<_DebtRow> createState() => _DebtRowState();
}

class _DebtRowState extends ConsumerState<_DebtRow> {
  bool _isSettling = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final debt = widget.debt;
    final currency = ref.watch(currencyProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedPress(
        onPressed: _isSettling ? null : _confirmSettle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surfaceContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CustomUserAvatar(
                avatarUrl: debt.fromAvatarUrl,
                name: debt.fromName,
                radius: 18,
                showBorder: true,
                forceCircular: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.fromName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      'le paga a ${debt.toName}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currency.format(debt.amount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentTeal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CustomUserAvatar(
                avatarUrl: debt.toAvatarUrl,
                name: debt.toName,
                radius: 18,
                showBorder: true,
                forceCircular: true,
              ),
              const SizedBox(width: 4),
              _isSettling
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.accentTeal,
                      size: 28,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSettle() async {
    final theme = context.theme;
    final debt = widget.debt;
    final formattedAmount = ref.read(currencyProvider).format(debt.amount);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Confirmar pago',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(color: theme.textSecondary, height: 1.5),
            children: [
              TextSpan(
                text: debt.fromName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const TextSpan(text: ' le paga '),
              TextSpan(
                text: formattedAmount,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentTeal,
                ),
              ),
              const TextSpan(text: ' a '),
              TextSpan(
                text: debt.toName,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancelar', style: TextStyle(color: theme.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSettling = true);

    try {
      await ref.read(expenseControllerProvider.notifier).settleDebt(
            fromUserId: debt.fromUserId,
            toUserId: debt.toUserId,
            amount: debt.amount,
          );

      HapticFeedback.mediumImpact();

      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(combinedFeedControllerProvider);

      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Pago de $formattedAmount registrado.',
        type: AppSnackBarType.success,
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'No se pudo registrar el pago: $e',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSettling = false);
    }
  }
}
