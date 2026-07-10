import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonthRecapPayer {
  final String userId;
  final String name;
  final String? avatarUrl;
  final double paid;

  const MonthRecapPayer({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.paid,
  });
}

class MonthRecapCategory {
  final String category;
  final double spent;

  const MonthRecapCategory({required this.category, required this.spent});
}

/// Resumen narrativo del MES ANTERIOR (RPC get_month_recap_v1). Null si ese
/// mes no tuvo movimientos — sin datos no hay historia que contar.
class MonthRecapData {
  final DateTime month;
  final double totalSpent;
  final double prevSpent;
  final double income;
  final List<MonthRecapCategory> byCategory;
  final List<MonthRecapPayer> byPayer;
  final double savingsAdded;
  final int expenseCount;
  final bool sharedEconomy;

  const MonthRecapData({
    required this.month,
    required this.totalSpent,
    required this.prevSpent,
    required this.income,
    required this.byCategory,
    required this.byPayer,
    required this.savingsAdded,
    required this.expenseCount,
    required this.sharedEconomy,
  });
}

final monthRecapProvider =
    FutureProvider.autoDispose<MonthRecapData?>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return null;

  final now = DateTime.now();
  final month = DateTime(now.year, now.month - 1);
  final monthStart = DateTime(month.year, month.month);
  final monthEnd = DateTime(month.year, month.month + 1);

  final response = await Supabase.instance.client.rpc(
    'get_month_recap_v1',
    params: {
      'p_household_id': householdId,
      'p_month_start': monthStart.toUtc().toIso8601String(),
      'p_month_end': monthEnd.toUtc().toIso8601String(),
    },
  );
  if (response is! Map) return null;
  final map = Map<String, dynamic>.from(response);

  final expenseCount = (map['expense_count'] as num?)?.toInt() ?? 0;
  if (expenseCount == 0) return null;

  final byCategory = <MonthRecapCategory>[
    if (map['by_category'] is List)
      for (final row in (map['by_category'] as List).whereType<Map>())
        MonthRecapCategory(
          category: row['category']?.toString() ?? 'other',
          spent: (row['spent'] as num?)?.toDouble() ?? 0,
        ),
  ];
  final byPayer = <MonthRecapPayer>[
    if (map['by_payer'] is List)
      for (final row in (map['by_payer'] as List).whereType<Map>())
        MonthRecapPayer(
          userId: row['user_id']?.toString() ?? '',
          name: row['name']?.toString() ?? '',
          avatarUrl: row['avatar_url']?.toString(),
          paid: (row['paid'] as num?)?.toDouble() ?? 0,
        ),
  ];

  return MonthRecapData(
    month: month,
    totalSpent: (map['total_spent'] as num?)?.toDouble() ?? 0,
    prevSpent: (map['prev_spent'] as num?)?.toDouble() ?? 0,
    income: (map['income'] as num?)?.toDouble() ?? 0,
    byCategory: byCategory,
    byPayer: byPayer,
    savingsAdded: (map['savings_added'] as num?)?.toDouble() ?? 0,
    expenseCount: expenseCount,
    sharedEconomy: map['shared_economy'] == true,
  );
});

String _dismissKeyFor(DateTime month) =>
    'homesync_recap_dismissed_${month.year}-${month.month}';

/// true si el banner del recap fue descartado para el mes recapitulado.
final monthRecapDismissedProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final now = DateTime.now();
  final month = DateTime(now.year, now.month - 1);
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_dismissKeyFor(month)) ?? false;
});

Future<void> persistMonthRecapDismissal() async {
  final now = DateTime.now();
  final month = DateTime(now.year, now.month - 1);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_dismissKeyFor(month), true);
}
