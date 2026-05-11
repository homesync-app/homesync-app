class ShoppingItemModel {
  final String id;
  final String householdId;
  final String name;
  final String? nameKey;
  final String? quantity;
  final String? unit;
  final String category;
  final String emoji;
  final String? note;
  final String? addedBy;
  final String? addedByName;
  final bool completed;
  final String? completedBy;
  final String? completedByName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool shouldSync;

  const ShoppingItemModel({
    required this.id,
    required this.householdId,
    required this.name,
    this.nameKey,
    this.quantity,
    this.unit,
    this.category = 'general',
    this.emoji = '🛒',
    this.note,
    this.addedBy,
    this.addedByName,
    this.completed = false,
    this.completedBy,
    this.completedByName,
    this.completedAt,
    required this.createdAt,
    this.shouldSync = true,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> map) {
    return ShoppingItemModel(
      id: map['id'] as String,
      householdId: map['household_id'] as String,
      name: map['name'] as String,
      nameKey: map['name_key'] as String?,
      quantity: map['quantity'] as String?,
      unit: map['unit'] as String?,
      category: map['category'] as String? ?? 'general',
      emoji: map['emoji'] as String? ?? '🛒',
      note: map['note'] as String?,
      addedBy: map['added_by'] as String?,
      addedByName: (map['added_by_user'] as Map<String, dynamic>?)?['full_name']
          as String?,
      completed: map['completed'] as bool? ?? false,
      completedBy: map['completed_by'] as String?,
      completedByName: (map['completed_by_user']
          as Map<String, dynamic>?)?['full_name'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      shouldSync: map['should_sync'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household_id': householdId,
      'name': name,
      'name_key': nameKey,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'emoji': emoji,
      'note': note,
      'added_by': addedBy,
      'completed': completed,
      'completed_by': completedBy,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'should_sync': shouldSync,
    };
  }

  String get displayQuantity {
    if (quantity == null && unit == null) return '';
    if (unit == null) return quantity!;
    return '$quantity $unit';
  }

  String get addedByDisplay {
    if (addedByName == null) return '';
    return addedByName!.split(' ').first;
  }

  String get completedByDisplay {
    if (completedByName == null) return '';
    return completedByName!.split(' ').first;
  }

  ShoppingItemModel copyWith({
    bool? completed,
    String? completedBy,
    DateTime? completedAt,
    bool? shouldSync,
  }) {
    return ShoppingItemModel(
      id: id,
      householdId: householdId,
      name: name,
      nameKey: nameKey,
      quantity: quantity,
      unit: unit,
      category: category,
      emoji: emoji,
      note: note,
      addedBy: addedBy,
      addedByName: addedByName,
      completed: completed ?? this.completed,
      completedBy: completedBy ?? this.completedBy,
      completedByName: completedByName,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      shouldSync: shouldSync ?? this.shouldSync,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
