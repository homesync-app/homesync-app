/// Presupuesto mensual de una categoría de gasto.
///
/// `ownerUserId` define el alcance: NULL es un presupuesto DEL HOGAR
/// (economía integrada); con dueño es personal (economía dividida), donde el
/// gasto medido es "mi parte" de los compartidos + mis personales.
class CategoryBudgetModel {
  final String id;
  final String householdId;
  final String? ownerUserId;
  final String category;
  final double monthlyLimit;

  const CategoryBudgetModel({
    required this.id,
    required this.householdId,
    required this.ownerUserId,
    required this.category,
    required this.monthlyLimit,
  });

  factory CategoryBudgetModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      ownerUserId: json['owner_user_id'] as String?,
      category: json['category'] as String? ?? 'other',
      monthlyLimit: (json['monthly_limit'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Presupuesto + gasto del mes en curso, listo para pintar.
class CategoryBudgetStatus {
  final CategoryBudgetModel budget;
  final double spent;

  const CategoryBudgetStatus({required this.budget, required this.spent});

  double get progress =>
      budget.monthlyLimit <= 0 ? 0 : spent / budget.monthlyLimit;

  double get remaining => budget.monthlyLimit - spent;

  bool get isNearLimit => progress >= 0.8 && progress <= 1.0;

  bool get isOverLimit => progress > 1.0;
}
