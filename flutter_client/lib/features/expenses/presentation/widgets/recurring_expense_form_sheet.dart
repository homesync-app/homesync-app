import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class RecurringExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpenseTemplateModel? template;

  const RecurringExpenseFormSheet({super.key, this.template});

  @override
  ConsumerState<RecurringExpenseFormSheet> createState() => _RecurringExpenseFormSheetState();
}

class _RecurringExpenseFormSheetState extends ConsumerState<RecurringExpenseFormSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  int _dayOfMonth = DateTime.now().day;
  String _category = 'utilities';
  String _splitType = 'equal';
  String _payerDefault = '';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'utilities', 'name': 'Servicios', 'icon': '💡'},
    {'id': 'rent', 'name': 'Alquiler', 'icon': '🏠'},
    {'id': 'supermarket', 'name': 'Suscripciones', 'icon': '📺'},
    {'id': 'entertainment', 'name': 'Hobby', 'icon': '🎬'},
    {'id': 'transport', 'name': 'Seguros', 'icon': '🚙'},
    {'id': 'health', 'name': 'Salud', 'icon': '💊'},
    {'id': 'finanzas', 'name': 'Ahorro / Inversión', 'icon': '🏦'},
    {'id': 'other', 'name': 'Otros', 'icon': '📦'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _titleController.text = widget.template!.title;
      _amountController.text = NumberFormat.decimalPattern('es_ES').format(widget.template!.defaultAmount.toInt());
      _dayOfMonth = widget.template!.dayOfMonth;
      _category = widget.template!.category;
      _splitType = widget.template!.splitType;
      _payerDefault = widget.template!.payerDefault;
    }
  }

  void _onAmountChanged(String val) {
    String clean = val.replaceAll('.', '').replaceAll(',', '');
    if (clean.isEmpty) {
      _amountController.text = '';
      return;
    }
    int? parsed = int.tryParse(clean);
    if (parsed != null) {
      String formatted = NumberFormat.decimalPattern('es_ES').format(parsed);
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  DateTime _calculateNextExecutionDate(int day) {
    final now = DateTime.now();
    if (day >= now.day) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final actualDay = day > daysInMonth ? daysInMonth : day;
      return DateTime(now.year, now.month, actualDay);
    } else {
      final daysInNextMonth = DateTime(now.year, now.month + 2, 0).day;
      final actualDay = day > daysInNextMonth ? daysInNextMonth : day;
      return DateTime(now.year, now.month + 1, actualDay);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completá los campos obligatorios.')));
      return;
    }

    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    setState(() => _isLoading = true);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      final template = ExpenseTemplateModel(
        id: widget.template?.id ?? const Uuid().v4(),
        householdId: householdId as String,
        title: _titleController.text.trim(),
        defaultAmount: double.parse(_amountController.text.replaceAll('.', '').replaceAll(',', '')),
        category: _category,
        dayOfMonth: _dayOfMonth,
        splitType: _splitType,
        payerDefault: _splitType == 'personal' ? (currentUserId ?? _payerDefault) : _payerDefault,
        isActive: true,
        nextExecutionDate: _calculateNextExecutionDate(_dayOfMonth),
      );

      await ref.read(expenseTemplateControllerProvider.notifier).saveTemplate(template);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: membersAsync.when(
        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (members) {
          if (_payerDefault.isEmpty && members.isNotEmpty) {
            _payerDefault = members.first.userId;
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 24),
                _buildDaySelector(),
                const SizedBox(height: 24),
                _buildCategorySelector(),
                const SizedBox(height: 24),
                _buildSplitTypeSelector(),
                if (_splitType != 'personal') ...[
                  const SizedBox(height: 24),
                  _buildPayerSelector(members),
                ],
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.template == null ? 'Nueva Suscripción' : 'Editar Suscripción',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
        if (widget.template != null)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Eliminar suscripción?'),
                  content: const Text('Dejará de aparecer en futuros meses.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), 
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(expenseTemplateControllerProvider.notifier).deleteTemplate(widget.template!.id);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Nombre (ej: Netflix, Alquiler)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      onChanged: _onAmountChanged,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Monto por defecto',
        prefixText: '\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Se cobra el día:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = _dayOfMonth == day;
              return GestureDetector(
                onTap: () => setState(() => _dayOfMonth = day),
                child: Container(
                  width: 44,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((c) {
            final isSelected = _category == c['id'];
            return ChoiceChip(
              label: Text('${c['icon']} ${c['name']}'),
              selected: isSelected,
              onSelected: (val) => setState(() => _category = c['id']),
              selectedColor: AppColors.primary.withValues(alpha: 0.1),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSplitTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reparto de gasto:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSplitOption('equal', 'Dividir 50/50', Icons.groups_rounded),
            const SizedBox(width: 12),
            _buildSplitOption('personal', 'Solo mío', Icons.person_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildSplitOption(String type, String label, IconData icon) {
    final isSelected = _splitType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _splitType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayerSelector(List<dynamic> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pagador habitual:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: members.map((m) {
            final isSelected = _payerDefault == m.userId;
            return GestureDetector(
              onTap: () => setState(() => _payerDefault = m.userId),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.5,
                child: Container(
                  decoration: isSelected ? BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    shape: BoxShape.circle,
                  ) : null,
                  child: CustomUserAvatar(avatarUrl: m.avatarUrl, name: m.displayName, radius: 24),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('Guardar Suscripción', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}
