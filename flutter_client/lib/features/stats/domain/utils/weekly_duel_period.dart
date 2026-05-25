DateTime weeklyDuelTargetWeekStart([DateTime? now]) {
  final value = now ?? DateTime.now();
  final today = DateTime(value.year, value.month, value.day);
  final currentMonday = today.subtract(Duration(days: today.weekday - 1));

  if (value.weekday == DateTime.monday && value.hour < 12) {
    return currentMonday.subtract(const Duration(days: 7));
  }

  return currentMonday;
}

String weeklyDuelWeekKey(DateTime weekStart) {
  return '${weekStart.year}_${weekStart.month}_${weekStart.day}';
}
