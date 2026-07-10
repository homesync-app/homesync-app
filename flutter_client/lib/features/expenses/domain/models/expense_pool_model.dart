/// Fondo de gasto (modo convivencia): agrupa gastos compartidos de un evento
/// ("Asado", "Viaje") sin sacarlos del balance global del hogar.
class ExpensePoolModel {
  final String id;
  final String householdId;
  final String name;
  final String emoji;
  final String status; // 'active' | 'closed'
  final String? createdBy;
  final DateTime? createdAt;

  const ExpensePoolModel({
    required this.id,
    required this.householdId,
    required this.name,
    required this.emoji,
    required this.status,
    this.createdBy,
    this.createdAt,
  });

  bool get isActive => status == 'active';

  factory ExpensePoolModel.fromJson(Map<String, dynamic> json) {
    return ExpensePoolModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🎉',
      status: json['status'] as String? ?? 'active',
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class PoolMemberPaid {
  final String userId;
  final String name;
  final String? avatarUrl;
  final double paid;

  const PoolMemberPaid({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.paid,
  });
}

class PoolBalance {
  final String userId;
  final String name;
  final String? avatarUrl;
  final double balance;

  const PoolBalance({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.balance,
  });
}

class PoolExpenseRow {
  final String id;
  final String title;
  final String? titleKey;
  final double amount;
  final String? category;
  final String type;
  final DateTime paidAt;
  final String? payerName;

  const PoolExpenseRow({
    required this.id,
    required this.title,
    required this.titleKey,
    required this.amount,
    required this.category,
    required this.type,
    required this.paidAt,
    required this.payerName,
  });
}

/// Detalle completo de un fondo (RPC get_pool_summary_v1).
class PoolSummary {
  final ExpensePoolModel pool;
  final double total;
  final List<PoolMemberPaid> members;
  final List<PoolBalance> balances;
  final List<PoolExpenseRow> expenses;

  const PoolSummary({
    required this.pool,
    required this.total,
    required this.members,
    required this.balances,
    required this.expenses,
  });

  bool get isSettled => balances.isEmpty;

  factory PoolSummary.fromJson(Map<String, dynamic> json) {
    final poolMap = Map<String, dynamic>.from(json['pool'] as Map);
    return PoolSummary(
      pool: ExpensePoolModel.fromJson({
        ...poolMap,
        'household_id': poolMap['household_id'] ?? '',
      }),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      members: [
        if (json['members'] is List)
          for (final row in (json['members'] as List).whereType<Map>())
            PoolMemberPaid(
              userId: row['user_id']?.toString() ?? '',
              name: row['name']?.toString() ?? '',
              avatarUrl: row['avatar_url']?.toString(),
              paid: (row['paid'] as num?)?.toDouble() ?? 0,
            ),
      ],
      balances: [
        if (json['balances'] is List)
          for (final row in (json['balances'] as List).whereType<Map>())
            PoolBalance(
              userId: row['user_id']?.toString() ?? '',
              name: row['name']?.toString() ?? '',
              avatarUrl: row['avatar_url']?.toString(),
              balance: (row['balance'] as num?)?.toDouble() ?? 0,
            ),
      ],
      expenses: [
        if (json['expenses'] is List)
          for (final row in (json['expenses'] as List).whereType<Map>())
            PoolExpenseRow(
              id: row['id']?.toString() ?? '',
              title: row['title']?.toString() ?? '',
              titleKey: row['title_key']?.toString(),
              amount: (row['amount'] as num?)?.toDouble() ?? 0,
              category: row['category']?.toString(),
              type: row['type']?.toString() ?? 'expense',
              paidAt: DateTime.tryParse(row['paid_at']?.toString() ?? '') ??
                  DateTime.now(),
              payerName: row['payer_name']?.toString(),
            ),
      ],
    );
  }
}
