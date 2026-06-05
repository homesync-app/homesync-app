import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// "Dar mesada" — adult → teen/child allowance transfer (Parent Mode, premium).
///
/// Calls the `transfer_to_member` RPC, which records two atomic PERSONAL rows
/// (adult expense + teen income) outside the shared household pool. See
/// docs/TEEN_FINANCES_SPEC.md.
class AllowanceSheet extends ConsumerStatefulWidget {
  const AllowanceSheet({super.key, this.initialRecipientId});

  /// Optional: preselect a teen (e.g., when opened from that teen's card).
  final String? initialRecipientId;

  static Future<bool?> show(BuildContext context, {String? recipientId}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllowanceSheet(initialRecipientId: recipientId),
    );
  }

  @override
  ConsumerState<AllowanceSheet> createState() => _AllowanceSheetState();
}

class _AllowanceSheetState extends ConsumerState<AllowanceSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _recipientId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _recipientId = widget.initialRecipientId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<MemberModel> _recipients(List<MemberModel> members) =>
      members.where((m) => m.isTeen || m.isChild).toList();

  Future<void> _send() async {
    final householdId = ref.read(householdIdProvider).value;
    final amount = double.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll(',', '.'),
    );

    if (householdId == null || _recipientId == null) {
      _snack('Elegí a quién darle la mesada.', AppSnackBarType.error);
      return;
    }
    if (amount == null || amount <= 0) {
      _snack('Ingresá un monto válido.', AppSnackBarType.error);
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await ref.read(supabaseClientProvider).rpc(
        'transfer_to_member',
        params: {
          'p_household_id': householdId,
          'p_to_user': _recipientId,
          'p_amount': amount,
          'p_note': _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          'p_request_id': UniqueKey().toString(),
        },
      );

      final ok = result is Map && result['success'] == true;
      if (!mounted) return;
      if (!ok) {
        final msg = (result is Map ? result['message'] : null)?.toString() ??
            'No se pudo enviar la mesada.';
        _snack(msg, AppSnackBarType.error);
        setState(() => _loading = false);
        return;
      }

      // Refresh balances/feed so both sides reflect the transfer.
      ref.invalidate(userBalanceProvider);
      ref.invalidate(expenseControllerProvider);
      Navigator.of(context).pop(true);
      _snack('¡Mesada enviada! 💸', AppSnackBarType.success);
    } catch (e) {
      if (!mounted) return;
      _snack('Error al enviar la mesada: $e', AppSnackBarType.error);
      setState(() => _loading = false);
    }
  }

  void _snack(String message, AppSnackBarType type) {
    if (!mounted) return;
    AppSnackBar.show(context, message: message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final members = ref.watch(householdMembersProvider).value ?? const [];
    final recipients = _recipients(members);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: theme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Dar mesada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Le transferís plata a un menor para sus finanzas personales.',
              style: TextStyle(fontSize: 13, color: theme.textSecondary),
            ),
            const SizedBox(height: 20),

            if (recipients.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No hay adolescentes o niños en el hogar para darles mesada.',
                  style: TextStyle(color: theme.textSecondary),
                ),
              )
            else ...[
              Text(
                'Para',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: recipients.map((m) {
                  final selected = m.userId == _recipientId;
                  return GestureDetector(
                    onTap: () => setState(() => _recipientId = m.userId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : theme.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : theme.divider.withValues(alpha: 0.2),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomUserAvatar(
                            name: m.displayName,
                            avatarUrl: m.avatarUrl,
                            radius: 14,
                            forceCircular: true,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            m.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.primary
                                  : theme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Text(
                'Monto',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: r'$ ',
                  hintText: '0',
                  filled: true,
                  fillColor: theme.surfaceVariant.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _noteController,
                style: TextStyle(color: theme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Nota (opcional) — ej: "Mesada de junio"',
                  filled: true,
                  fillColor: theme.surfaceVariant.withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _send,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enviar mesada',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
