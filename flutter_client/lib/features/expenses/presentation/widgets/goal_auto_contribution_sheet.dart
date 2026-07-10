import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Aporte mensual automático a una meta: gestiona la plantilla recurrente
/// vinculada (expense_templates.goal_id). El motor existente hace el resto —
/// genera el planificado, recuerda el vencimiento y, al confirmarlo, el
/// servidor registra la contribución en la meta.
///
/// Premium (usa el motor de recurrentes): free ve el paywall desde [show].
class GoalAutoContributionSheet extends ConsumerStatefulWidget {
  final SavingsGoalModel goal;

  const GoalAutoContributionSheet({super.key, required this.goal});

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    SavingsGoalModel goal,
  ) {
    final isPremium = ref.read(premiumProvider).value ?? false;
    if (!isPremium) {
      PremiumPaywall.show(context);
      return Future.value();
    }
    return AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalAutoContributionSheet(goal: goal),
    );
  }

  @override
  ConsumerState<GoalAutoContributionSheet> createState() =>
      _GoalAutoContributionSheetState();
}

class _GoalAutoContributionSheetState
    extends ConsumerState<GoalAutoContributionSheet> {
  final _amountController = TextEditingController();
  int _dayOfMonth = 1;
  bool _isSaving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  ExpenseTemplateModel? _linkedTemplate(List<ExpenseTemplateModel> templates) {
    for (final template in templates) {
      if (template.goalId == widget.goal.id) return template;
    }
    return null;
  }

  double? _parseAmount(String raw) {
    final normalized = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized)?.roundToDouble();
  }

  void _onAmountChanged(String val) {
    final parsed = _parseAmount(val);
    if (parsed == null) {
      _amountController.text = '';
      return;
    }
    final formatted =
        NumberFormat.decimalPattern('es_ES').format(parsed.round());
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  DateTime _nextExecutionDate(int day) {
    final now = DateTime.now();
    if (day >= now.day) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      return DateTime(now.year, now.month, day > daysInMonth ? daysInMonth : day);
    }
    final daysInNextMonth = DateTime(now.year, now.month + 2, 0).day;
    return DateTime(
      now.year,
      now.month + 1,
      day > daysInNextMonth ? daysInNextMonth : day,
    );
  }

  Future<void> _save(ExpenseTemplateModel? existing) async {
    final t = AppLocalizations.of(context);
    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) return;

    final householdId = await ref.read(householdIdProvider.future);
    final userId = ref.read(currentUserIdProvider);
    if (householdId == null || userId == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final template = ExpenseTemplateModel(
        id: existing?.id ?? const Uuid().v4(),
        householdId: householdId,
        title: widget.goal.title,
        titleKey: null,
        defaultAmount: amount,
        category: 'finanzas',
        dayOfMonth: _dayOfMonth,
        // Aporte personal de quien lo configura: no entra al pozo compartido
        // (la contribución server-side también se registra como personal).
        splitType: 'personal',
        payerDefault: existing?.payerDefault ?? userId,
        isActive: true,
        type: 'expense',
        goalId: widget.goal.id,
        nextExecutionDate: _nextExecutionDate(_dayOfMonth),
      );
      await ref
          .read(expenseTemplateControllerProvider.notifier)
          .saveTemplate(template);
      if (!mounted) return;
      AppHaptics.success();
      Navigator.pop(context);
      AppSnackBar.show(
        context,
        message: t.goalAutoSavedSnack,
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _disable(ExpenseTemplateModel existing) async {
    final t = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      await ref
          .read(expenseTemplateControllerProvider.notifier)
          .deleteTemplate(existing.id);
      if (!mounted) return;
      AppHaptics.success();
      Navigator.pop(context);
      AppSnackBar.show(
        context,
        message: t.goalAutoDisabledSnack,
        type: AppSnackBarType.neutral,
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final templatesAsync = ref.watch(expenseTemplateControllerProvider);

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
      child: templatesAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: AppLoader()),
        ),
        error: (e, _) => SizedBox(
          height: 160,
          child: Center(child: Text(t.commonErrorWithDetails('$e'))),
        ),
        data: (templates) {
          final existing = _linkedTemplate(templates);
          if (!_prefilled) {
            _prefilled = true;
            if (existing != null) {
              _amountController.text = NumberFormat.decimalPattern('es_ES')
                  .format(existing.defaultAmount.round());
              _dayOfMonth = existing.dayOfMonth;
            }
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
                      color: theme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      widget.goal.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.goalAutoTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t.goalAutoSubtitle(widget.goal.title),
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t.goalAutoAmountEyebrow,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: theme.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  autofocus: existing == null,
                  controller: _amountController,
                  onChanged: _onAmountChanged,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
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
                      borderSide: BorderSide(
                        color: theme.border.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      borderSide: BorderSide(
                        color: theme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t.goalAutoDayEyebrow,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: theme.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: theme.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _dayOfMonth,
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
                        if (day != null) setState(() => _dayOfMonth = day);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    if (existing != null) ...[
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed:
                                _isSaving ? null : () => _disable(existing),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.45),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                              ),
                            ),
                            child: Text(
                              t.goalAutoDisable,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              _isSaving ? null : () => _save(existing),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  t.commonSave,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
