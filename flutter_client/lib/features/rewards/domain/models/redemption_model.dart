import 'package:flutter/foundation.dart';

/// Un canje de premio (`reward_redemptions`) con los datos embebidos del
/// premio (`rewards(title, title_key, icon)`) para poder pintarlo sin joins
/// extra del lado del cliente.
@immutable
class RedemptionModel {
  final String id;
  final String rewardId;
  final String userId;
  final String householdId;
  final int cost;
  final String status;
  final DateTime? createdAt;
  final String rewardTitle;
  final String? rewardTitleKey;
  final String rewardIcon;

  const RedemptionModel({
    required this.id,
    required this.rewardId,
    required this.userId,
    required this.householdId,
    required this.cost,
    required this.status,
    this.createdAt,
    required this.rewardTitle,
    this.rewardTitleKey,
    required this.rewardIcon,
  });

  bool get isPending => status == 'pending';

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    final reward = json['rewards'] as Map<String, dynamic>?;
    final rawCreatedAt = json['created_at'];
    DateTime? parsedCreatedAt;
    if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt)?.toLocal();
    }

    return RedemptionModel(
      id: (json['id'] as String?) ?? '',
      rewardId: (json['reward_id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      householdId: (json['household_id'] as String?) ?? '',
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'pending',
      createdAt: parsedCreatedAt,
      rewardTitle: (reward?['title'] as String?) ?? 'Premio sin título',
      rewardTitleKey: reward?['title_key'] as String?,
      rewardIcon: (reward?['icon'] as String?) ?? '🎁',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedemptionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ status.hashCode;
}
