enum TaskStatus {
  active,
  assigned,
  pendingApproval,
  pendingVerification,
  verified,
  objected;

  static TaskStatus fromString(String? value) {
    if (value == 'pending_approval') return TaskStatus.pendingApproval;
    if (value == 'pending_verification') return TaskStatus.pendingVerification;
    return TaskStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.active,
    );
  }

  String get dbValue {
    switch (this) {
      case TaskStatus.pendingApproval:
        return 'pending_approval';
      case TaskStatus.pendingVerification:
        return 'pending_verification';
      default:
        return name;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  static TaskPriority fromString(String? value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

enum TaskType {
  oneTime,
  recurring;

  static TaskType fromString(String? value) {
    if (value == 'one_time') return TaskType.oneTime;
    return TaskType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskType.oneTime,
    );
  }

  String get dbValue => this == TaskType.oneTime ? 'one_time' : 'recurring';
}

enum TaskDifficulty {
  easy,
  medium,
  hard;

  static TaskDifficulty fromString(String? value) {
    return TaskDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskDifficulty.medium,
    );
  }
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String? assignedTo;
  final TaskStatus status;
  final int xpReward;
  final int coinReward;
  final String? recurrenceType;
  final int recurrenceInterval;
  final List<int> recurrenceWeekdays;
  final List<int> recurrenceMonthDays;
  final DateTime? dueAt;
  final DateTime? recurrenceEndAt;
  final String householdId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? completedBy;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? lastCompletedAt;
  final String? lastVerifiedBy;
  final TaskPriority priority;
  final TaskType type;
  final TaskDifficulty difficulty;
  final String? createdById;
  final String? sourceTemplateId;
  final String? titleKey;

  /// Sprint 3 Modo Padres: lista de user_id que se turnan. Vacio = sin
  /// rotacion. `assigned_to` siempre es "a quien le toca ahora", sirve para
  /// mostrar la UI tal cual lo hacia antes; al completar el server avanza.
  final List<String> rotationPool;
  final String rotationStrategy;
  final int rotationIndex;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.assignedTo,
    required this.status,
    required this.xpReward,
    required this.coinReward,
    this.recurrenceType,
    this.recurrenceInterval = 1,
    this.recurrenceWeekdays = const [],
    this.recurrenceMonthDays = const [],
    this.dueAt,
    this.recurrenceEndAt,
    required this.householdId,
    required this.createdAt,
    this.completedAt,
    this.completedBy,
    this.verifiedBy,
    this.verifiedAt,
    this.lastCompletedAt,
    this.lastVerifiedBy,
    this.priority = TaskPriority.medium,
    this.type = TaskType.oneTime,
    this.difficulty = TaskDifficulty.medium,
    this.createdById,
    this.sourceTemplateId,
    this.titleKey,
    this.rotationPool = const [],
    this.rotationStrategy = 'round_robin',
    this.rotationIndex = 0,
  });

  /// Sprint 3: true cuando la tarea tiene un pool de rotacion configurado.
  bool get hasRotation => rotationPool.isNotEmpty;

  /// Sprint 1 Modo Padres: stub para invocar RPCs que solo necesitan el id
  /// (verify_task_transaction / reject_task_transaction). Evita tener que
  /// pasar un TaskModel completo cuando solo conocemos el id desde la lista
  /// de aprobaciones pendientes.
  factory TaskModel.minimalForApproval({required String id}) {
    return TaskModel(
      id: id,
      title: '',
      status: TaskStatus.pendingApproval,
      xpReward: 0,
      coinReward: 0,
      householdId: '',
      createdAt: DateTime.now(),
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Sin título',
      description: map['description'] as String?,
      category: map['category'] as String?,
      assignedTo: map['assigned_to'] as String?,
      status: TaskStatus.fromString(map['status'] as String?),
      xpReward: _toInt(map['xp_reward']),
      coinReward: _toInt(map['coin_reward']),
      recurrenceType: map['recurrence_type'] as String?,
      recurrenceInterval: _toInt(map['recurrence_interval'], defaultValue: 1),
      recurrenceWeekdays:
          (map['recurrence_weekdays'] as List?)?.cast<int>() ?? const [],
      recurrenceMonthDays:
          (map['recurrence_month_days'] as List?)?.cast<int>() ?? const [],
      dueAt: _parseDate(map['due_at']),
      recurrenceEndAt: _parseDate(map['recurrence_end_at']),
      householdId: map['household_id'] as String? ?? '',
      createdAt: _parseDate(map['created_at']) ?? DateTime.now(),
      completedAt: _parseDate(map['completed_at'] ?? map['last_completed_at']),
      completedBy: map['completed_by'] as String?,
      verifiedBy:
          map['verified_by'] as String? ?? map['last_verified_by'] as String?,
      verifiedAt: _parseDate(map['verified_at']),
      lastCompletedAt: map['last_completed_at'] as String?,
      lastVerifiedBy: map['last_verified_by'] as String?,
      priority: TaskPriority.fromString(map['priority'] as String?),
      type: TaskType.fromString(map['type'] as String?),
      difficulty: TaskDifficulty.fromString(map['difficulty'] as String?),
      createdById: map['created_by_id'] as String?,
      sourceTemplateId: map['source_template_id'] as String?,
      titleKey: map['title_key'] as String?,
      rotationPool:
          (map['rotation_pool'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      rotationStrategy: (map['rotation_strategy'] as String?) ?? 'round_robin',
      rotationIndex: _toInt(map['rotation_index']),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'assigned_to': assignedTo,
        'status': status.dbValue,
        'xp_reward': xpReward,
        'coin_reward': coinReward,
        'recurrence_type': recurrenceType,
        'recurrence_interval': recurrenceInterval,
        'recurrence_weekdays': recurrenceWeekdays,
        'recurrence_month_days': recurrenceMonthDays,
        'due_at': dueAt?.toIso8601String(),
        'recurrence_end_at': recurrenceEndAt?.toIso8601String(),
        'household_id': householdId,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'completed_by': completedBy,
        'verified_by': verifiedBy,
        'verified_at': verifiedAt?.toIso8601String(),
        'last_completed_at': lastCompletedAt,
        'last_verified_by': lastVerifiedBy,
        'priority': priority.name,
        'type': type.dbValue,
        'difficulty': difficulty.name,
        'created_by_id': createdById,
        'source_template_id': sourceTemplateId,
        'title_key': titleKey,
        'rotation_pool': rotationPool,
        'rotation_strategy': rotationStrategy,
        'rotation_index': rotationIndex,
      };

  // ── Computed helpers ───────────────────────────────────────────────────────

  bool get isActive =>
      status == TaskStatus.active ||
      status == TaskStatus.assigned ||
      status == TaskStatus.pendingApproval ||
      status == TaskStatus.objected;
  bool get isPendingApproval => status == TaskStatus.pendingApproval;
  bool get isPendingVerification => status == TaskStatus.pendingVerification;
  bool get isCompleted =>
      isPendingVerification || status == TaskStatus.verified;
  bool get isVerified => status == TaskStatus.verified;
  bool get isObjected => status == TaskStatus.objected;
  bool get isPending => isActive;
  bool get isRecurring => recurrenceType != null;
  bool get isOverdue {
    if (dueAt == null || !isActive) return false;
    final now = DateTime.now();
    // Only tasks due BEFORE today count as overdue.
    // Tasks due today (even if past midnight) are handled by isDueToday to
    // avoid appearing in both the "today" and "overdue" lists simultaneously.
    final startOfToday = DateTime(now.year, now.month, now.day);
    return dueAt!.isBefore(startOfToday);
  }

  bool get isDueToday {
    if (dueAt == null) return false;
    final now = DateTime.now();
    return dueAt!.year == now.year &&
        dueAt!.month == now.month &&
        dueAt!.day == now.day;
  }

  String get recurrenceLabel {
    switch (recurrenceType) {
      case 'daily':
        return 'Diaria';
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensual';
      case 'custom':
        return 'Personalizada';
      default:
        return 'Sin repetición';
    }
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? assignedTo,
    TaskStatus? status,
    int? xpReward,
    int? coinReward,
    String? recurrenceType,
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    DateTime? dueAt,
    DateTime? recurrenceEndAt,
    String? householdId,
    DateTime? createdAt,
    DateTime? completedAt,
    String? completedBy,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? lastCompletedAt,
    String? lastVerifiedBy,
    TaskPriority? priority,
    TaskType? type,
    TaskDifficulty? difficulty,
    String? createdById,
    String? sourceTemplateId,
    String? titleKey,
    List<String>? rotationPool,
    String? rotationStrategy,
    int? rotationIndex,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      recurrenceMonthDays: recurrenceMonthDays ?? this.recurrenceMonthDays,
      dueAt: dueAt ?? this.dueAt,
      recurrenceEndAt: recurrenceEndAt ?? this.recurrenceEndAt,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      lastVerifiedBy: lastVerifiedBy ?? this.lastVerifiedBy,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      createdById: createdById ?? this.createdById,
      sourceTemplateId: sourceTemplateId ?? this.sourceTemplateId,
      titleKey: titleKey ?? this.titleKey,
      rotationPool: rotationPool ?? this.rotationPool,
      rotationStrategy: rotationStrategy ?? this.rotationStrategy,
      rotationIndex: rotationIndex ?? this.rotationIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TaskModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TaskModel(id: $id, title: $title, status: ${status.dbValue})';

  // ── Private helpers ───────────────────────────────────────────────────────

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    return (value as num).toInt();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
