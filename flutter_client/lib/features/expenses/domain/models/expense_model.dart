class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String? category;
  final String householdId;
  final String paidBy;
  final DateTime paidAt;
  final DateTime createdAt;
  final String? payerEmail;
  final String? payerFullName;
  final bool isShared;
  final String? splitType;
  final String? description;
  final String type; // 'expense' or 'income'
  final List<Map<String, dynamic>>? expenseSplits;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    this.category,
    required this.householdId,
    required this.paidBy,
    required this.paidAt,
    required this.createdAt,
    this.payerEmail,
    this.payerFullName,
    this.isShared = true,
    this.type = 'expense',
    this.splitType,
    this.description,
    this.expenseSplits,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> map) {
    final payerMap = map['payer'] as Map<String, dynamic>? ??
        map['users'] as Map<String, dynamic>?;

    return ExpenseModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Movimiento',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String?,
      householdId: map['household_id'] as String? ?? '',
      paidBy: map['paid_by'] as String? ?? '',
      paidAt: DateTime.tryParse(map['paid_at'] as String? ?? '') ??
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      payerEmail: payerMap?['email'] as String?,
      payerFullName: payerMap?['full_name'] as String?,
      isShared: map['is_shared'] as bool? ?? true,
      type: map['type'] as String? ?? 'expense',
      splitType: map['split_type'] as String?,
      description: map['description'] as String?,
      expenseSplits: (map['expense_splits'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'household_id': householdId,
        'paid_by': paidBy,
        'paid_at': paidAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'is_shared': isShared,
        'type': type,
        'split_type': splitType,
        'description': description,
      };

  // ── Display helpers ────────────────────────────────────────────────────────

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  String get payerDisplayName {
    if (payerFullName != null && payerFullName!.isNotEmpty) {
      return payerFullName!.split(' ').first;
    }
    if (payerEmail != null && payerEmail!.isNotEmpty) {
      return payerEmail!.split('@').first;
    }
    return 'Alguien';
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  String get categoryIcon {
    const icons = {
      'supermarket': '🛒',
      'utilities': '💡',
      'rent': '🏠',
      'restaurants': '🍽️',
      'transport': '🚗',
      'entertainment': '🎬',
      'health': '💊',
      'other': '📦',
    };
    return icons[category] ?? '📦';
  }

  String get categoryLabel {
    const labels = {
      'supermarket': 'Supermercado',
      'utilities': 'Servicios',
      'rent': 'Alquiler',
      'restaurants': 'Restaurantes',
      'transport': 'Transporte',
      'entertainment': 'Entretenimiento',
      'health': 'Salud',
      'other': 'Otros',
    };
    return labels[category] ?? 'Otros';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ExpenseModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ExpenseModel(id: $id, title: $title, amount: $amount)';
}

/// Represents a member's financial balance within the household
class HouseholdBalanceModel {
  final String userId;
  final String? userEmail;
  final String? userFullName;
  final double balance;
  final String? avatarUrl;

  const HouseholdBalanceModel({
    required this.userId,
    this.userEmail,
    this.userFullName,
    required this.balance,
    this.avatarUrl,
  });

  factory HouseholdBalanceModel.fromJson(Map<String, dynamic> map) {
    return HouseholdBalanceModel(
      userId: map['user_id'] as String? ?? '',
      userEmail: map['user_email'] as String?,
      userFullName: map['user_full_name'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  String get displayName {
    if (userFullName != null && userFullName!.isNotEmpty) {
      return userFullName!.split(' ').first;
    }
    if (userEmail != null && userEmail!.isNotEmpty) {
      return userEmail!.split('@').first;
    }
    return 'Miembro';
  }

  bool get isSettled => balance.abs() < 0.01;
  bool get isCreditor => balance > 0.01;
  bool get isDebtor => balance < -0.01;

  String get statusLabel {
    if (isSettled) return 'Al día ✓';
    if (isCreditor) return 'Aportó de más';
    return 'Debe aportar';
  }
}
