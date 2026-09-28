import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/amount_input.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class PlannedExpensePaymentSheet extends ConsumerStatefulWidget {
  final FeedItemModel plannedExpense;

  const PlannedExpensePaymentSheet({
    super.key,
    required this.plannedExpense,
  });

  @override
  ConsumerState<PlannedExpensePaymentSheet> createState() =>
      _PlannedExpensePaymentSheetState();

  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    FeedItemModel plannedExpense,
  ) {
    return AppSheet.show<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          PlannedExpensePaymentSheet(plannedExpense: plannedExpense),
    );
  }
}

class _PlannedExpensePaymentSheetState
    extends ConsumerState<PlannedExpensePaymentSheet> {
  final _amountController = TextEditingController();
  DateTime _paidAt = DateTime.now();
  String _paidBy = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Same format as the expense form: whole pesos, cents in currencies that
    // use them.
    _amountController.text = ref
        .read(currencyProvider)
        .inputFormat
        .format(widget.plannedExpense.amount);
    _paidBy = widget.plannedExpense.payerId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Guarantees [_paidBy] always points at an eligible member so the selector
  /// highlights a chip and the value sent to the RPC is a real adult member id.
  ///
  /// The planned expense's payer id can come from a different identity space
  /// than [MemberModel.userId] (Supabase UUID vs Firebase UID, depending on the
  /// source). When it doesn't match any member we fall back to the current user
  /// — the person registering the payment is the natural default — and finally
  /// to the first member.
  void _ensureValidPayer(List<MemberModel> members) {
    final eligiblePayers = _eligiblePayers(members);
    if (eligiblePayers.isEmpty) return;
    if (eligiblePayers.any((m) => m.userId == _paidBy)) return;

    final currentUserId = ref.read(currentUserIdProvider);
    _paidBy = eligiblePayers
        .firstWhere(
          (m) => m.userId == currentUserId,
          orElse: () => eligiblePayers.first,
        )
        .userId;
  }

  List<MemberModel> _eligiblePayers(List<MemberModel> members) {
    final adults = members.where((member) => member.isAdult).toList();
    return adults.isNotEmpty ? adults : members;
  }

  double? _parseAmount(String raw) {
    if (raw.trim().isEmpty) return null;
    return ref.read(currencyProvider).inputFormat.parse(raw);
  }

  Future<void> _confirmPayment() async {
    if (_isLoading) return;
    final t = AppLocalizations.of(context);
    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(combinedFeedControllerProvider.notifier)
          .payPlannedExpense(
            plannedId: widget.plannedExpense.id,
            amount: amount,
            paidAt: _paidAt,
            paidBy: _paidBy,
          );

      if (!mounted) return;

      final templateUpdated = result['template_updated'] == true;
      AppHaptics.success();
      Navigator.pop(context, {
        'success': true,
        'template_updated': templateUpdated,
        'title': widget.plannedExpense.title,
      });
    } catch (error, stackTrace) {
      log.e(
        'Planned expense payment failed for ${widget.plannedExpense.id}',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      // Use the overlay-based snackbar: a ScaffoldMessenger snackbar renders
      // *behind* this modal bottom sheet, so the user would see no feedback and
      // an open form. AppSnackBar draws on the root overlay, above the sheet.
      AppSnackBar.show(
        context,
        message: t.expensesPlannedPaymentError,
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final membersAsync = ref.watch(householdMembersProvider);
    final isSharedEconomy =
        ref.watch(currentHouseholdProvider).value?.financeMode == 'shared';

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: membersAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: AppLoader()),
        ),
        error: (error, stackTrace) => SizedBox(
          height: 200,
          child: AppErrorState(
            message: AppLocalizations.of(context)
                .expensesPlannedPaymentMembersLoadError,
            onRetry: () => ref.invalidate(householdMembersProvider),
          ),
        ),
        data: (List<MemberModel> members) {
          _ensureValidPayer(members);
          final eligiblePayers = _eligiblePayers(members);

          return SingleChildScrollView(
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
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).expensesPlannedPaymentTitle(
                    widget.plannedExpense.transactionType,
                  ),
                  style: AppTypography.sectionTitle.copyWith(
                    fontSize: 22,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).expensesPlannedPaymentSubtitle(
                    widget.plannedExpense.transactionType,
                    widget.plannedExpense.title,
                  ),
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAmountField(),
                const SizedBox(height: 20),
                _buildDatePicker(context),
                if (!isSharedEconomy) ...[
                  const SizedBox(height: 20),
                  _buildPayerSelector(eligiblePayers),
                ],
                const SizedBox(height: 32),
                _buildConfirmButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountField() {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).expensesPlannedPaymentAmountEyebrow,
          style: AppTypography.eyebrow.copyWith(
            color: theme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          autofocus: true,
          controller: _amountController,
          keyboardType: ref.watch(currencyProvider).inputFormat.keyboardType,
          inputFormatters: [
            AmountInputFormatter(ref.watch(currencyProvider).inputFormat),
          ],
          style: AppTypography.heroAmount.copyWith(
            fontSize: 32,
            color: theme.textPrimary,
          ),
          decoration: InputDecoration(
            prefixText: ref.watch(currencyProvider).inputPrefix(),
            filled: true,
            fillColor: theme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              borderSide: BorderSide(color: theme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              borderSide:
                  BorderSide(color: theme.border.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              borderSide:
                  BorderSide(color: theme.primary.withValues(alpha: 0.7)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).expensesPlannedPaymentDateEyebrow(
            widget.plannedExpense.transactionType,
          ),
          style: AppTypography.eyebrow.copyWith(
            color: theme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _paidAt,
              firstDate: DateTime.now().subtract(const Duration(days: 60)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) setState(() => _paidAt = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: theme.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE d, MMMM', 'es').format(_paidAt),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_calendar_rounded,
                  size: 20,
                  color: theme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayerSelector(List<MemberModel> members) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).expensesFormFieldPayer.toUpperCase(),
          style: AppTypography.eyebrow.copyWith(
            color: theme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: members.map((m) {
            final isSelected = _paidBy == m.userId;
            return GestureDetector(
              onTap: () => setState(() => _paidBy = m.userId),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isSelected)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      CustomUserAvatar(
                        avatarUrl: m.avatarUrl,
                        name: m.displayName,
                        radius: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.displayName.split(' ')[0],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w600,
                      color:
                          isSelected ? AppColors.primary : theme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    final theme = context.theme;
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                AppLocalizations.of(context).plannedExpensePaymentConfirmButton,
                style: AppTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
