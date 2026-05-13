/// Sprint 4 Modo Padres: resumen semanal del hogar.
class WeeklyFamilySummary {
  final String householdId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final DateTime generatedAt;
  final int tasksDone;
  final int tasksPlanned;
  final double completionRate;
  final int tasksDoneLastWeek;
  final int tasksDoneDelta;
  final SummaryMember? mvp;
  final SummaryMember? slacker;
  final ForgottenTask? forgottenTask;
  final num spendingTotal;
  final num spendingLastWeek;
  final num spendingDelta;
  final TopCategorySpend? topCategory;

  const WeeklyFamilySummary({
    required this.householdId,
    required this.weekStart,
    required this.weekEnd,
    required this.generatedAt,
    required this.tasksDone,
    required this.tasksPlanned,
    required this.completionRate,
    required this.tasksDoneLastWeek,
    required this.tasksDoneDelta,
    required this.mvp,
    required this.slacker,
    required this.forgottenTask,
    required this.spendingTotal,
    required this.spendingLastWeek,
    required this.spendingDelta,
    required this.topCategory,
  });

  factory WeeklyFamilySummary.fromMap(Map<String, dynamic> map) {
    return WeeklyFamilySummary(
      householdId: map['household_id'] as String,
      weekStart: DateTime.parse(map['week_start'] as String),
      weekEnd: DateTime.parse(map['week_end'] as String),
      generatedAt: DateTime.parse(map['generated_at'] as String),
      tasksDone: (map['tasks_done'] as num?)?.toInt() ?? 0,
      tasksPlanned: (map['tasks_planned'] as num?)?.toInt() ?? 0,
      completionRate: (map['completion_rate'] as num?)?.toDouble() ?? 0,
      tasksDoneLastWeek: (map['tasks_done_last_week'] as num?)?.toInt() ?? 0,
      tasksDoneDelta: (map['tasks_done_delta'] as num?)?.toInt() ?? 0,
      mvp: map['mvp'] is Map
          ? SummaryMember.fromMap(
              Map<String, dynamic>.from(map['mvp'] as Map),
            )
          : null,
      slacker: map['slacker'] is Map
          ? SummaryMember.fromMap(
              Map<String, dynamic>.from(map['slacker'] as Map),
            )
          : null,
      forgottenTask: map['forgotten_task'] is Map
          ? ForgottenTask.fromMap(
              Map<String, dynamic>.from(map['forgotten_task'] as Map),
            )
          : null,
      spendingTotal: (map['spending_total'] as num?) ?? 0,
      spendingLastWeek: (map['spending_last_week'] as num?) ?? 0,
      spendingDelta: (map['spending_delta'] as num?) ?? 0,
      topCategory: map['top_category'] is Map
          ? TopCategorySpend.fromMap(
              Map<String, dynamic>.from(map['top_category'] as Map),
            )
          : null,
    );
  }
}

class SummaryMember {
  final String userId;
  final String fullName;
  final String? avatarUrl;

  /// Para `mvp` esto trae `tasks_done`. Para `slacker` trae `overdue_count`.
  /// Lo guardamos generico para no duplicar el modelo.
  final int count;

  const SummaryMember({
    required this.userId,
    required this.fullName,
    required this.avatarUrl,
    required this.count,
  });

  factory SummaryMember.fromMap(Map<String, dynamic> map) {
    return SummaryMember(
      userId: map['user_id'] as String,
      fullName: (map['full_name'] as String?) ?? 'Miembro',
      avatarUrl: map['avatar_url'] as String?,
      count: (map['tasks_done'] as num?)?.toInt() ??
          (map['overdue_count'] as num?)?.toInt() ??
          0,
    );
  }
}

class ForgottenTask {
  final String id;
  final String title;
  final String? category;
  final DateTime dueAt;
  final int overdueSeconds;

  const ForgottenTask({
    required this.id,
    required this.title,
    required this.category,
    required this.dueAt,
    required this.overdueSeconds,
  });

  Duration get overdue => Duration(seconds: overdueSeconds);

  factory ForgottenTask.fromMap(Map<String, dynamic> map) {
    return ForgottenTask(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? 'Tarea',
      category: map['category'] as String?,
      dueAt: DateTime.parse(map['due_at'] as String),
      overdueSeconds: (map['overdue_seconds'] as num?)?.toInt() ?? 0,
    );
  }
}

class TopCategorySpend {
  final String category;
  final num total;
  final int count;

  const TopCategorySpend({
    required this.category,
    required this.total,
    required this.count,
  });

  factory TopCategorySpend.fromMap(Map<String, dynamic> map) {
    return TopCategorySpend(
      category: (map['category'] as String?) ?? 'sin_categoria',
      total: (map['total'] as num?) ?? 0,
      count: (map['count'] as num?)?.toInt() ?? 0,
    );
  }
}
