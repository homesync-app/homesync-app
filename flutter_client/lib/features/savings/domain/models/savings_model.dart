class SavingsGoalModel {
  final String id;
  final String householdId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String color;
  final String icon;
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.householdId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.color = '#FF7E67',
    this.icon = '💰',
    required this.createdAt,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'],
      householdId: json['household_id'],
      title: json['title'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      color: json['color'] ?? '#FF7E67',
      icon: json['icon'] ?? '💰',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'target_amount': targetAmount,
      'color': color,
      'icon': icon,
    };
  }

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;
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

  SavingsContributionModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.amount,
    this.note,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory SavingsContributionModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>?;
    return SavingsContributionModel(
      id: json['id'],
      goalId: json['goal_id'],
      userId: json['user_id'],
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      userName: userData?['full_name'],
      userAvatar: userData?['avatar_url'],
    );
  }
}
