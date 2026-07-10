import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/expenses/domain/models/category_budget_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Presupuestos del alcance vigente: en economía integrada los del hogar
/// (owner NULL, cualquier miembro los gestiona); en dividida, los personales
/// del usuario (su gasto por categoría es "su parte" y es info privada).
final categoryBudgetsProvider =
    FutureProvider.autoDispose<List<CategoryBudgetModel>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  final userId = ref.watch(currentUserIdProvider);
  if (householdId == null || userId == null) {
    return const <CategoryBudgetModel>[];
  }

  final household = await ref.watch(currentHouseholdProvider.future);
  final isSharedEconomy = household?.financeMode == 'shared';

  final client = Supabase.instance.client;
  final base = client
      .from('category_budgets')
      .select()
      .eq('household_id', householdId);
  final rows = await (isSharedEconomy
      ? base.isFilter('owner_user_id', null)
      : base.eq('owner_user_id', userId));

  return (rows as List<dynamic>)
      .whereType<Map>()
      .map((row) => CategoryBudgetModel.fromJson(Map<String, dynamic>.from(row)))
      .toList(growable: false);
});

/// Gasto del mes por categoría con semántica de "mi parte" por modo (RPC
/// get_category_spend_v1). Depende del feed para refrescarse solo cuando se
/// registra/borra/paga un movimiento (el form ya invalida el feed).
final categorySpendProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return const <String, double>{};

  // Dependencia intencional: cualquier invalidación del feed re-consulta el
  // gasto (guardar gasto, pagar planificado, settle, etc.).
  await ref.watch(combinedFeedControllerProvider.future);

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final monthEnd = DateTime(now.year, now.month + 1);

  final response = await Supabase.instance.client.rpc(
    'get_category_spend_v1',
    params: {
      'p_household_id': householdId,
      'p_month_start': monthStart.toUtc().toIso8601String(),
      'p_month_end': monthEnd.toUtc().toIso8601String(),
    },
  );

  final result = <String, double>{};
  if (response is List) {
    for (final row in response.whereType<Map>()) {
      final category = row['category']?.toString() ?? 'other';
      final spent = (row['spent'] as num?)?.toDouble() ?? 0;
      result[category] = (result[category] ?? 0) + spent;
    }
  }
  return result;
});

/// Presupuestos + gasto del mes, ordenados por urgencia (mayor % primero).
final categoryBudgetStatusesProvider =
    FutureProvider.autoDispose<List<CategoryBudgetStatus>>((ref) async {
  final budgets = await ref.watch(categoryBudgetsProvider.future);
  if (budgets.isEmpty) return const <CategoryBudgetStatus>[];

  final spend = await ref.watch(categorySpendProvider.future);
  final statuses = budgets
      .map(
        (budget) => CategoryBudgetStatus(
          budget: budget,
          spent: spend[budget.category] ?? 0,
        ),
      )
      .toList(growable: false)
    ..sort((a, b) => b.progress.compareTo(a.progress));
  return statuses;
});

/// Mutaciones de presupuestos (insert/update/delete directos con RLS).
class CategoryBudgetMutations {
  final Ref _ref;

  CategoryBudgetMutations(this._ref);

  Future<void> create({
    required String category,
    required double monthlyLimit,
  }) async {
    final householdId = await _ref.read(householdIdProvider.future);
    final userId = _ref.read(currentUserIdProvider);
    if (householdId == null || userId == null) return;

    final household = await _ref.read(currentHouseholdProvider.future);
    final isSharedEconomy = household?.financeMode == 'shared';

    await Supabase.instance.client.from('category_budgets').insert({
      'household_id': householdId,
      'owner_user_id': isSharedEconomy ? null : userId,
      'category': category,
      'monthly_limit': monthlyLimit,
    });
    log.i('Budget created category=$category limit=$monthlyLimit');
    _invalidate();
  }

  Future<void> updateLimit({
    required String id,
    required double monthlyLimit,
  }) async {
    await Supabase.instance.client.from('category_budgets').update({
      'monthly_limit': monthlyLimit,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
    log.i('Budget updated id=$id limit=$monthlyLimit');
    _invalidate();
  }

  Future<void> delete(String id) async {
    await Supabase.instance.client
        .from('category_budgets')
        .delete()
        .eq('id', id);
    log.i('Budget deleted id=$id');
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(categoryBudgetsProvider);
  }
}

// keepAlive: las mutaciones cruzan awaits después de cerrar el sheet que las
// disparó; un provider autoDispose dejaría un Ref muerto a mitad del RPC
// (misma trampa que el ExpenseRepository).
final categoryBudgetMutationsProvider = Provider(
  CategoryBudgetMutations.new,
);
