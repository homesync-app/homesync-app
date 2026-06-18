class SavingsGoalModel {
  final String id;
  final String householdId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String color;
  final String icon;
  final DateTime createdAt;
  final DateTime? targetDate;
  final DateTime? completedAt;
  final DateTime? archivedAt;
  final String? createdBy;

  SavingsGoalModel({
    required this.id,
    required this.householdId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.color = '#FF7E67',
    this.icon = '💰',
    required this.createdAt,
    this.targetDate,
    this.completedAt,
    this.archivedAt,
    this.createdBy,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) =>
        value == null ? null : DateTime.tryParse(value as String);
    return SavingsGoalModel(
      id: json['id'],
      householdId: json['household_id'],
      title: json['title'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      color: json['color'] ?? '#FF7E67',
      icon: json['icon'] ?? '💰',
      createdAt: DateTime.parse(json['created_at']),
      targetDate: parseDate(json['target_date']),
      completedAt: parseDate(json['completed_at']),
      archivedAt: parseDate(json['archived_at']),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'target_amount': targetAmount,
      'color': color,
      'icon': icon,
      if (targetDate != null) 'target_date': targetDate!.toIso8601String(),
    };
  }

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;

  /// A goal is "reached" once its saved amount meets or exceeds the target.
  /// Derived from amounts so it stays correct even if [completedAt] hasn't
  /// been persisted yet (e.g. right after a contribution).
  bool get isReached => targetAmount > 0 && currentAmount >= targetAmount;

  bool get isArchived => archivedAt != null;
}

class SavingsContributionModel {
  final String id;
  final String goalId;
  final String userId;
  final double amount;
  final String? note;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;
  final String splitType;
  final List<SavingsContributionParticipant> participants;

  SavingsContributionModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.amount,
    this.note,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.splitType = 'personal',
    this.participants = const [],
  });

  factory SavingsContributionModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>?;
    final participants = (json['participants'] as List<dynamic>?)
            ?.whereType<Map>()
            .map(
              (item) => SavingsContributionParticipant.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList() ??
        const <SavingsContributionParticipant>[];
    return SavingsContributionModel(
      id: json['id'],
      goalId: json['goal_id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      userName: userData?['full_name'],
      userAvatar: userData?['avatar_url'],
      splitType: json['split_type'] as String? ?? 'personal',
      participants: participants,
    );
  }

  bool get isSharedContribution =>
      splitType != 'personal' && participants.length > 1;
}

class SavingsContributionParticipant {
  final String userId;
  final String name;
  final String? avatarUrl;

  const SavingsContributionParticipant({
    required this.userId,
    required this.name,
    this.avatarUrl,
  });

  factory SavingsContributionParticipant.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String?;
    final rawEmail = json['email'] as String?;
    return SavingsContributionParticipant(
      userId: json['user_id'] as String? ?? '',
      name: (rawName != null && rawName.trim().isNotEmpty)
          ? rawName.trim().split(' ').first
          : (rawEmail != null && rawEmail.trim().isNotEmpty)
              ? rawEmail.trim().split('@').first
              : 'Miembro',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
}
