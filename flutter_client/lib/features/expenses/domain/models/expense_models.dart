class Expense {
  final String id;
  final String householdId;
  final String createdById;
  final String title;
  final String? description;
  final String category;
  final double amount;
  final String currency;
  final String paidBy;
  final DateTime paidAt;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.householdId,
    required this.createdById,
    required this.title,
    this.description,
    required this.category,
    required this.amount,
    required this.currency,
    required this.paidBy,
    required this.paidAt,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      createdById: json['created_by_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paidBy: json['paid_by'] as String,
      paidAt: DateTime.parse(json['paid_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ExpenseBalance {
  final String userId;
  final String userEmail;
  final double totalPaid;
  final double totalOwed;
  final double balance;

  ExpenseBalance({
    required this.userId,
    required this.userEmail,
    required this.totalPaid,
    required this.totalOwed,
    required this.balance,
  });

  factory ExpenseBalance.fromJson(Map<String, dynamic> json) {
    return ExpenseBalance(
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0,
      totalOwed: (json['total_owed'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Debt {
  final String debtorId;
  final String debtorEmail;
  final String creditorId;
  final String creditorEmail;
  final double amount;

  Debt({
    required this.debtorId,
    required this.debtorEmail,
    required this.creditorId,
    required this.creditorEmail,
    required this.amount,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      debtorId: json['debtor_id'] as String,
      debtorEmail: json['debtor_email'] as String,
      creditorId: json['creditor_id'] as String,
      creditorEmail: json['creditor_email'] as String,
      amount: (json['debt_amount'] as num).toDouble(),
    );
  }
}

class ExpenseHistoryItem {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final String category;
  final String paidByEmail;
  final DateTime createdAt;
  final int splitCount;

  ExpenseHistoryItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.paidByEmail,
    required this.createdAt,
    required this.splitCount,
  });

  factory ExpenseHistoryItem.fromJson(Map<String, dynamic> json) {
    return ExpenseHistoryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: json['category'] as String,
      paidByEmail: json['paid_by_email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      splitCount: json['split_count'] as int,
    );
  }
}

class ExpenseCategory {
  final String id;
  final String name;
  final String icon;
  final String color;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}
