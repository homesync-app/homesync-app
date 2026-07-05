import 'package:flutter/foundation.dart';

/// Household model.
@immutable
class HouseholdModel {
  final String id;
  final String name;
  final String householdType;
  final bool tasksEnabled;
  final String financeMode;
  final double defaultSplitRatio;

  /// The member [defaultSplitRatio] belongs to. The other member pays
  /// `1 - defaultSplitRatio`. Null means no anchored ratio (split evenly).
  final String? splitRatioAnchorId;
  final DateTime? createdAt;

  /// Sprint 1 Modo Padres: 'off' | 'children_only' | 'per_member'.
  /// La RPC `complete_task_transaction` lee esto del lado servidor; en el
  /// cliente lo usamos para mostrar el toggle correcto en settings.
  final String taskApprovalMode;

  /// Parent Mode (premium): si las mesadas (transferencia adulto→teen) están
  /// habilitadas. Off por defecto. El gate efectivo (familia + premium) lo
  /// aplica `allowanceEnabledProvider`.
  final bool allowanceEnabled;

  const HouseholdModel({
    required this.id,
    required this.name,
    required this.householdType,
    this.tasksEnabled = true,
    this.financeMode = 'divided',
    this.defaultSplitRatio = 0.5,
    this.splitRatioAnchorId,
    this.createdAt,
    this.taskApprovalMode = 'off',
    this.allowanceEnabled = false,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    return HouseholdModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Mi Hogar',
      householdType: json['household_type'] as String? ?? 'couple',
      tasksEnabled: json['tasks_enabled'] as bool? ?? true,
      financeMode: json['finance_mode'] as String? ??
          ((json['household_type'] as String?) == 'family'
              ? 'shared'
              : 'divided'),
      defaultSplitRatio:
          (json['default_split_ratio'] as num? ?? 0.5).toDouble(),
      splitRatioAnchorId: json['split_ratio_anchor_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      taskApprovalMode: (json['task_approval_mode'] as String?) ?? 'off',
      allowanceEnabled: json['allowance_enabled'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HouseholdModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
