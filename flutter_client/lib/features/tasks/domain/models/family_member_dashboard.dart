/// Sprint 2 Modo Padres: snapshot por miembro de la familia para el
/// dashboard parental. Lo entrega `get_family_member_dashboard`.
class FamilyMemberSnapshot {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String memberType;
  final String? displayRole;
  final int tasksDone;
  final int tasksOpen;
  final int tasksOverdue;
  final int tasksPendingApproval;
  final int xpEarned;
  final int coinsEarned;
  final int coinsSpent;
  final int streakDays;
  final List<TopCategoryEntry> topCategories;

  const FamilyMemberSnapshot({
    required this.userId,
    required this.fullName,
    required this.avatarUrl,
    required this.memberType,
    required this.displayRole,
    required this.tasksDone,
    required this.tasksOpen,
    required this.tasksOverdue,
    required this.tasksPendingApproval,
    required this.xpEarned,
    required this.coinsEarned,
    required this.coinsSpent,
    required this.streakDays,
    required this.topCategories,
  });

  /// Total de tareas planificadas que el miembro tenia (donedone + abiertas).
  /// Lo usamos para calcular la tasa de cumplimiento sin tener que sumar
  /// columnas en la UI.
  int get plannedTotal => tasksDone + tasksOpen;

  /// 0..1; si no habia nada planificado devolvemos 1 (perfecto: nada que
  /// hacer, nada que reprochar).
  double get completionRate {
    final total = plannedTotal;
    if (total == 0) return 1;
    return tasksDone / total;
  }

  bool get isAdult => memberType == 'adult' || memberType == 'parent' ||
      memberType == 'guardian';
  bool get isChild => memberType == 'child';
  bool get isTeen => memberType == 'teen';

  factory FamilyMemberSnapshot.fromMap(Map<String, dynamic> map) {
    final cats = map['top_categories'];
    return FamilyMemberSnapshot(
      userId: map['user_id'] as String,
      fullName: (map['full_name'] as String?) ?? 'Miembro',
      avatarUrl: map['avatar_url'] as String?,
      memberType: (map['member_type'] as String?) ?? 'adult',
      displayRole: map['display_role'] as String?,
      tasksDone: _i(map['tasks_done']),
      tasksOpen: _i(map['tasks_open']),
      tasksOverdue: _i(map['tasks_overdue']),
      tasksPendingApproval: _i(map['tasks_pending_approval']),
      xpEarned: _i(map['xp_earned']),
      coinsEarned: _i(map['coins_earned']),
      coinsSpent: _i(map['coins_spent']),
      streakDays: _i(map['streak_days']),
      topCategories: cats is List
          ? cats
              .whereType<Map>()
              .map(
                (c) => TopCategoryEntry.fromMap(
                  Map<String, dynamic>.from(c),
                ),
              )
              .toList()
          : const [],
    );
  }

  static int _i(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class TopCategoryEntry {
  final String category;
  final int xp;
  final int count;

  const TopCategoryEntry({
    required this.category,
    required this.xp,
    required this.count,
  });

  factory TopCategoryEntry.fromMap(Map<String, dynamic> map) {
    return TopCategoryEntry(
      category: (map['category'] as String?) ?? 'sin_categoria',
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      count: (map['count'] as num?)?.toInt() ?? 0,
    );
  }
}

enum DashboardPeriod { week, month }

extension DashboardPeriodX on DashboardPeriod {
  String get rpcValue => this == DashboardPeriod.week ? 'week' : 'month';
  String get label => this == DashboardPeriod.week ? 'Esta semana' : 'Este mes';
}

class FamilyMemberDashboard {
  final DashboardPeriod period;
  final DateTime periodStart;
  final DateTime generatedAt;
  final List<FamilyMemberSnapshot> members;

  const FamilyMemberDashboard({
    required this.period,
    required this.periodStart,
    required this.generatedAt,
    required this.members,
  });

  factory FamilyMemberDashboard.fromMap(Map<String, dynamic> map) {
    final periodStr = (map['period'] as String?) ?? 'week';
    final period = periodStr == 'month'
        ? DashboardPeriod.month
        : DashboardPeriod.week;
    final raw = map['members'];
    return FamilyMemberDashboard(
      period: period,
      periodStart: DateTime.parse(map['period_start'] as String),
      generatedAt: DateTime.parse(map['generated_at'] as String),
      members: raw is List
          ? raw
              .whereType<Map>()
              .map(
                (m) => FamilyMemberSnapshot.fromMap(
                  Map<String, dynamic>.from(m),
                ),
              )
              .toList()
          : const [],
    );
  }
}
