import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

class CreateTaskDialog extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>>? members;

  const CreateTaskDialog({super.key, this.members});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _xpController = TextEditingController();
  final _coinController = TextEditingController();

  String? _selectedCategory;
  String _selectedDifficulty = 'medium';
  String? _selectedMemberId;

  /// Sprint 3 Modo Padres: pool de miembros entre los que rota la tarea.
  /// Solo se usa cuando la recurrencia esta seteada y el usuario tiene Modo
  /// Padres activo. Si esta vacio o tiene 1 solo miembro, no hay rotacion.
  final Set<String> _rotationPool = <String>{};
  String? _selectedRecurrence;
  String _customRecurrenceMode = 'weekdays';
  final Set<int> _selectedWeekdays = {};
  int _recurrenceInterval = 1;
  final Set<int> _selectedMonthDays = {};
  bool _customRewards = false;
  bool _isLoading = false;
  bool _showSuccessState = false;
  List<Map<String, dynamic>> _members = [];

  final List<Map<String, dynamic>> _difficulties = [
    {'id': 'easy', 'name': 'Facil', 'xp': 5, 'coins': 1},
    {'id': 'medium', 'name': 'Media', 'xp': 10, 'coins': 1},
    {'id': 'hard', 'name': 'Dificil', 'xp': 20, 'coins': 2},
  ];

  final List<Map<String, String>> _recurrenceOptions = [
    {'id': 'daily', 'name': 'Diaria'},
    {'id': 'weekly', 'name': 'Semanal'},
    {'id': 'monthly', 'name': 'Mensual'},
  ];

  Map<String, dynamic> get _currentDifficulty => _difficulties.firstWhere(
        (difficulty) => difficulty['id'] == _selectedDifficulty,
        orElse: () => _difficulties[1],
      );

  @override
  void initState() {
    super.initState();
    if (widget.members != null && widget.members!.isNotEmpty) {
      _members = widget.members!;
    } else {
      _loadMembers();
    }
    _loadDefaultCategory();
    _updateRewardControllers();
  }

  void _updateRewardControllers() {
    final difficulty = _currentDifficulty;
    _xpController.text = difficulty['xp'].toString();
    _coinController.text = difficulty['coins'].toString();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await ref.read(householdMembersNotifierProvider.future);
      setState(() {
        _members = members
            .map((member) => member.toMap())
            .toList()
            .cast<Map<String, dynamic>>();
      });
    } catch (e) {
      log.e('Error loading members: $e', error: e);
    }
  }

  Future<void> _loadDefaultCategory() async {
    try {
      final categories = await ref.read(categoriesProvider.future);
      if (!mounted || categories.isEmpty || _selectedCategory != null) return;
      setState(() => _selectedCategory = categories.first.id);
    } catch (e) {
      log.e('Error loading default task category: $e', error: e);
    }
  }

  String? _validateCustomRecurrence() {
    if (_selectedRecurrence != 'custom') return null;

    switch (_customRecurrenceMode) {
      case 'weekdays':
        if (_selectedWeekdays.isEmpty) {
          return 'Elige al menos un dia para la repeticion personalizada.';
        }
        break;
      case 'month_days':
        if (_selectedMonthDays.isEmpty) {
          return 'Elige al menos una fecha del mes.';
        }
        break;
      case 'interval':
        if (_recurrenceInterval < 1) {
          return 'El intervalo debe ser de al menos 1 dia.';
        }
        break;
    }

    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _xpController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Espera un momento y elige una categoria.'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    final recurrenceError = _validateCustomRecurrence();
    if (recurrenceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recurrenceError),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final tasks = ref.read(tasksProvider).value ?? [];
    final isDuplicate = tasks.any((task) {
      final sameTitle = task.title.toLowerCase().trim() == title.toLowerCase();
      final sameCategory = task.category == _selectedCategory;
      final sameAssignee = task.assignedTo == _selectedMemberId;
      return task.isActive && sameTitle && sameCategory && sameAssignee;
    });

    if (isDuplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una tarea identica activa'),
            backgroundColor: AppColors.accentOrange,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Sprint 3 Modo Padres: si hay pool valido (recurrente + 2+ miembros)
      // arrancamos asignando al primero del pool y delegamos la rotacion al
      // server (advance_task_rotation) en cada completion.
      final List<String>? rotationPoolList =
          (_selectedRecurrence != null && _rotationPool.length >= 2)
              ? _rotationPool.toList()
              : null;
      final assignedTo = rotationPoolList != null
          ? rotationPoolList.first
          : _selectedMemberId;

      await ref.read(tasksProvider.notifier).createTask({
        'title': title,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'xpReward': int.tryParse(_xpController.text) ?? 10,
        'coinReward': int.tryParse(_coinController.text) ?? 1,
        'assignedTo': assignedTo,
        'recurrenceType': _selectedRecurrence,
        'recurrenceInterval': _recurrenceInterval,
        'recurrenceWeekdays':
            _selectedRecurrence == 'custom' ? _selectedWeekdays.toList() : null,
        'recurrenceMonthDays': _selectedRecurrence == 'custom'
            ? _selectedMonthDays.toList()
            : null,
        'rotationPool': rotationPoolList,
      });

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _showSuccessState = true);
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showSuccessState = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <CategoryModel>[],
    );

    final currentCategoryId =
        _selectedCategory ?? (categories.isNotEmpty ? categories.first.id : '');

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.16),
                        ),
                      ),
                      child: const Icon(
                        Icons.add_task_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva tarea',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          'DETALLE',
                          'Que hay que hacer',
                          'Ponle un nombre claro para que se entienda de un vistazo.',
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Que hay que hacer',
                            prefixIcon: Icon(Icons.edit_note_rounded),
                          ),
                          validator: (value) {
                            final title = value?.trim() ?? '';
                            if (title.isEmpty) {
                              return 'Titulo requerido';
                            }
                            if (title.length < 3) {
                              return 'Usa al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notas (opcional)',
                            hintText:
                                'ej: "usar el limpiapisos azul", "revisar el filtro tambien"',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Icon(Icons.notes_rounded),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionHeader(
                          'CATEGORIA',
                          'Donde vive mejor',
                          'Elige la zona del hogar para que aparezca ordenada.',
                        ),
                        const SizedBox(height: 10),
                        categoriesAsync.when(
                          data: (_) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: categories.map((category) {
                                final isSelected =
                                    currentCategoryId == category.id;
                                final color = AppColors.fromHex(category.color);
                                return GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedCategory = category.id,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? color.withValues(alpha: 0.15)
                                                : const Color(0xFFF8FAFC),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? color
                                                  : const Color(0xFFF1F5F9),
                                              width: isSelected ? 2.5 : 1.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: color.withValues(
                                                        alpha: 0.2,
                                                      ),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              CategoryMapping
                                                  .getCategoryMaterialIcon(
                                                category.id,
                                              ),
                                              color: isSelected
                                                  ? color
                                                  : color.withValues(
                                                      alpha: 0.8,
                                                    ),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? color
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          error: (_, __) => const SizedBox(),
                        ),
                        const SizedBox(height: 20),
                        _buildSectionHeader(
                          'FRECUENCIA',
                          'Cuando se repite',
                          'Puede quedar unica, repetirse o seguir un patron propio.',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFrequencyChip('Sin repetir', null),
                            ..._recurrenceOptions.map(
                              (recurrence) => _buildFrequencyChip(
                                recurrence['name']!,
                                recurrence['id'],
                              ),
                            ),
                            _buildFrequencyChip('Personalizada', 'custom'),
                          ],
                        ),
                        if (_selectedRecurrence == 'custom') ...[
                          const SizedBox(height: 16),
                          _buildCustomRecurrenceMenu(),
                        ],
                        const SizedBox(height: 20),
                        _buildSectionHeader(
                          'RESPONSABLE',
                          'Quien puede hacerla',
                          'Puedes dejarla abierta o asignarla a alguien en particular.',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildAssigneeChip('Cualquiera', null, 'C'),
                            ..._members.map((member) {
                              final name = member['users']['full_name'] ??
                                  member['users']['email'] ??
                                  'Miembro';
                              final initial =
                                  name.toString().substring(0, 1).toUpperCase();
                              return _buildAssigneeChip(
                                name,
                                member['user_id'] as String,
                                initial,
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildRotationSection(),
                        _buildSectionHeader(
                          'VALOR',
                          'Cuanto vale completarla',
                          'La dificultad define puntos y coins de forma rapida.',
                        ),
                        const SizedBox(height: 10),
                        _buildDifficultySection(),
                        const SizedBox(height: 16),
                        _buildRewardsSection(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: AnimatedPress(
                          scale: _isLoading ? 1 : 0.97,
                          onTap: _isLoading ? null : _handleSubmit,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textPrimary,
                              disabledBackgroundColor: AppColors.textPrimary,
                              disabledForegroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutBack,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: _isLoading
                                  ? const SizedBox(
                                      key: ValueKey('loading'),
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : _showSuccessState
                                      ? const Row(
                                          key: ValueKey('success'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Tarea creada',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          key: ValueKey('idle'),
                                          'Crear tarea',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
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
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String eyebrow, String title, String subtitle) {
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

  Widget _buildFrequencyChip(String label, String? value) {
    final isSelected = _selectedRecurrence == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRecurrence = value;
        if (value == 'custom' &&
            _selectedWeekdays.isEmpty &&
            _selectedMonthDays.isEmpty) {
          _selectedWeekdays.add(DateTime.now().weekday);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGold.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentGold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.accentGold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRecurrenceMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCustomModeTab('Por dia', 'weekdays'),
              _buildCustomModeTab('Intervalo', 'interval'),
              _buildCustomModeTab('Fecha', 'month_days'),
            ],
          ),
          const SizedBox(height: 16),
          if (_customRecurrenceMode == 'weekdays') _buildWeekdaySelector(),
          if (_customRecurrenceMode == 'interval') _buildIntervalSelector(),
          if (_customRecurrenceMode == 'month_days') _buildMonthDaySelector(),
        ],
      ),
    );
  }

  Widget _buildCustomModeTab(String label, String mode) {
    final isSelected = _customRecurrenceMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _customRecurrenceMode = mode),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: 24,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = _selectedWeekdays.contains(dayNum);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedWeekdays.remove(dayNum);
              } else {
                _selectedWeekdays.add(dayNum);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIntervalSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Repetir cada',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.remove,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  if (_recurrenceInterval > 1) {
                    setState(() => _recurrenceInterval--);
                  }
                },
              ),
              Container(
                alignment: Alignment.center,
                width: 30,
                child: Text(
                  _recurrenceInterval.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.add,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  if (_recurrenceInterval < 365) {
                    setState(() => _recurrenceInterval++);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'dias',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMonthDaySelector() {
    return Column(
      children: [
        const Text(
          'Elige los dias del mes',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: List.generate(31, (index) {
            final day = index + 1;
            final isSelected = _selectedMonthDays.contains(day);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedMonthDays.remove(day);
                  } else {
                    _selectedMonthDays.add(day);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentGreen : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.accentGreen : AppColors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Sprint 3 Modo Padres: selector de pool de rotacion. Solo se muestra
  /// cuando la tarea es recurrente y el usuario tiene Modo Padres disponible
  /// (admin de family con premium). Si el flag no esta, devolvemos un
  /// SizedBox.shrink y la seccion no ocupa lugar.
  Widget _buildRotationSection() {
    if (_selectedRecurrence == null) return const SizedBox.shrink();
    final available = ref.watch(parentModeAvailableProvider);
    if (!available) return const SizedBox.shrink();
    if (_members.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'ROTACION',
          'Que se turnen los miembros',
          'Elegi al menos dos. Cada vez que se complete, le toca al siguiente.',
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _members.map((member) {
            final id = member['user_id'] as String;
            final name = member['users']['full_name'] ??
                member['users']['email'] ??
                'Miembro';
            final initial =
                name.toString().substring(0, 1).toUpperCase();
            final selected = _rotationPool.contains(id);
            return GestureDetector(
              onTap: () => setState(() {
                if (selected) {
                  _rotationPool.remove(id);
                } else {
                  _rotationPool.add(id);
                }
              }),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accentBlue.withValues(alpha: 0.12)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: selected
                        ? AppColors.accentBlue
                        : const Color(0xFFF1F5F9),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: selected
                          ? AppColors.accentBlue
                          : const Color(0xFFCBD5E1),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name.toString(),
                      style: TextStyle(
                        color: selected
                            ? AppColors.accentBlue
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_rotationPool.length == 1)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Necesitas al menos 2 personas en el pool.',
              style: TextStyle(
                color: AppColors.accentOrange,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAssigneeChip(String name, String? id, String initial) {
    final isSelected = _selectedMemberId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMemberId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor:
                  isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name.split(' ')[0],
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Row(
      children: _difficulties.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDifficulty = difficulty['id'] as String;
                if (!_customRewards) {
                  _updateRewardControllers();
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: difficulty != _difficulties.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    difficulty['name'] as String,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${difficulty['xp']} XP / ${difficulty['coins']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.monetization_on_rounded,
                        size: 11,
                        color: isSelected ? AppColors.primary : AppColors.sage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recompensas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _customRewards = !_customRewards;
                  if (!_customRewards) {
                    _updateRewardControllers();
                  }
                }),
                child: Row(
                  children: [
                    Icon(
                      _customRewards
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: _customRewards
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Personalizar',
                      style: TextStyle(
                        fontSize: 12,
                        color: _customRewards
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _xpController,
                  enabled: _customRewards,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'XP',
                    prefixIcon: Icon(
                      Icons.star_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: TextStyle(
                    color: _customRewards
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                  validator: (value) {
                    if (!_customRewards) return null;
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null) return 'Ingresa un numero';
                    if (parsed <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _coinController,
                  enabled: _customRewards,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Coins',
                    prefixIcon: Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.sage,
                      size: 20,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: TextStyle(
                    color: _customRewards
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                  validator: (value) {
                    if (!_customRewards) return null;
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null) return 'Ingresa un numero';
                    if (parsed < 0) return 'No puede ser negativo';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
