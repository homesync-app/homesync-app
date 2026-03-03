import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';


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

  String? _selectedCategory; // initialised from DB on first build
  String _selectedDifficulty = 'medium';
  String? _selectedMemberId;
  String? _selectedRecurrence;
  String _customRecurrenceMode = 'weekdays';
  final Set<int> _selectedWeekdays = {};
  int _recurrenceInterval = 1;
  final Set<int> _selectedMonthDays = {};
  bool _customRewards = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _members = [];
  final List<Map<String, dynamic>> _difficulties = [
    {'id': 'easy', 'name': 'Fácil', 'xp': 5, 'coins': 1},
    {'id': 'medium', 'name': 'Medio', 'xp': 10, 'coins': 2},
    {'id': 'hard', 'name': 'Difícil', 'xp': 20, 'coins': 5},
  ];

  final List<Map<String, String>> _recurrenceOptions = [
    {'id': 'daily', 'name': 'Diario'},
    {'id': 'weekly', 'name': 'Semanal'},
    {'id': 'monthly', 'name': 'Mensual'},
  ];

  Map<String, dynamic> get _currentDifficulty => _difficulties.firstWhere(
        (d) => d['id'] == _selectedDifficulty,
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
    _updateRewardControllers();
  }

  void _updateRewardControllers() {
    final diff = _currentDifficulty;
    _xpController.text = diff['xp'].toString();
    _coinController.text = diff['coins'].toString();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await ref.read(householdMembersProvider.future);
      setState(() => _members = members.map((m) => m.toMap()).toList().cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Error loading members: $e');
    }
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

    setState(() => _isLoading = true);

    try {
      await ref.read(tasksProvider.notifier).createTask({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category': _selectedCategory,
        'difficulty': _selectedDifficulty,
        'xpReward': int.tryParse(_xpController.text) ?? 10,
        'coinReward': int.tryParse(_coinController.text) ?? 5,
        'assignedTo': _selectedMemberId,
        'recurrenceType': _selectedRecurrence,
      });

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <CategoryModel>[],
    );

    // Initialise selected category to the first DB entry on first build
    if (_selectedCategory == null && categories.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedCategory = categories.first.id);
      });
    }
    final currentCategoryId = _selectedCategory ?? (categories.isNotEmpty ? categories.first.id : '');

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_task_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    const Text('Nueva Tarea',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: '¿Qué hay que hacer?',
                            prefixIcon: Icon(Icons.edit_note_rounded),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Título requerido'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notas (opcional)',
                            hintText:
                                'ej: "usar el limpiapisos azul", "revisar el filtro también"',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Icon(Icons.notes_rounded),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ── Category picker ─────────────────────────────
                        const Text('Categoría',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        categoriesAsync.when(
                          data: (_) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: categories.map((cat) {
                                final isSelected = currentCategoryId == cat.id;
                                final color = AppColors.fromHex(cat.color);
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedCategory = cat.id),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 56, height: 56,
                                          decoration: BoxDecoration(
                                            color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFFF8FAFC),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? color : const Color(0xFFF1F5F9),
                                              width: isSelected ? 2.5 : 1.5,
                                            ),
                                            boxShadow: isSelected ? [
                                              BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
                                            ] : [],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              AppColors.getCategoryMaterialIcon(cat.id),
                                              color: isSelected ? color : color.withValues(alpha: 0.8),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          cat.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            color: isSelected ? color : AppColors.textSecondary,
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
                            child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                          ),
                          error: (_, __) => const SizedBox(),
                        ),
                        const SizedBox(height: 20),
                        const Text('Frecuencia',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFrequencyChip('Sin repetir', null),
                            ..._recurrenceOptions.map((r) =>
                                _buildFrequencyChip(r['name']!, r['id'])),
                            _buildFrequencyChip('Personalizado', 'custom'),
                          ],
                        ),
                        if (_selectedRecurrence == 'custom') ...[
                          const SizedBox(height: 16),
                          _buildCustomRecurrenceMenu(),
                        ],
                        const SizedBox(height: 20),
                        const Text('Asignar a',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildAssigneeChip('Cualquiera', null, 'C'),
                            ..._members.map((m) {
                              final name = m['users']['full_name'] ??
                                  m['users']['email'] ??
                                  'Miembro';
                              final initial =
                                  name.toString().substring(0, 1).toUpperCase();
                              return _buildAssigneeChip(
                                  name, m['user_id'] as String, initial);
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            )),
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
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Crear tarea',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 16,
                                  )),
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

  Widget _buildFrequencyChip(String label, String? value) {
    final isSelected = _selectedRecurrence == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRecurrence = value;
        if (value == 'custom' &&
            _selectedWeekdays.isEmpty &&
            _selectedMonthDays.isEmpty) {
          // Defaults if none selected
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
              _buildCustomModeTab('Por día', 'weekdays'),
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
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
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
                      )
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
        const Text('Repetir cada',
            style: TextStyle(color: AppColors.textSecondary)),
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
                icon: const Icon(Icons.remove,
                    size: 20, color: AppColors.textSecondary),
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
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add,
                    size: 20, color: AppColors.textSecondary),
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
        const Text('días', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildMonthDaySelector() {
    return Column(
      children: [
        const Text('Elige los días del mes',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isSelected
                  ? AppColors.primary
                  : const Color(0xFFCBD5E1),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dificultad',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: _difficulties.map((d) {
            final isSelected = _selectedDifficulty == d['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDifficulty = d['id'] as String;
                    if (!_customRewards) {
                      _updateRewardControllers();
                    }
                  });
                },
                child: Container(
                  margin:
                      EdgeInsets.only(right: d != _difficulties.last ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        d['name'] as String,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d['xp']} XP / ${d['coins']} 💰',
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
              const Text('Recompensas',
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
                    prefixIcon: Icon(Icons.star_rounded,
                        color: AppColors.accent, size: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: TextStyle(
                    color: _customRewards
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
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
                    prefixIcon: Icon(Icons.monetization_on_rounded,
                        color: AppColors.success, size: 20),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: TextStyle(
                    color: _customRewards
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
