import 'package:flutter/foundation.dart';

/// Household model.
@immutable
class HouseholdModel {
  final String id;
  final String name;
  final String householdType;
  final DateTime? createdAt;

  const HouseholdModel({
    required this.id,
    required this.name,
    required this.householdType,
    this.createdAt,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    return HouseholdModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Mi Hogar',
      householdType: json['household_type'] as String? ?? 'couple',
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
