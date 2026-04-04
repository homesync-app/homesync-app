import 'package:flutter/foundation.dart';

/// Household model.
@immutable
class HouseholdModel {
  final String id;
  final String name;
  final String householdType;
  final bool tasksEnabled;
  final double defaultSplitRatio;
  final DateTime? createdAt;

  const HouseholdModel({
    required this.id,
    required this.name,
    required this.householdType,
    this.tasksEnabled = true,
    this.defaultSplitRatio = 0.5,
    this.createdAt,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    return HouseholdModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Mi Hogar',
      householdType: json['household_type'] as String? ?? 'couple',
      tasksEnabled: json['tasks_enabled'] as bool? ?? true,
      defaultSplitRatio: (json['default_split_ratio'] as num? ?? 0.5).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HouseholdModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
