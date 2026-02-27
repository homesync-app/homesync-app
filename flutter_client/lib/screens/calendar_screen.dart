import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import '../theme/app_colors.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Map<DateTime, List<Task>> _groupTasks(List<Task> tasks) {
    final Map<DateTime, List<Task>> groupedTasks = {};

    for (var task in tasks) {
      if (task.recurrenceType != null || task.dueAt != null) {
        if (task.dueAt != null) {
          final date = task.dueAt!.toLocal();
          final normalizedDate = DateTime(date.year, date.month, date.day);
          if (groupedTasks[normalizedDate] == null) {
            groupedTasks[normalizedDate] = [];
          }
          groupedTasks[normalizedDate]!.add(task);
        } else if (task.recurrenceType == 'daily') {
          for (int i = 0; i < 30; i++) {
            final d = DateTime.now().add(Duration(days: i));
            final normalizedDate = DateTime(d.year, d.month, d.day);
            if (groupedTasks[normalizedDate] == null) {
              groupedTasks[normalizedDate] = [];
            }
            groupedTasks[normalizedDate]!.add(task);
          }
        } else if (task.recurrenceType == 'weekly') {
          for (int i = 0; i < 4; i++) {
            final d = DateTime.now().add(Duration(days: i * 7));
            final normalizedDate = DateTime(d.year, d.month, d.day);
            if (groupedTasks[normalizedDate] == null) {
              groupedTasks[normalizedDate] = [];
            }
            groupedTasks[normalizedDate]!.add(task);
          }
        }
      }
    }
    return groupedTasks;
  }

  List<Task> _getEventsForDay(
      DateTime day, Map<DateTime, List<Task>> scheduledTasks) {
    final normalizedDate = DateTime(day.year, day.month, day.day);
    return scheduledTasks[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Container(
      color: AppColors.background,
      child: tasksAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) =>
            Center(child: Text('Error: $err', style: TextStyle(color: AppColors.error))),
        data: (tasks) {
          final scheduledTasks = _groupTasks(tasks);
          final eventsForSelectedDay =
              _getEventsForDay(_selectedDay ?? _focusedDay, scheduledTasks);

          return Column(
            children: [
              TableCalendar<Task>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                eventLoader: (day) => _getEventsForDay(day, scheduledTasks),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.accentGold,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: eventsForSelectedDay.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay tareas programadas para este día.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: eventsForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final task = eventsForSelectedDay[index];
                          final xp = task.xpReward;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.event_note,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Recompensa: $xp XP',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
