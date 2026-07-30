class CoupleMemberContribution {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int tasksDone;

  const CoupleMemberContribution({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.tasksDone,
  });

  factory CoupleMemberContribution.fromMap(Map<String, dynamic> map) {
    return CoupleMemberContribution(
      userId: map['user_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      avatarUrl: map['avatar_url']?.toString(),
      tasksDone: (map['tasks_done'] as num?)?.toInt() ?? 0,
    );
  }
}

class CoupleConnectionSummary {
  final String householdId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int tasksDone;
  final int tasksPlanned;
  final int needsAttention;
  final int specialMoments;
  final List<CoupleMemberContribution> memberDistribution;

  const CoupleConnectionSummary({
    required this.householdId,
    required this.weekStart,
    required this.weekEnd,
    required this.tasksDone,
    required this.tasksPlanned,
    required this.needsAttention,
    required this.specialMoments,
    required this.memberDistribution,
  });

  double get completionRate {
    if (tasksPlanned == 0) return 0;
    return (tasksDone / tasksPlanned).clamp(0.0, 1.0).toDouble();
  }

  int get tasksRemaining {
    final remaining = tasksPlanned - tasksDone;
    if (remaining < 0) return 0;
    if (remaining > tasksPlanned) return tasksPlanned;
    return remaining;
  }

  factory CoupleConnectionSummary.fromMap(Map<String, dynamic> map) {
    final rawDistribution = map['member_distribution'];
    return CoupleConnectionSummary(
      householdId: map['household_id']?.toString() ?? '',
      weekStart:
          DateTime.tryParse(map['week_start']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      weekEnd:
          DateTime.tryParse(map['week_end']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      tasksDone: (map['tasks_done'] as num?)?.toInt() ?? 0,
      tasksPlanned: (map['tasks_planned'] as num?)?.toInt() ?? 0,
      needsAttention: (map['needs_attention'] as num?)?.toInt() ?? 0,
      specialMoments: (map['special_moments'] as num?)?.toInt() ?? 0,
      memberDistribution: rawDistribution is List
          ? rawDistribution
              .whereType<Map>()
              .map(
                (item) => CoupleMemberContribution.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const [],
    );
  }
}
