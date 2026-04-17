import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  final Function(TaskModel) onEdit;
  final Function(TaskModel) onSchedule;

  const CalendarScreen({
    super.key,
    required this.onEdit,
    required this.onSchedule,
  });

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<DateTime, List<TaskModel>> _groupTasks(List<TaskModel> tasks) {
    final Map<DateTime, List<TaskModel>> groupedTasks = {};
    for (var task in tasks) {
      if (task.recurrenceType != null || task.dueAt != null) {
        if (task.dueAt != null) {
          final date = task.dueAt!.toLocal();
          final normalizedDate = DateTime(date.year, date.month, date.day);
          (groupedTasks[normalizedDate] ??= []).add(task);
        } else if (task.recurrenceType == 'daily') {
          for (int i = 0; i < 30; i++) {
            final d = DateTime.now().add(Duration(days: i));
            final normalizedDate = DateTime(d.year, d.month, d.day);
            (groupedTasks[normalizedDate] ??= []).add(task);
          }
        } else if (task.recurrenceType == 'weekly') {
          for (int i = 0; i < 4; i++) {
            final d = DateTime.now().add(Duration(days: i * 7));
            final normalizedDate = DateTime(d.year, d.month, d.day);
            (groupedTasks[normalizedDate] ??= []).add(task);
          }
        }
      }
    }
    return groupedTasks;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackground,
      body: tasksAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),),
        error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: AppColors.error),),),
        data: (tasks) {
          final scheduledTasks = _groupTasks(tasks);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tasksProvider);
            },
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: Column(
              children: [
                _buildWeekHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24)
                        .copyWith(bottom: 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final dayDate = _weekStart.add(Duration(days: index));
                      final isToday = isSameDay(DateTime.now(), dayDate);
                      final tasksForDay = scheduledTasks[dayDate] ?? [];

                      return _buildDaySection(dayDate, tasksForDay, isToday)
                          .animateEntrance(delay: index * 50);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekHeader() {
    final theme = context.theme;
    final monthFormat = DateFormat('MMMM yyyy', 'es');
    final startMonth = monthFormat.format(_weekStart);
    final monthYear = startMonth[0].toUpperCase() + startMonth.substring(1);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase.withValues(
              alpha: theme.isDarkMode ? 0.22 : 0.03,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semana de',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: theme.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthYear,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _previousWeek,
                  ),
                  const SizedBox(width: 12),
                  _buildArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextWeek,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton(
      {required IconData icon, required VoidCallback onTap,}) {
    final theme = context.theme;
    return AnimatedPress(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.elevatedSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.border.withValues(alpha: theme.isDarkMode ? 0.9 : 0.5),
          ),
        ),
        child: Icon(icon, color: theme.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildDaySection(DateTime date, List<TaskModel> tasks, bool isToday) {
    final theme = context.theme;
    final dayNameFull = DateFormat('EEEE', 'es').format(date);
    final dayName = dayNameFull[0].toUpperCase() + dayNameFull.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 16),
          child: Row(
            children: [
              Text(
                isToday ? 'Hoy, $dayName' : dayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isToday ? AppColors.primary : theme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.divider.withValues(alpha: 0.9),
                        theme.divider.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withValues(
                alpha: theme.isDarkMode ? 0.72 : 0.5,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.border
                    .withValues(alpha: theme.isDarkMode ? 0.75 : 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.textMuted.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    color: theme.textMuted,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Sin tareas programadas',
                  style: TextStyle(
                    color: theme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ...tasks.map((task) => _CalendarTaskCard(
                task: task,
                onEdit: () => widget.onEdit(task),
                onSchedule: () => widget.onSchedule(task),
              ),),
      ],
    );
  }
}

class _CalendarTaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onSchedule;

  const _CalendarTaskCard({
    required this.task,
    required this.onEdit,
    required this.onSchedule,
  });

  @override
  ConsumerState<_CalendarTaskCard> createState() => _CalendarTaskCardState();
}

class _CalendarTaskCardState extends ConsumerState<_CalendarTaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = context.theme;
    final isCompleted = task.isVerified;
    final xp = task.xpReward;
    final category = task.category ?? 'general';
    final normalizedCategory = CategoryMapping.normaliseCategory(category);

    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        final normalizedTaskCategory =
            CategoryMapping.normaliseCategory(category);
        for (final categoryOption in list) {
          if (CategoryMapping.normaliseCategory(categoryOption.id) ==
              normalizedTaskCategory) {
            return categoryOption;
          }
        }
        return null;
      },
      orElse: () => null,
    );

    final categoryColor = categoryData != null
        ? AppColors.fromHex(categoryData.color)
        : CategoryMapping.getCategoryColor(category);
    final categoryIcon =
        CategoryMapping.getCategoryMaterialIcon(normalizedCategory);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isExpanded
              ? categoryColor.withValues(alpha: 0.3)
              : (isCompleted
                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                  : theme.border
                      .withValues(alpha: theme.isDarkMode ? 0.85 : 0.5)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase.withValues(
              alpha: _isExpanded
                  ? (theme.isDarkMode ? 0.3 : 0.06)
                  : (theme.isDarkMode ? 0.2 : 0.02),
            ),
            blurRadius: _isExpanded ? 15 : 10,
            offset: Offset(0, _isExpanded ? 6 : 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(
                        categoryIcon,
                        size: 22,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isCompleted
                                ? theme.textMuted
                                : theme.textPrimary,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '+$xp XP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentGold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (task.recurrenceType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2,),
                                decoration: BoxDecoration(
                                  color: AppColors.accentTeal
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.recurrenceType!.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.accentTeal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted && !_isExpanded)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.accentGreen, size: 24,),
                ],
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  heightFactor: _isExpanded ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Divider(
                          height: 1,
                          color: theme.divider.withValues(
                            alpha: theme.isDarkMode ? 0.35 : 0.9,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionTile(
                                icon: Icons.edit_rounded,
                                label: 'Editar',
                                color: AppColors.primary,
                                onTap: widget.onEdit,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionTile(
                                icon: Icons.schedule_rounded,
                                label: 'Programar',
                                color: AppColors.accentGold,
                                onTap: widget.onSchedule,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedPress(
      onTap: () {
        setState(() => _isExpanded = false);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
