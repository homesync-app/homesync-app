import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/presentation/providers/allowance_schedule_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';
import 'package:homesync_client/shared/widgets/design/app_sheet_shell.dart';
import 'package:homesync_client/shared/widgets/inline_error_banner.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Adult -> teen allowance transfer for Parent Mode.
class AllowanceSheet extends ConsumerStatefulWidget {
  const AllowanceSheet({super.key, this.initialRecipientId});

  final String? initialRecipientId;

  static Future<bool?> show(BuildContext context, {String? recipientId}) {
    return AppSheet.show<bool>(
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
  bool _isDisablingSchedule = false;
  String? _errorMessage;

  /// Mesada recurrente: repetir todos los meses el día elegido (fase 3 del
  /// spec de teen finances; el cron server-side hace los envíos siguientes).
  bool _repeatMonthly = false;
  int _repeatDay = DateTime.now().day.clamp(1, 28);

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
    if (_loading) return;
    final t = AppLocalizations.of(context);
    // es-AR sin centavos: coma = decimal al parsear, pero se redondea.
    final amount = double.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll(',', '.'),
    )?.roundToDouble();

    if (_recipientId == null) {
      setState(() => _errorMessage = t.allowanceRecipientRequired);
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = t.allowanceAmountInvalid);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) {
        throw StateError('Cannot send an allowance without a household');
      }

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
      if (!ok) {
        log.w(
          'Allowance transfer returned an unsuccessful result',
          error: result,
        );
        if (mounted) {
          setState(() => _errorMessage = t.allowanceSendGenericError);
        }
        return;
      }

      // Mesada recurrente: dejamos programados los meses siguientes (el
      // envío de HOY ya salió arriba; last_run_month evita el doble envío).
      var scheduled = false;
      var scheduleFailed = false;
      if (_repeatMonthly) {
        try {
          await ref.read(allowanceScheduleMutationsProvider).upsert(
                toUserId: _recipientId!,
                amount: amount,
                dayOfMonth: _repeatDay,
                note: _noteController.text.trim().isEmpty
                    ? null
                    : _noteController.text.trim(),
              );
          scheduled = true;
        } catch (error, stackTrace) {
          log.e(
            'Allowance transfer succeeded but schedule creation failed',
            error: error,
            stackTrace: stackTrace,
          );
          scheduleFailed = true;
        }
      }

      if (!mounted) return;
      ref.invalidate(userBalanceProvider);
      ref.invalidate(expenseControllerProvider);
      Navigator.of(context).pop(true);
      // The transfer is already committed. Report a scheduling failure as a
      // partial success instead of replacing it with a generic success snack.
      if (scheduleFailed) {
        _snack(
          t.allowanceSentScheduleFailed,
          AppSnackBarType.error,
        );
      } else {
        _snack(
          scheduled
              ? t.allowanceScheduledSnack(_repeatDay)
              : t.allowanceSentSnack,
          AppSnackBarType.success,
        );
      }
    } catch (error, stackTrace) {
      log.e(
        'Allowance transfer failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _errorMessage = t.allowanceSendGenericError);
    } finally {
      if (mounted) setState(() => _loading = false);
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
    final membersAsync = ref.watch(householdMembersProvider);
    final members = membersAsync.value ?? const <MemberModel>[];
    final recipients = _recipients(members);
    final canSubmit = membersAsync.hasValue && recipients.isNotEmpty;

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
                  if (membersAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(child: AppLoader()),
                    )
                  else if (membersAsync.hasError)
                    AppErrorState(
                      message: t.allowanceMembersLoadError,
                      onRetry: () => ref.invalidate(householdMembersProvider),
                    )
                  else if (recipients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        t.allowanceNoRecipients,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: theme.textSecondary,
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
                      style: AppTypography.sectionTitle.copyWith(
                        fontSize: 22,
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
                    const SizedBox(height: 16),
                    _buildRepeatSection(t, theme),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    InlineErrorBanner(message: _errorMessage!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Toggle de mesada mensual + día, y banner de la programación activa
  /// hacia el teen seleccionado (con desactivar).
  Widget _buildRepeatSection(AppLocalizations t, AppThemeColors theme) {
    final schedules = ref.watch(myAllowanceSchedulesProvider).value ?? const [];
    AllowanceScheduleModel? activeForRecipient;
    for (final schedule in schedules) {
      if (schedule.toUserId == _recipientId) {
        activeForRecipient = schedule;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeForRecipient != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  Icons.event_repeat_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.allowanceActiveScheduleInfo(
                      '\$${activeForRecipient.amount.round()}',
                      activeForRecipient.dayOfMonth,
                    ),
                    style: AppTypography.caption.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isDisablingSchedule
                      ? null
                      : () async {
                          final id = activeForRecipient!.id;
                          setState(() => _isDisablingSchedule = true);
                          try {
                            await ref
                                .read(allowanceScheduleMutationsProvider)
                                .deactivate(id);
                            if (!mounted) return;
                            _snack(
                              t.allowanceScheduleDisabledSnack,
                              AppSnackBarType.neutral,
                            );
                          } catch (error, stackTrace) {
                            log.e(
                              'Allowance schedule deactivation failed for $id',
                              error: error,
                              stackTrace: stackTrace,
                            );
                            if (!mounted) return;
                            _snack(
                              t.allowanceScheduleDisableError,
                              AppSnackBarType.error,
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isDisablingSchedule = false);
                            }
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: _isDisablingSchedule
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          t.allowanceScheduleDisable,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                t.allowanceRepeatToggle,
                style: AppTypography.bodyStrong.copyWith(
                  fontSize: 13.5,
                  color: theme.textPrimary,
                ),
              ),
            ),
            Switch.adaptive(
              value: _repeatMonthly,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _repeatMonthly = value),
            ),
          ],
        ),
        if (_repeatMonthly) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _repeatDay,
                isExpanded: true,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                items: [
                  for (var day = 1; day <= 28; day++)
                    DropdownMenuItem(
                      value: day,
                      child: Text(
                        t.expensesRecurrentesDayOfMonth(day),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                ],
                onChanged: (day) {
                  if (day != null) setState(() => _repeatDay = day);
                },
              ),
            ),
          ),
        ],
      ],
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
      style: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.textSecondary,
      ),
    );
  }
}
