class Expense {
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

  const Expense({
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
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    final payerMap = map['payer'] as Map<String, dynamic>? ??
        map['users'] as Map<String, dynamic>?;

    return Expense(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Gasto',
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
      };

  // ── Display helpers ────────────────────────────────────────────────────────

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
      identical(this, other) || other is Expense && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Expense(id: $id, title: $title, amount: $amount)';
}

/// Represents a member's financial balance within the household
class HouseholdBalance {
  final String userId;
  final String? userEmail;
  final String? userFullName;
  final double balance;

  const HouseholdBalance({
    required this.userId,
    this.userEmail,
    this.userFullName,
    required this.balance,
  });

  factory HouseholdBalance.fromMap(Map<String, dynamic> map) {
    return HouseholdBalance(
      userId: map['user_id'] as String? ?? '',
      userEmail: map['user_email'] as String?,
      userFullName: map['user_full_name'] as String?,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
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
