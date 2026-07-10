import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/core/utils/debt_simplifier.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_pool_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/pool_provider.dart';
import 'package:homesync_client/features/expenses/presentation/utils/finance_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Detalle de un fondo: total, quién puso cuánto, qué falta saldar DE ESTE
/// FONDO (con registro de pago que también baja la deuda global) y sus
/// movimientos. "Cerrar fondo" lo archiva — las deudas restantes siguen
/// vivas en el balance global.
class PoolDetailSheet extends ConsumerWidget {
  final String poolId;

  const PoolDetailSheet({super.key, required this.poolId});

  static Future<void> show(BuildContext context, String poolId) {
    return AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PoolDetailSheet(poolId: poolId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final summaryAsync = ref.watch(poolSummaryProvider(poolId));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: summaryAsync.when(
        loading: () => const SizedBox(
          height: 260,
          child: Center(child: AppLoader()),
        ),
        error: (e, _) => SizedBox(
          height: 200,
          child: Center(child: Text(t.commonErrorWithDetails('$e'))),
        ),
        data: (summary) {
          if (summary == null) {
            return SizedBox(
              height: 200,
              child: Center(child: Text(t.poolsDetailNotFound)),
            );
          }
          return _PoolDetailBody(summary: summary);
        },
      ),
    );
  }
}

class _PoolDetailBody extends ConsumerStatefulWidget {
  final PoolSummary summary;

  const _PoolDetailBody({required this.summary});

  @override
  ConsumerState<_PoolDetailBody> createState() => _PoolDetailBodyState();
}

class _PoolDetailBodyState extends ConsumerState<_PoolDetailBody> {
  /// Claves de idempotencia por deuda (from→to) para reintentos seguros.
  final _settleRequestIds = <String, String>{};
  String? _settlingKey;
  bool _isClosing = false;

  Future<void> _settle(SimplifiedDebt debt) async {
    final t = AppLocalizations.of(context);
    final currency = ref.read(currencyProvider);
    final theme = context.theme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(
          t.settleConfirmTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          t.settleConfirmBody(
            debt.fromName,
            currency.format(debt.amount.round()),
            debt.toName,
          ),
          style: TextStyle(color: theme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              t.commonCancel,
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final key = '${debt.fromUserId}->${debt.toUserId}';
    final requestId = _settleRequestIds[key] ??= const Uuid().v4();

    setState(() => _settlingKey = key);
    try {
      await ref.read(expenseControllerProvider.notifier).settleDebt(
            fromUserId: debt.fromUserId,
            toUserId: debt.toUserId,
            amount: debt.amount,
            requestId: requestId,
            poolId: widget.summary.pool.id,
          );
      _settleRequestIds.remove(key);
      if (!mounted) return;
      AppHaptics.celebrate();
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(combinedFeedControllerProvider);
      AppSnackBar.show(
        context,
        message: t.settleSuccess(currency.format(debt.amount.round())),
        type: AppSnackBarType.success,
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: t.settleError(e.toString()),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _settlingKey = null);
    }
  }

  Future<void> _closePool() async {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(
          t.poolsCloseConfirmTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          widget.summary.isSettled
              ? t.poolsCloseConfirmBodySettled
              : t.poolsCloseConfirmBodyPending,
          style: TextStyle(color: theme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              t.commonCancel,
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.poolsCloseCta),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isClosing = true);
    try {
      await ref.read(poolMutationsProvider).close(widget.summary.pool.id);
      if (!mounted) return;
      AppHaptics.success();
      Navigator.pop(context);
      AppSnackBar.show(
        context,
        message: t.poolsClosedSnack(widget.summary.pool.name),
        type: AppSnackBarType.success,
        duration: const Duration(milliseconds: 1800),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: t.commonErrorWithDetails('$e'),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isClosing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final currency = ref.watch(currencyProvider);
    final localeTag = Localizations.localeOf(context).toString();
    final summary = widget.summary;
    final currentUserId = ref.watch(currentUserIdProvider);

    // Deudas internas del fondo, simplificadas igual que en Inicio.
    final debts = DebtSimplifier.simplify([
      for (final balance in summary.balances)
        HouseholdBalanceModel(
          userId: balance.userId,
          userFullName: balance.name,
          avatarUrl: balance.avatarUrl,
          balance: balance.balance,
        ),
    ]);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  summary.pool.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    summary.pool.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              t.poolsDetailTotalLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: theme.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedAmount(
              value: summary.total,
              locale: localeTag,
              format: (value) => currency.format(value.round()),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -1,
                fontFeatures: kTabularFigures,
              ),
            ),

            // Quién puso.
            if (summary.members.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                t.recapPayersTitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: theme.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              for (final member in summary.members) ...[
                Row(
                  children: [
                    CustomUserAvatar(
                      avatarUrl: member.avatarUrl,
                      name: member.name,
                      radius: 15,
                      forceCircular: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        member.name.split(' ').first,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      currency.format(member.paid.round()),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: theme.textPrimary,
                        fontFeatures: kTabularFigures,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ],

            // Para saldar este fondo.
            const SizedBox(height: 14),
            Text(
              t.poolsDetailSettleTitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: theme.textMuted,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            if (debts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.poolsDetailAllSettled,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final debt in debts) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.poolsDetailDebtRow(
                            debt.fromName,
                            currency.format(debt.amount.round()),
                            debt.toName,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Registrar el pago lo inicia cualquiera de los dos
                      // involucrados (mismo criterio que el settle global).
                      if (currentUserId == debt.fromUserId ||
                          currentUserId == debt.toUserId)
                        _settlingKey ==
                                '${debt.fromUserId}->${debt.toUserId}'
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : TextButton(
                                onPressed: _settlingKey != null
                                    ? null
                                    : () => _settle(debt),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.accentTeal,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(
                                  t.poolsDetailSettleCta,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                    ],
                  ),
                ),
              ],

            // Movimientos del fondo.
            if (summary.expenses.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                t.expensesBreakdownMovementsEyebrow,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: theme.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              for (final row in summary.expenses.take(20)) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedFinanceTitle(
                              t,
                              title: row.title,
                              titleKey: row.titleKey,
                              category: row.category,
                              transactionType: row.type,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                          ),
                          Text(
                            '${DateFormat('d MMM', localeTag).format(row.paidAt)}'
                            '${row.payerName == null ? '' : ' · ${row.payerName!.split(' ').first}'}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currency.format(row.amount.round()),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: row.type == 'settlement'
                            ? AppColors.accentTeal
                            : theme.textPrimary,
                        fontFeatures: kTabularFigures,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isClosing ? null : _closePool,
                icon: const Icon(Icons.archive_outlined, size: 18),
                label: Text(
                  t.poolsCloseCta,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.textSecondary,
                  side: BorderSide(
                    color: theme.border.withValues(alpha: 0.8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
