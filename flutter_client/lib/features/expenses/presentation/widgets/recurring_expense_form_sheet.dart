import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class RecurringExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpenseTemplateModel? template;

  const RecurringExpenseFormSheet({super.key, this.template});

  @override
  ConsumerState<RecurringExpenseFormSheet> createState() =>
      _RecurringExpenseFormSheetState();
}

class _RecurringExpenseFormSheetState
    extends ConsumerState<RecurringExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  int _dayOfMonth = DateTime.now().day;
  String _category = 'utilities';
  String _splitType = 'equal';
  String _payerDefault = '';
  bool _isLoading = false;

  final List<Map<String, String>> _categories = const [
    {'id': 'utilities', 'name': 'Servicios'},
    {'id': 'rent', 'name': 'Alquiler'},
    {'id': 'supermarket', 'name': 'Suscripciones'},
    {'id': 'entertainment', 'name': 'Hobby'},
    {'id': 'transport', 'name': 'Seguros'},
    {'id': 'health', 'name': 'Salud'},
    {'id': 'finanzas', 'name': 'Ahorro / Inversion'},
    {'id': 'other', 'name': 'Otros'},
  ];

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    if (template != null) {
      _titleController.text = template.title;
      _amountController.text = NumberFormat.decimalPattern('es_ES').format(
        template.defaultAmount.round(),
      );
      _dayOfMonth = template.dayOfMonth;
      _category = template.category;
      _splitType = template.splitType;
      _payerDefault = template.payerDefault;
    }
    _initializeDefaultPayer();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  double? _parseAmount(String raw) {
    final normalized = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<void> _initializeDefaultPayer() async {
    try {
      final members = await ref.read(householdMembersProvider.future);
      if (!mounted || members.isEmpty || _payerDefault.isNotEmpty) return;
      setState(() => _payerDefault = members.first.userId);
    } catch (_) {
      // If members are not available yet, the selector will show loading/error.
    }
  }

  void _onAmountChanged(String value) {
    final clean = value.replaceAll('.', '').replaceAll(',', '');
    if (clean.isEmpty) {
      _amountController.text = '';
      return;
    }

    final parsed = int.tryParse(clean);
    if (parsed == null) return;

    final formatted = NumberFormat.decimalPattern('es_ES').format(parsed);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  DateTime _calculateNextExecutionDate(int day) {
    final now = DateTime.now();
    if (day >= now.day) {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      return DateTime(
        now.year,
        now.month,
        day > daysInMonth ? daysInMonth : day,
      );
    }

    final daysInNextMonth = DateTime(now.year, now.month + 2, 0).day;
    return DateTime(
      now.year,
      now.month + 1,
      day > daysInNextMonth ? daysInNextMonth : day,
    );
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final title = _titleController.text.trim();
    final parsedAmount = _parseAmount(_amountController.text);

    if (title.isEmpty || parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa titulo y monto valido.')),
      );
      return;
    }

    if (_splitType != 'personal' && _payerDefault.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige quien suele abonarla para dejarla lista.'),
        ),
      );
      return;
    }

    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    setState(() => _isLoading = true);
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      final template = ExpenseTemplateModel(
        id: widget.template?.id ?? const Uuid().v4(),
        householdId: householdId,
        title: title,
        defaultAmount: parsedAmount,
        category: _category,
        dayOfMonth: _dayOfMonth,
        splitType: _splitType,
        payerDefault: _splitType == 'personal'
            ? (currentUserId ?? _payerDefault)
            : _payerDefault,
        isActive: true,
        nextExecutionDate: _calculateNextExecutionDate(_dayOfMonth),
      );

      await ref
          .read(expenseTemplateControllerProvider.notifier)
          .saveTemplate(template);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final template = widget.template;
    if (template == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar suscripcion?'),
        content: const Text('Dejara de aparecer en futuros meses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ref
        .read(expenseTemplateControllerProvider.notifier)
        .deleteTemplate(template.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: membersAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (members) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildSectionIntro(
                    eyebrow: 'DETALLE',
                    title: 'Que se renueva cada mes',
                    subtitle:
                        'Define el nombre y el monto para reconocerla rapido.',
                  ),
                  const SizedBox(height: 16),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildAmountField(),
                  const SizedBox(height: 24),
                  _buildSectionIntro(
                    eyebrow: 'CALENDARIO',
                    title: 'Cuando se registra',
                    subtitle: 'Elegimos el dia habitual para programarla sola.',
                  ),
                  const SizedBox(height: 16),
                  _buildDaySelector(),
                  const SizedBox(height: 24),
                  _buildSectionIntro(
                    eyebrow: 'CATEGORIA',
                    title: 'Donde encaja mejor',
                    subtitle:
                        'Ayuda a ordenar Finanzas y mantener la lectura clara.',
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelector(),
                  const SizedBox(height: 24),
                  _buildSectionIntro(
                    eyebrow: 'REPARTO',
                    title: 'Como se reparte',
                    subtitle:
                        'Define si se divide entre ambos o si queda como personal.',
                  ),
                  const SizedBox(height: 16),
                  _buildSplitTypeSelector(),
                  if (_splitType != 'personal') ...[
                    const SizedBox(height: 24),
                    _buildSectionIntro(
                      eyebrow: 'PAGADOR',
                      title: 'Quien suele abonarla',
                      subtitle:
                          'Esto deja una sugerencia lista para los proximos meses.',
                    ),
                    const SizedBox(height: 16),
                    _buildPayerSelector(members),
                  ],
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: const Icon(
                Icons.autorenew_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const Spacer(),
            if (widget.template != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                onPressed: _delete,
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          widget.template == null ? 'Nueva suscripcion' : 'Editar suscripcion',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionIntro({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: AppColors.primary.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textInputAction: TextInputAction.next,
      validator: (value) {
        final title = value?.trim() ?? '';
        if (title.isEmpty) return 'Escribe un nombre para reconocerla.';
        if (title.length < 3) return 'Usa al menos 3 caracteres.';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Nombre',
        hintText: 'Ej: Netflix, alquiler o internet',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      onChanged: _onAmountChanged,
      validator: (value) {
        final amount = _parseAmount(value ?? '');
        if (amount == null) return 'Ingresa un monto valido.';
        if (amount <= 0) return 'El monto debe ser mayor a cero.';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Monto por defecto',
        prefixText: r'$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Se cobra el dia:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
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
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.divider.withValues(alpha: 0.65),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w500,
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
        const Text(
          'Categoria:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _category == category['id'];
            final categoryColor = AppColors.getCategoryColor(category['id']);
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppColors.getCategoryMaterialIcon(category['id']),
                    size: 16,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(category['name']!),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _category = category['id']!),
              selectedColor: categoryColor.withValues(alpha: 0.16),
              backgroundColor: categoryColor.withValues(alpha: 0.07),
              checkmarkColor: categoryColor,
              side: BorderSide(
                color: isSelected
                    ? categoryColor.withValues(alpha: 0.9)
                    : categoryColor.withValues(alpha: 0.22),
              ),
              labelStyle: TextStyle(
                color: isSelected ? categoryColor : AppColors.textSecondary,
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
        const Text(
          'Reparto de gasto:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSplitOption('equal', 'Dividir 50/50', Icons.groups_rounded),
            const SizedBox(width: 12),
            _buildSplitOption('personal', 'Solo mio', Icons.person_rounded),
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
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.divider.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: isSelected ? 0.03 : 0.015),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayerSelector(List<MemberModel> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pagador habitual:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: members.map((member) {
            final isSelected = _payerDefault == member.userId;
            return GestureDetector(
              onTap: () => setState(() => _payerDefault = member.userId),
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.58,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: isSelected
                      ? BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.6,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        )
                      : null,
                  child: CustomUserAvatar(
                    avatarUrl: member.avatarUrl,
                    name: member.displayName,
                    radius: 24,
                  ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Guardar suscripcion',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}
