import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';
import 'package:homesync_client/shared/widgets/design/app_sheet_shell.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Adult -> teen allowance transfer for Parent Mode.
class AllowanceSheet extends ConsumerStatefulWidget {
  const AllowanceSheet({super.key, this.initialRecipientId});

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
      members.where((m) => m.isTeen).toList();

  Future<void> _send() async {
    final t = AppLocalizations.of(context);
    final householdId = ref.read(householdIdProvider).value;
    final amount = double.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll(',', '.'),
    );

    if (householdId == null || _recipientId == null) {
      _snack(t.allowanceRecipientRequired, AppSnackBarType.error);
      return;
    }
    if (amount == null || amount <= 0) {
      _snack(t.allowanceAmountInvalid, AppSnackBarType.error);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
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
          'p_request_id': DateTime.now().microsecondsSinceEpoch.toString(),
        },
      );

      final ok = result is Map && result['success'] == true;
      if (!mounted) return;
      if (!ok) {
        final msg = (result is Map ? result['message'] : null)?.toString() ??
            t.allowanceSendGenericError;
        _snack(msg, AppSnackBarType.error);
        setState(() => _loading = false);
        return;
      }

      ref.invalidate(userBalanceProvider);
      ref.invalidate(expenseControllerProvider);
      Navigator.of(context).pop(true);
      _snack(t.allowanceSentSnack, AppSnackBarType.success);
    } catch (e) {
      if (!mounted) return;
      _snack(t.allowanceSendError(e.toString()), AppSnackBarType.error);
      setState(() => _loading = false);
    }
  }

  void _snack(String message, AppSnackBarType type) {
    if (!mounted) return;
    AppSnackBar.show(context, message: message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final members = ref.watch(householdMembersProvider).value ?? const [];
    final recipients = _recipients(members);
    final canSubmit = recipients.isNotEmpty;

    return AnimatedPadding(
      duration: AppMotion.normal,
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: AppSheetShell(
            title: t.allowanceSheetTitle,
            subtitle: t.allowanceSheetSubtitle,
            actions: [
              Expanded(
                child: AppButton(
                  label: t.allowanceSubmitButton,
                  icon: Icons.payments_rounded,
                  isLoading: _loading,
                  isDisabled: !canSubmit,
                  isFullWidth: true,
                  onTap: _send,
                ),
              ),
            ],
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recipients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        t.allowanceNoRecipients,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    )
                  else ...[
                    _Label(t.allowanceRecipientLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recipients.map(_buildRecipientChip).toList(),
                    ),
                    const SizedBox(height: 20),
                    _Label(t.allowanceAmountLabel),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
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
                        fillColor: theme.surfaceVariant.withValues(alpha: 0.42),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _noteController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!_loading) {
                          _send();
                        }
                      },
                      style: TextStyle(color: theme.textPrimary),
                      decoration: InputDecoration(
                        hintText: t.allowanceNoteHint,
                        filled: true,
                        fillColor: theme.surfaceVariant.withValues(alpha: 0.42),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientChip(MemberModel member) {
    final theme = context.theme;
    final selected = member.userId == _recipientId;
    return GestureDetector(
      onTap: () => setState(() => _recipientId = member.userId),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : theme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadii.lg),
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
              name: member.displayName,
              avatarUrl: member.avatarUrl,
              radius: 14,
              forceCircular: true,
            ),
            const SizedBox(width: 8),
            Text(
              member.displayName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: theme.textSecondary,
      ),
    );
  }
}
