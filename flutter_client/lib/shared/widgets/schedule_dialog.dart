import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

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
    final theme = context.theme;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(32),
          boxShadow: theme.modalShadow,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Programar Tarea',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Configura la repetición y responsables',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('REPETIR ESCALA'),
                    const SizedBox(height: 12),
                    _buildRepeatOptions(),
                    
                    if (_selectedMode == TaskRepeatMode.custom) ...[
                      const SizedBox(height: 24),
                      _buildCustomRecurrenceMenu(),
                    ],

                    const SizedBox(height: 32),
                    _buildSectionTitle('ASIGNAR RESPONSABLES'),
                    const SizedBox(height: 12),
                    _buildMemberSelector(),

                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 8,
                              shadowColor: AppColors.primary.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              'Confirmar',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildRepeatOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildModeChip('Ninguna', TaskRepeatMode.none, Icons.block_rounded),
        _buildModeChip('Diario', TaskRepeatMode.daily, Icons.today_rounded),
        _buildModeChip('Semanal', TaskRepeatMode.weekly, Icons.date_range_rounded),
        _buildModeChip('Mensual', TaskRepeatMode.monthly, Icons.calendar_today_rounded),
        _buildModeChip('Personalizado', TaskRepeatMode.custom, Icons.settings_rounded),
      ],
    );
  }

  Widget _buildModeChip(String label, TaskRepeatMode mode, IconData icon) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRecurrenceMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCustomModeTab('Días', 'weekdays'),
              _buildCustomModeTab('Intervalo', 'interval'),
              _buildCustomModeTab('Fecha', 'month_days'),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _customRecurrenceMode == 'weekdays' 
                ? _buildDaySelector()
                : _customRecurrenceMode == 'interval'
                    ? _buildIntervalSelector()
                    : _buildMonthDaySelector(),
          ),
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
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: 20,
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
      spacing: 10,
      runSpacing: 10,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                _dayNames[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Cada', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_recurrenceInterval > 1) setState(() => _recurrenceInterval--);
                  },
                  icon: const Icon(Icons.remove_rounded, size: 20, color: AppColors.primary),
                ),
                SizedBox(
                  width: 30,
                  child: Text(
                    _recurrenceInterval.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_recurrenceInterval < 365) setState(() => _recurrenceInterval++);
                  },
                  icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('días', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMonthDaySelector() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: List.generate(31, (index) {
        final day = index + 1;
        final isSelected = _selectedMonthDays.contains(day);
        return GestureDetector(
          onTap: () => setState(() => isSelected ? _selectedMonthDays.remove(day) : _selectedMonthDays.add(day)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentGreen : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppColors.accentGreen : const Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMemberSelector() {
    if (widget.members.isEmpty) return const SizedBox.shrink();

    return Column(
      children: widget.members.map((m) {
        final userId = m['user_id'] ?? '';
        final name = (m['users']?['full_name'] as String?)?.split(' ').first ?? 'Miembro';
        final isSelected = _selectedMembers.contains(userId);

        return GestureDetector(
          onTap: () => setState(() => isSelected ? _selectedMembers.remove(userId) : _selectedMembers.add(userId)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isSelected 
                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (val) => setState(() => val! ? _selectedMembers.add(userId) : _selectedMembers.remove(userId)),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleSave() {
    final customDays = _selectedMode == TaskRepeatMode.custom ? _selectedDays.toList() : null;
    final assignedMembers = _selectedMembers.toList();
    widget.onSave(_selectedMode, customDays, assignedMembers);
    Navigator.pop(context);
  }
}
