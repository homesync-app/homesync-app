import 'package:homesync_client/core/theme/category_mapping.dart';

class ExpenseSplitModel {
  final String userId;
  final double amount;
  final String? fullName;
  final String? avatarUrl;

  const ExpenseSplitModel({
    required this.userId,
    required this.amount,
    this.fullName,
    this.avatarUrl,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> map) {
    // Supabase join structure for users
    final userData = map['users'];
    Map<String, dynamic>? userMap;
    if (userData is Map<String, dynamic>) {
      userMap = userData;
    } else if (userData is List && userData.isNotEmpty) {
      userMap = userData.first as Map<String, dynamic>?;
    }

    return ExpenseSplitModel(
      userId: map['user_id'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      fullName: userMap?['full_name'] as String?,
      avatarUrl: userMap?['avatar_url'] as String?,
    );
  }
}

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
  final String? payerAvatarUrl;
  final bool isShared;
  final String? splitType;
  final String? description;
  final String type; // 'expense' or 'income'
  final List<ExpenseSplitModel>? splits;
  final String? receiptPath;

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
    this.payerAvatarUrl,
    this.isShared = true,
    this.type = 'expense',
    this.splitType,
    this.description,
    this.splits,
    this.receiptPath,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> map) {
    // Robustly handle joined user data
    Map<String, dynamic>? payerMap;
    final rawPayer = map['users'] ?? map['payer'];

    if (rawPayer is Map<String, dynamic>) {
      payerMap = rawPayer;
    } else if (rawPayer is List && rawPayer.isNotEmpty) {
      payerMap = rawPayer.first as Map<String, dynamic>?;
    }

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
      payerAvatarUrl: payerMap?['avatar_url'] as String?,
      isShared: (map['is_shared'] as bool?) ??
          !({'personal', 'gift'}
              .contains((map['split_type'] as String?)?.toLowerCase())),
      type: map['type'] as String? ?? 'expense',
      splitType: map['split_type'] as String?,
      description: map['description'] as String?,
      splits: (map['expense_splits'] as List<dynamic>?)
          ?.map((e) => ExpenseSplitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      receiptPath: map['receipt_path'] as String?,
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
        'receipt_path': receiptPath,
      };

  // ── Display helpers ────────────────────────────────────────────────────────

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
  bool get isSettlement => type == 'settlement';

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
    return CategoryMapping.categoryIcons[category] ?? '📦';
  }

  String get categoryLabel {
    return CategoryMapping.categoryNames[category] ?? 'Otros';
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
