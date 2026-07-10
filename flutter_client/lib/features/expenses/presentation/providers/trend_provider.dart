import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MonthlySpendPoint {
  final DateTime month;
  final double spent;

  const MonthlySpendPoint({required this.month, required this.spent});

  bool get isCurrentMonth {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }
}

/// Gasto de los últimos 6 meses (RPC get_monthly_spend_trend_v1, con la misma
/// semántica de "mi parte" que el resumen). Devuelve SIEMPRE 6 puntos — los
/// meses sin movimientos van en 0 — para que las barras mantengan la línea de
/// tiempo. Depende del feed para refrescarse tras registrar movimientos.
final monthlySpendTrendProvider =
    FutureProvider.autoDispose<List<MonthlySpendPoint>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return const <MonthlySpendPoint>[];

  await ref.watch(combinedFeedControllerProvider.future);

  final response = await Supabase.instance.client.rpc(
    'get_monthly_spend_trend_v1',
    params: {
      'p_household_id': householdId,
      'p_months': 6,
    },
  );

  final spentByMonth = <String, double>{};
  if (response is List) {
    for (final row in response.whereType<Map>()) {
      final month = DateTime.tryParse(row['month_start']?.toString() ?? '');
      if (month == null) continue;
      spentByMonth['${month.year}-${month.month}'] =
          (row['spent'] as num?)?.toDouble() ?? 0;
    }
  }

  final now = DateTime.now();
  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - 5 + i);
    return MonthlySpendPoint(
      month: month,
      spent: spentByMonth['${month.year}-${month.month}'] ?? 0,
    );
  });
});
