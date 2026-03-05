import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: tasksAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: AppColors.error))),
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
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: _buildWeekHeader(),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24)
                        .copyWith(bottom: 100),
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final dayDate = _weekStart.add(Duration(days: index));
                      final isToday = isSameDay(DateTime.now(), dayDate);
                      final tasksForDay = scheduledTasks[dayDate] ?? [];

                      return _buildDaySection(dayDate, tasksForDay, isToday);
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
    final monthFormat = DateFormat('MMMM yyyy', 'es');
    final startMonth = monthFormat.format(_weekStart);
    final monthYear = startMonth[0].toUpperCase() + startMonth.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            monthYear,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              _buildArrowButton(
                icon: Icons.chevron_left_rounded,
                onTap: _previousWeek,
              ),
              const SizedBox(width: 8),
              _buildArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: _nextWeek,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildArrowButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 22),
      ),
    );
  }

  Widget _buildDaySection(DateTime date, List<TaskModel> tasks, bool isToday) {
    final dayNameFull = DateFormat('EEEE', 'es').format(date);
    final dayName = dayNameFull[0].toUpperCase() + dayNameFull.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isToday
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]),
                child: Text(
                  '$dayName ${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isToday ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE2E8F0),
                      const Color(0xFFE2E8F0).withValues(alpha: 0),
                    ],
                  )),
                ),
              )
            ],
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.nightlight_round,
                      color: Color(0xFF94A3B8), size: 14),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Día libre',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ...tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isCompleted = task.isVerified;
    final xp = task.xpReward;
    final category = task.category ?? 'general';

    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        try {
          return list.firstWhere((c) => c.id == category);
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );

    final categoryColor = categoryData != null
        ? AppColors.fromHex(categoryData.color)
        : AppColors.getCategoryColor(category);
    final categoryIcon =
        categoryData?.icon ?? AppColors.categoryIcons[category] ?? '📋';

    return AnimatedPress(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted
                ? AppColors.accentGreen.withValues(alpha: 0.1)
                : const Color(0xFFF1F5F9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(categoryIcon, style: const TextStyle(fontSize: 24)),
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
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+$xp XP',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentGold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accentGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'COMPLETADA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Container(
                margin: const EdgeInsets.only(left: 12),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen,
                  border: Border.all(
                    color: AppColors.accentGreen,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child:
                      Icon(Icons.check_rounded, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
