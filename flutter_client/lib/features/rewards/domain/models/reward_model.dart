import 'package:flutter/foundation.dart';

@immutable
class RewardModel {
  final String id;
  final String householdId;
  final String title;
  final String? description;
  final int cost;
  final String icon;
  final String? category;
  final String? createdBy;
  final bool isApproved;
  final bool isActive;
  final DateTime? createdAt;

  const RewardModel({
    required this.id,
    required this.householdId,
    required this.title,
    this.description,
    required this.cost,
    required this.icon,
    this.category,
    this.createdBy,
    required this.isApproved,
    required this.isActive,
    this.createdAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'];
    DateTime? parsedCreatedAt;
    if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    return RewardModel(
      id: (json['id'] as String?) ?? '',
      householdId: (json['household_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Premio sin título',
      description: json['description'] as String?,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String? ?? '🎁',
      category: json['category'] as String?,
      createdBy: json['created_by'] as String?,
      isApproved: json['is_approved'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'title': title,
      'description': description,
      'cost': cost,
      'icon': icon,
      'category': category,
      'created_by': createdBy,
      'is_approved': isApproved,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          cost == other.cost &&
          category == other.category &&
          isApproved == other.isApproved &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      cost.hashCode ^
      category.hashCode ^
      isApproved.hashCode ^
      isActive.hashCode;
}
