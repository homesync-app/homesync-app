import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/expenses/domain/models/category_budget_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/budget_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_data.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:intl/intl.dart';

/// Gestión de presupuestos: lista con topes actuales y alta de categorías
/// nuevas. Editar/crear abre el sub-sheet [_BudgetEditSheet].
class BudgetManageSheet extends ConsumerWidget {
  const BudgetManageSheet({super.key});

  static Future<void> show(
    BuildContext context, {
    CategoryBudgetModel? editBudget,
  }) {
    if (editBudget != null) {
      return _BudgetEditSheet.show(context, budget: editBudget);
    }
    return AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BudgetManageSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final budgetsAsync = ref.watch(categoryBudgetsProvider);
    final isSharedEconomy =
        ref.watch(currentHouseholdProvider).value?.financeMode == 'shared';
    final currency = ref.watch(currencyProvider);

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
      child: budgetsAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: AppLoader()),
        ),
        error: (e, _) => SizedBox(
          height: 160,
          child: Center(child: Text(t.commonErrorWithDetails('$e'))),
        ),
        data: (budgets) {
          final budgetedIds = budgets.map((b) => b.category).toSet();
          final canAddMore = buildExpenseCategories()
              .where((c) => c['id'] != 'settlement')
              .any((c) => !budgetedIds.contains(c['id']));

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
                  t.budgetsManageTitle,
                  style: AppTypography.sectionTitle.copyWith(
                    fontSize: 22,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSharedEconomy
                      ? t.budgetsManageSubtitleShared
                      : t.budgetsManageSubtitlePersonal,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                if (budgets.isEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        t.budgetsManageEmpty,
                        style: TextStyle(
                          color: theme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  ...budgets.map(
                    (budget) => _BudgetRow(
                      budget: budget,
                      currencyLabel:
                          currency.format(budget.monthlyLimit.round()),
                      onTap: () =>
                          _BudgetEditSheet.show(context, budget: budget),
                    ),
                  ),
                const SizedBox(height: 12),
                if (canAddMore)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _BudgetEditSheet.show(context),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        t.budgetsAddCategory,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(
                          color: theme.primary.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final CategoryBudgetModel budget;
  final String currencyLabel;
  final VoidCallback onTap;

  const _BudgetRow({
    required this.budget,
    required this.currencyLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final categories = buildExpenseCategories();
    final category = categories.firstWhere(
      (c) => c['id'] == budget.category,
      orElse: () => categories.last,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: theme.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Text(
                category['icon'] as String,
                style: AppTypography.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizedExpenseCategoryName(t, budget.category),
                  style: AppTypography.bodyStrong.copyWith(
                    fontSize: 14.5,
                    color: theme.textPrimary,
                  ),
                ),
              ),
              Text(
                currencyLabel,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alta/edición de un presupuesto: selector de categoría (solo en alta) y
/// tope mensual entero es-AR.
class _BudgetEditSheet extends ConsumerStatefulWidget {
  final CategoryBudgetModel? budget;

  const _BudgetEditSheet({this.budget});

  static Future<void> show(
    BuildContext context, {
    CategoryBudgetModel? budget,
  }) {
    return AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BudgetEditSheet(budget: budget),
    );
  }

  @override
  ConsumerState<_BudgetEditSheet> createState() => _BudgetEditSheetState();
}

class _BudgetEditSheetState extends ConsumerState<_BudgetEditSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategory;
  bool _isSaving = false;

  bool get _isEdit => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _selectedCategory = widget.budget!.category;
      _amountController.text = NumberFormat.decimalPattern('es_ES')
          .format(widget.budget!.monthlyLimit.round());
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0 || _selectedCategory == null) return;

    setState(() => _isSaving = true);
    try {
      final mutations = ref.read(categoryBudgetMutationsProvider);
      if (_isEdit) {
        await mutations.updateLimit(
          id: widget.budget!.id,
          monthlyLimit: amount,
        );
      } else {
        await mutations.create(
          category: _selectedCategory!,
          monthlyLimit: amount,
        );
      }
      if (!mounted) return;
      AppHaptics.success();
      Navigator.pop(context);
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

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final categoryName =
        localizedExpenseCategoryName(t, widget.budget!.category);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: Text(
          t.budgetsDeleteTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          t.budgetsDeleteBody(categoryName),
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(categoryBudgetMutationsProvider)
          .delete(widget.budget!.id);
      if (!mounted) return;
      AppHaptics.success();
      Navigator.pop(context);
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
    final budgetedCategories = ref
            .watch(categoryBudgetsProvider)
            .value
            ?.map((b) => b.category)
            .toSet() ??
        const <String>{};

    final selectableCategories = buildExpenseCategories()
        .where(
          (c) =>
              c['id'] != 'settlement' &&
              (!budgetedCategories.contains(c['id']) ||
                  c['id'] == widget.budget?.category),
        )
        .toList(growable: false);

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
      child: SingleChildScrollView(
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
              _isEdit ? t.budgetsEditTitle : t.budgetsNewTitle,
              style: AppTypography.sectionTitle.copyWith(
                fontSize: 22,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            if (!_isEdit) ...[
              Text(
                t.budgetsCategoryEyebrow,
                style: AppTypography.eyebrow.copyWith(
                  color: theme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectableCategories.map((category) {
                  final id = category['id'] as String;
                  final isSelected = _selectedCategory == id;
                  return ChoiceChip(
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = id),
                    showCheckmark: false,
                    label: Text(
                      '${category['icon']} '
                      '${localizedExpenseCategoryName(t, id)}',
                    ),
                    labelStyle: AppTypography.caption.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : theme.textPrimary,
                    ),
                    selectedColor: theme.primary,
                    backgroundColor: theme.surface,
                    side: BorderSide(
                      color: isSelected
                          ? theme.primary
                          : theme.border.withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              t.budgetsLimitEyebrow,
              style: AppTypography.eyebrow.copyWith(
                color: theme.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              autofocus: _isEdit,
              controller: _amountController,
              onChanged: _onAmountChanged,
              keyboardType: TextInputType.number,
              style: AppTypography.heroAmount.copyWith(
                fontSize: 28,
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
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                if (_isEdit) ...[
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : _delete,
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
                          t.commonDelete,
                          style:
                              const TextStyle(fontWeight: FontWeight.w800),
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
                      onPressed: _isSaving ? null : _save,
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
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
