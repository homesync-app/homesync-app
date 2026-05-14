import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

enum TaskRepeatMode { none, daily, weekly, monthly, custom }

class ScheduleSelection {
  final TaskRepeatMode mode;
  final int recurrenceInterval;
  final List<int> recurrenceWeekdays;
  final List<int> recurrenceMonthDays;
  final String? assignedTo;

  const ScheduleSelection({
    required this.mode,
    this.recurrenceInterval = 1,
    this.recurrenceWeekdays = const [],
    this.recurrenceMonthDays = const [],
    this.assignedTo,
  });
}

class ScheduleDialog extends StatefulWidget {
  final String? currentRepeat;
  final List<int> currentWeekdays;
  final List<int> currentMonthDays;
  final int currentInterval;
  final String? currentAssignedTo;
  final List<Map<String, dynamic>> members;
  final Function(ScheduleSelection selection) onSave;

  const ScheduleDialog({
    super.key,
    this.currentRepeat,
    this.currentWeekdays = const [],
    this.currentMonthDays = const [],
    this.currentInterval = 1,
    this.currentAssignedTo,
    required this.members,
    required this.onSave,
  });

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  TaskRepeatMode _selectedMode = TaskRepeatMode.none;
  String _customRecurrenceMode = 'weekdays';
  final Set<int> _selectedDays = {};
  int _recurrenceInterval = 1;
  final Set<int> _selectedMonthDays = {};
  int? _selectedWeeklyDay;
  int? _selectedMonthlyDay;
  String? _selectedAssignedTo;

  final List<String> _dayNames = const ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _recurrenceInterval =
        widget.currentInterval > 0 ? widget.currentInterval : 1;
    _selectedAssignedTo = widget.currentAssignedTo;
    _selectedDays.addAll(widget.currentWeekdays);
    _selectedMonthDays.addAll(widget.currentMonthDays);
    _selectedWeeklyDay = widget.currentWeekdays.isNotEmpty
        ? widget.currentWeekdays.first
        : now.weekday;
    _selectedMonthlyDay = widget.currentMonthDays.isNotEmpty
        ? widget.currentMonthDays.first
        : now.day.clamp(1, 31);

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
      case 'custom':
        _selectedMode = TaskRepeatMode.custom;
        if (_selectedMonthDays.isNotEmpty) {
          _customRecurrenceMode = 'month_days';
        } else if (_recurrenceInterval > 1) {
          _customRecurrenceMode = 'interval';
        } else {
          _customRecurrenceMode = 'weekdays';
        }
        break;
      default:
        _selectedMode = TaskRepeatMode.none;
    }

    if (_selectedDays.isEmpty) {
      _selectedDays.add(now.weekday);
    }
    if (_selectedMonthDays.isEmpty) {
      _selectedMonthDays.add(now.day.clamp(1, 31));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 52,
              height: 6,
              decoration: BoxDecoration(
                color: theme.border.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    _buildSectionTitle('REPETICION'),
                    const SizedBox(height: 12),
                    _buildRepeatOptions(theme),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: _buildModeConfig(theme),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionTitle('RESPONSABLE'),
                    const SizedBox(height: 12),
                    _buildMemberSelector(theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 26),
              decoration: BoxDecoration(
                color: theme.background.withValues(alpha: 0.98),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: _buildFooter(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.schedule_rounded,
            color: theme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Programar tarea',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elegí cómo se repite y quién queda a cargo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Cerrar',
          onPressed: () => Navigator.pop(context),
          splashRadius: 22,
          icon: Icon(
            Icons.close_rounded,
            color: theme.textMuted.withValues(alpha: 0.82),
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.15,
      ),
    );
  }

  Widget _buildRepeatOptions(AppThemeColors theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildModeChip(
            theme, 'Ninguna', TaskRepeatMode.none, Icons.block_rounded,),
        _buildModeChip(
            theme, 'Diaria', TaskRepeatMode.daily, Icons.today_rounded,),
        _buildModeChip(
            theme, 'Semanal', TaskRepeatMode.weekly, Icons.date_range_rounded,),
        _buildModeChip(theme, 'Mensual', TaskRepeatMode.monthly,
            Icons.calendar_month_rounded,),
        _buildModeChip(
            theme, 'Personalizada', TaskRepeatMode.custom, Icons.tune_rounded,),
      ],
    );
  }

  Widget _buildModeChip(
    AppThemeColors theme,
    String label,
    TaskRepeatMode mode,
    IconData icon,
  ) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.11)
              : theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? theme.primary.withValues(alpha: 0.26)
                : theme.border.withValues(alpha: 0.9),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? theme.primary : theme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primary : theme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeConfig(AppThemeColors theme) {
    if (_selectedMode == TaskRepeatMode.none ||
        _selectedMode == TaskRepeatMode.daily) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surfaceVariant.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.border.withValues(alpha: 0.55)),
        ),
        child: switch (_selectedMode) {
          TaskRepeatMode.weekly => _buildWeeklyConfig(theme),
          TaskRepeatMode.monthly => _buildMonthlyConfig(theme),
          TaskRepeatMode.custom => _buildCustomRecurrenceMenu(theme),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildWeeklyConfig(AppThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elegí el día de la semana',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'La tarea se repetirá cada semana en ese día.',
          style: TextStyle(
            fontSize: 12.5,
            color: theme.textSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            final day = index + 1;
            final isSelected = _selectedWeeklyDay == day;
            return _buildDayPill(
              theme,
              label: _dayNames[index],
              selected: isSelected,
              onTap: () => setState(() => _selectedWeeklyDay = day),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthlyConfig(AppThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elegí el día del mes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'La tarea se repetirá todos los meses en esa fecha.',
          style: TextStyle(
            fontSize: 12.5,
            color: theme.textSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(31, (index) {
            final day = index + 1;
            final isSelected = _selectedMonthlyDay == day;
            return _buildNumberPill(
              theme,
              label: '$day',
              selected: isSelected,
              onTap: () => setState(() => _selectedMonthlyDay = day),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomRecurrenceMenu(AppThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCustomModeTab(theme, 'Días', 'weekdays'),
            _buildCustomModeTab(theme, 'Intervalo', 'interval'),
            _buildCustomModeTab(theme, 'Fecha', 'month_days'),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (_customRecurrenceMode) {
            'interval' => _buildIntervalSelector(theme),
            'month_days' => _buildMonthDaySelector(theme),
            _ => _buildDaySelector(theme),
          },
        ),
      ],
    );
  }

  Widget _buildCustomModeTab(AppThemeColors theme, String label, String mode) {
    final isSelected = _customRecurrenceMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _customRecurrenceMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.11)
              : theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.primary.withValues(alpha: 0.24)
                : theme.border.withValues(alpha: 0.78),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? theme.primary : theme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(AppThemeColors theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSelected = _selectedDays.contains(dayNum);
        return _buildDayPill(
          theme,
          label: _dayNames[index],
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(dayNum);
              } else {
                _selectedDays.add(dayNum);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildIntervalSelector(AppThemeColors theme) {
    return Container(
      key: const ValueKey('interval'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Cada',
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.border.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Disminuir',
                  onPressed: () {
                    if (_recurrenceInterval > 1) {
                      setState(() => _recurrenceInterval--);
                    }
                  },
                  icon: Icon(
                    Icons.remove_rounded,
                    size: 18,
                    color: theme.primary,
                  ),
                ),
                SizedBox(
                  width: 34,
                  child: Text(
                    _recurrenceInterval.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Aumentar',
                  onPressed: () {
                    if (_recurrenceInterval < 365) {
                      setState(() => _recurrenceInterval++);
                    }
                  },
                  icon: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: theme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _recurrenceInterval == 1 ? 'día' : 'días',
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDaySelector(AppThemeColors theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(31, (index) {
        final day = index + 1;
        final isSelected = _selectedMonthDays.contains(day);
        return _buildNumberPill(
          theme,
          label: '$day',
          selected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMonthDays.remove(day);
              } else {
                _selectedMonthDays.add(day);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildDayPill(
    AppThemeColors theme, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              selected ? theme.primary.withValues(alpha: 0.14) : theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? theme.primary.withValues(alpha: 0.26)
                : theme.border.withValues(alpha: 0.82),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? theme.primary : theme.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPill(
    AppThemeColors theme, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color:
              selected ? AppColors.sage.withValues(alpha: 0.15) : theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.sage.withValues(alpha: 0.3)
                : theme.border.withValues(alpha: 0.82),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.sage : theme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberSelector(AppThemeColors theme) {
    if (widget.members.isEmpty) return const SizedBox.shrink();

    final cards = <Widget>[
      _buildAssigneeCard(
        theme,
        label: 'Cualquiera',
        subtitle: 'Queda abierta para quien la quiera hacer.',
        selected: _selectedAssignedTo == null,
        onTap: () => setState(() => _selectedAssignedTo = null),
      ),
      ...widget.members.map((m) {
        final userId = m['user_id'] as String? ?? '';
        final users = m['users'] as Map<String, dynamic>? ?? const {};
        final name = (users['full_name'] as String?) ??
            (users['email'] as String?)?.split('@').first ??
            'Miembro';
        final avatarUrl = users['avatar_url'] as String?;
        return _buildAssigneeCard(
          theme,
          label: name.split(' ').first,
          subtitle: 'Responsable principal de esta tarea.',
          selected: _selectedAssignedTo == userId,
          avatarName: name,
          avatarUrl: avatarUrl,
          onTap: () => setState(() => _selectedAssignedTo = userId),
        );
      }),
    ];

    return Column(children: cards);
  }

  Widget _buildAssigneeCard(
    AppThemeColors theme, {
    required String label,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    String? avatarName,
    String? avatarUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color:
              selected ? theme.primary.withValues(alpha: 0.06) : theme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? theme.primary.withValues(alpha: 0.24)
                : theme.border.withValues(alpha: 0.82),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            avatarName == null
                ? Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: theme.primary,
                      size: 22,
                    ),
                  )
                : CustomUserAvatar(
                    name: avatarName,
                    avatarUrl: avatarUrl,
                    radius: 21,
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected
                    ? theme.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? theme.primary.withValues(alpha: 0.22)
                      : theme.border.withValues(alpha: 0.85),
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      color: theme.primary,
                      size: 18,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(AppThemeColors theme) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: theme.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.primary.withValues(alpha: 0.13),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    List<int> weekdays = const [];
    List<int> monthDays = const [];
    var interval = 1;

    switch (_selectedMode) {
      case TaskRepeatMode.none:
      case TaskRepeatMode.daily:
        break;
      case TaskRepeatMode.weekly:
        weekdays = [_selectedWeeklyDay ?? DateTime.now().weekday];
        break;
      case TaskRepeatMode.monthly:
        monthDays = [_selectedMonthlyDay ?? DateTime.now().day.clamp(1, 31)];
        break;
      case TaskRepeatMode.custom:
        if (_customRecurrenceMode == 'weekdays') {
          if (_selectedDays.isEmpty) {
            _showError(
                'Elegí al menos un día para la repetición personalizada.',);
            return;
          }
          weekdays = _selectedDays.toList()..sort();
        } else if (_customRecurrenceMode == 'interval') {
          interval = _recurrenceInterval;
        } else {
          if (_selectedMonthDays.isEmpty) {
            _showError('Elegí al menos una fecha para repetir la tarea.');
            return;
          }
          monthDays = _selectedMonthDays.toList()..sort();
        }
        break;
    }

    widget.onSave(
      ScheduleSelection(
        mode: _selectedMode,
        recurrenceInterval: interval,
        recurrenceWeekdays: weekdays,
        recurrenceMonthDays: monthDays,
        assignedTo: _selectedAssignedTo,
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentOrange,
      ),
    );
  }
}
