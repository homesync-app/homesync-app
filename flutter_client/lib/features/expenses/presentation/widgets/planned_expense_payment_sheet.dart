import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
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
    return showModalBottomSheet<Map<String, dynamic>>(
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
    final initialAmount = widget.plannedExpense.amount.toInt();
    _amountController.text = NumberFormat.decimalPattern('es_ES')
        .format(initialAmount);
    _paidBy = widget.plannedExpense.payerId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll('.', '').replaceAll(',', '');
    if (clean.isEmpty) {
      _amountController.text = '';
      return;
    }

    final parsed = int.tryParse(clean);
    if (parsed != null) {
      final formatted = NumberFormat.decimalPattern('es_ES').format(parsed);
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _confirmPayment() async {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(
        _amountController.text.replaceAll('.', '').replaceAll(',', ''),
      );

      final result =
          await ref.read(combinedFeedControllerProvider.notifier).payPlannedExpense(
                plannedId: widget.plannedExpense.id,
                amount: amount,
                paidAt: _paidAt,
                paidBy: _paidBy,
              );

      if (!mounted) return;

      final templateUpdated = result['template_updated'] == true;
      Navigator.pop(context, {
        'success': true,
        'template_updated': templateUpdated,
        'title': widget.plannedExpense.title,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).commonErrorWithDetails('$e'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: membersAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Center(
          child: Text(AppLocalizations.of(context).commonErrorWithDetails('$e')),
        ),
        data: (List<MemberModel> members) {
          if (_paidBy.isEmpty && members.isNotEmpty) {
            _paidBy = members.first.userId;
          }

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
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).expensesPlannedPaymentTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)
                      .expensesPlannedPaymentSubtitle(widget.plannedExpense.title),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAmountField(),
                const SizedBox(height: 20),
                _buildDatePicker(context),
                const SizedBox(height: 20),
                _buildPayerSelector(members),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).expensesPlannedPaymentAmountEyebrow,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textMuted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          autofocus: true,
          controller: _amountController,
          onChanged: _onAmountChanged,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixText: '\$ ',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).expensesPlannedPaymentDateEyebrow,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textMuted,
            letterSpacing: 1,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.edit_calendar_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayerSelector(List<MemberModel> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUIEN PAGO?',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textMuted,
            letterSpacing: 1,
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
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
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
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Confirmar y registrar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }
}

