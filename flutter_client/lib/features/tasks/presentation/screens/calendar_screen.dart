import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/utils/app_animations.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _weekStart;
  final PageController _pageController = PageController(initialPage: 1000);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
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

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
  }

  void _onPageChanged(int index) {
    final weeksOffset = index - 1000;
    setState(() {
      // Find the Monday of the current selected standard offset
      final now = DateTime.now();
      final currentMonday = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      _weekStart = currentMonday.add(Duration(days: weeksOffset * 7));
      
      // Keep selected day in same weekday format, but just snap it back to current week
      // Wait, we can just optionally select the Monday of that new week, or keep current day.
      // Easiest is to select the new week's Monday if the selected date's week is different
      final selectedWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      if (!isSameDay(selectedWeekStart, _weekStart)) {
        _selectedDate = _weekStart; // select Monday
      }
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (tasks) {
          final scheduledTasks = _groupTasks(tasks);
          final eventsForSelectedDay = scheduledTasks[_selectedDate] ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: _buildWeekSelector(scheduledTasks),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: eventsForSelectedDay.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildTaskCard(eventsForSelectedDay[index]),
                            );
                          },
                          childCount: eventsForSelectedDay.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeekSelector(Map<DateTime, List<TaskModel>> scheduledTasks) {
    final monthFormat = DateFormat('MMMM yyyy', 'es');
    final monthYear = monthFormat.format(_weekStart);

    return Column(
      children: [
        // Header (Month and Arrows)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthYear[0].toUpperCase() + monthYear.substring(1),
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
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Page view for swiping weeks
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final weeksOffset = index - 1000;
              final now = DateTime.now();
              final currentMonday = DateTime(now.year, now.month, now.day)
                  .subtract(Duration(days: now.weekday - 1));
              final pageWeekStart = currentMonday.add(Duration(days: weeksOffset * 7));

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (dayIndex) {
                    final dayDate = pageWeekStart.add(Duration(days: dayIndex));
                    final isSelected = isSameDay(_selectedDate, dayDate);
                    final isToday = isSameDay(DateTime.now(), dayDate);
                    final hasTasks = (scheduledTasks[dayDate]?.isNotEmpty ?? false);

                    return _buildDayPill(dayDate, isSelected, isToday, hasTasks);
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 22),
      ),
    );
  }

  Widget _buildDayPill(DateTime date, bool isSelected, bool isToday, bool hasTasks) {
    final dayName = DateFormat('E', 'es').format(date)[0].toUpperCase();
    
    return GestureDetector(
      onTap: () => _onDaySelected(date),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        width: 46,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : (isToday ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
            width: isToday && !isSelected ? 2 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: hasTasks
                    ? (isSelected ? Colors.white : AppColors.accentGold)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.weekend_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Día libre!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No tienes actividades programadas para esta fecha. Un buen momento para relajarse.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
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
    final categoryIcon = categoryData?.icon ?? AppColors.categoryIcons[category] ?? '📋';

    return AnimatedPress(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isCompleted 
                ? AppColors.accentGreen.withOpacity(0.1)
                : const Color(0xFFF1F5F9), 
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(categoryIcon, style: const TextStyle(fontSize: 26)),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isCompleted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.12),
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen,
                  border: Border.all(
                    color: AppColors.accentGreen,
                    width: 2.5,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
