import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'expense_category_matcher.dart';

class RecurringExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpenseTemplateModel? template;

  const RecurringExpenseFormSheet({super.key, this.template});

  @override
  ConsumerState<RecurringExpenseFormSheet> createState() =>
      _RecurringExpenseFormSheetState();

  static Future<void> show(BuildContext context,
      {ExpenseTemplateModel? template}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: RecurringExpenseFormSheet(template: template),
        ),
      ),
    );
  }
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
    {'id': 'rent', 'name': 'Alquiler y hogar'},
    {'id': 'restaurants', 'name': 'Salidas y comidas'},
    {'id': 'transport', 'name': 'Transporte'},
    {'id': 'entertainment', 'name': 'Ocio y planes'},
    {'id': 'health', 'name': 'Salud'},
    {'id': 'finanzas', 'name': 'Ahorro e inversión'},
    {'id': 'mercadolibre', 'name': 'Compras online'},
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
    _titleController.addListener(_onTitleChanged);
    _initializeDefaultPayer();
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    if (widget.template != null) return;
    final inferredCategory =
        inferExpenseCategoryIdFromText(_titleController.text);
    if (inferredCategory == null) return;
    if (_category == inferredCategory) return;
    if (_categories.any((category) => category['id'] == inferredCategory)) {
      setState(() => _category = inferredCategory);
    }
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
    } catch (error, stackTrace) {
      log.w(
        'RecurringExpenseFormSheet could not initialize default payer',
        error: error,
        stackTrace: stackTrace,
      );
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
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
      child: SafeArea(
        top: false,
        child: membersAsync.when(
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (members) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, 28 + bottomInset),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 56,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.divider.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildHeader(),
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: 'DETALLE',
                            title: 'Qué se renueva cada mes',
                            subtitle:
                                'Define el nombre y el monto para reconocerla rápido.',
                          ),
                          const SizedBox(height: 16),
                          _buildTitleField(),
                          const SizedBox(height: 16),
                          _buildAmountField(),
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: 'CALENDARIO',
                            title: 'Cuándo se registra',
                            subtitle:
                                'Elegimos el día habitual para programarla sola.',
                          ),
                          const SizedBox(height: 16),
                          _buildDaySelector(),
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: 'CATEGORÍA',
                            title: 'Dónde encaja mejor',
                            subtitle:
                                'Ayuda a ordenar Finanzas y mantener la lectura clara.',
                          ),
                          const SizedBox(height: 16),
                          _buildCategorySelector(),
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: 'REPARTO',
                            title: 'Cómo se reparte',
                            subtitle:
                                'Define si se divide entre ambos o si queda como personal.',
                          ),
                          const SizedBox(height: 16),
                          _buildSplitTypeSelector(),
                          if (_splitType != 'personal') ...[
                            const SizedBox(height: 28),
                            _buildSectionIntro(
                              eyebrow: 'PAGADOR',
                              title: 'Quién suele abonarla',
                              subtitle:
                                  'Esto deja una sugerencia lista para los próximos meses.',
                            ),
                            const SizedBox(height: 16),
                            _buildPayerSelector(members),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomActions(bottomInset),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: const Icon(
                Icons.autorenew_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template == null
                        ? 'Nueva suscripción'
                        : 'Editar suscripción',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.template == null
                        ? 'Dejala configurada y lista para que se registre sola todos los meses.'
                        : 'Ajusta monto, categoría y reparto para mantenerla al día.',
                    style: const TextStyle(
                      fontSize: 15.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.textMuted,
                size: 36,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        if (widget.template != null) ...[
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Eliminar suscripción'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.22)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
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
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
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
            final categoryColor =
                CategoryMapping.getCategoryColor(category['id']);
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CategoryMapping.getCategoryMaterialIcon(category['id']),
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
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.6,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Guardar suscripción',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomActions(double bottomInset) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(24, 18, 24, bottomInset > 0 ? bottomInset : 18),
      decoration: BoxDecoration(
        color: context.theme.background.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildSaveButton()),
        ],
      ),
    );
  }
}
