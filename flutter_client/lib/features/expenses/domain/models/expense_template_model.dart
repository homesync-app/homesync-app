class ExpenseTemplateModel {
  final String id;
  final String householdId;
  final String title;
  final String? titleKey;
  final double defaultAmount;
  final String category;
  final String frequency;
  final int dayOfMonth;
  final String splitType;
  final String payerDefault;
  final bool isActive;
  final String type; // 'expense' | 'income'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? nextExecutionDate;

  const ExpenseTemplateModel({
    required this.id,
    required this.householdId,
    required this.title,
    this.titleKey,
    required this.defaultAmount,
    required this.category,
    this.frequency = 'monthly',
    required this.dayOfMonth,
    required this.splitType,
    required this.payerDefault,
    this.isActive = true,
    this.type = 'expense',
    this.createdAt,
    this.updatedAt,
    this.nextExecutionDate,
  });

  bool get isIncome => type == 'income';

  factory ExpenseTemplateModel.fromJson(Map<String, dynamic> json) {
    return ExpenseTemplateModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      title: json['title'] as String,
      titleKey: json['title_key'] as String?,
      defaultAmount: (json['default_amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String,
      frequency: json['frequency'] as String? ?? 'monthly',
      dayOfMonth: json['day_of_month'] as int,
      splitType: json['split_type'] as String,
      payerDefault: json['payer_default'] as String,
      isActive: json['is_active'] as bool? ?? true,
      type: json['type'] as String? ?? 'expense',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      nextExecutionDate: json['next_execution_date'] != null
          ? DateTime.parse(json['next_execution_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'title': title,
      'title_key': titleKey,
      'default_amount': defaultAmount,
      'category': category,
      'frequency': frequency,
      'day_of_month': dayOfMonth,
      'split_type': splitType,
      'payer_default': payerDefault,
      'is_active': isActive,
      'type': type,
      if (nextExecutionDate != null)
        'next_execution_date': nextExecutionDate!.toIso8601String(),
    };
  }

  ExpenseTemplateModel copyWith({
    String? id,
    String? householdId,
    String? title,
    String? titleKey,
    double? defaultAmount,
    String? category,
    String? frequency,
    int? dayOfMonth,
    String? splitType,
    String? payerDefault,
    bool? isActive,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextExecutionDate,
  }) {
    return ExpenseTemplateModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      title: title ?? this.title,
      titleKey: titleKey ?? this.titleKey,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      splitType: splitType ?? this.splitType,
      payerDefault: payerDefault ?? this.payerDefault,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
    );
  }
}
