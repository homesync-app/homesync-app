import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

enum TaskRepeatMode { none, daily, weekly, monthly, custom }

class ScheduleDialog extends StatefulWidget {
  final String? currentRepeat;
  final List<Map<String, dynamic>> members;
  final Function(TaskRepeatMode mode, List<int>? customDays,
      List<String>? assignedMembers) onSave;

  const ScheduleDialog({
    super.key,
    this.currentRepeat,
    required this.members,
    required this.onSave,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  TaskRepeatMode _selectedMode = TaskRepeatMode.none;
  final Set<String> _selectedMembers = {};

  // Custom Recurrence State
  String _customRecurrenceMode = 'weekdays';
  final Set<int> _selectedDays = {};
  int _recurrenceInterval = 1;
  final Set<int> _selectedMonthDays = {};

  final List<String> _dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    if (widget.currentRepeat != null) {
      switch (widget.currentRepeat) {
        case 'daily':
          _selectedMode = TaskRepeatMode.daily;
          break;
        case 'weekly':
          _selectedMode = TaskRepeatMode.weekly;
          break;
        case 'monthly':
          _selectedMode = TaskRepeatMode.monthly;
          break;
      }
    }
    for (var m in widget.members) {
      _selectedMembers.add(m['user_id'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    child: const Icon(Icons.schedule_rounded,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Programar tarea',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Repetir',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildRepeatOptions(),
              if (_selectedMode == TaskRepeatMode.custom) ...[
                const SizedBox(height: 20),
                _buildCustomRecurrenceMenu(),
              ],
              const SizedBox(height: 24),
              const Text(
                'Asignar a',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildMemberSelector(),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatOptions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildModeChip('Sin repetir', TaskRepeatMode.none),
        _buildModeChip('Diario', TaskRepeatMode.daily),
        _buildModeChip('Semanal', TaskRepeatMode.weekly),
        _buildModeChip('Mensual', TaskRepeatMode.monthly),
        _buildModeChip('Personalizado', TaskRepeatMode.custom),
      ],
    );
  }

  Widget _buildModeChip(String label, TaskRepeatMode mode) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
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
          if (_customRecurrenceMode == 'weekdays') _buildDaySelector(),
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

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = _selectedDays.contains(dayNum);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(dayNum);
              } else {
                _selectedDays.add(dayNum);
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
            child: Center(
              child: Text(
                _dayNames[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
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

  Widget _buildMemberSelector() {
    if (widget.members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No hay otros miembros en el equipo',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: widget.members.map((m) {
        final userId = m['user_id'] ?? '';
        final name =
            m['users']?['full_name'] ?? m['users']?['email'] ?? 'Miembro';
        final isSelected = _selectedMembers.contains(userId);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMembers.remove(userId);
              } else {
                _selectedMembers.add(userId);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      isSelected ? AppColors.primary : AppColors.textMuted,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleSave() {
    final customDays =
        _selectedMode == TaskRepeatMode.custom ? _selectedDays.toList() : null;
    final assignedMembers = _selectedMembers.toList();

    widget.onSave(_selectedMode, customDays, assignedMembers);
    Navigator.pop(context);
  }
}
