import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_pool_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fondos activos del hogar (RLS los limita a miembros).
final activePoolsProvider =
    FutureProvider.autoDispose<List<ExpensePoolModel>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return const <ExpensePoolModel>[];

  final rows = await Supabase.instance.client
      .from('expense_pools')
      .select()
      .eq('household_id', householdId)
      .eq('status', 'active')
      .order('created_at', ascending: false);

  return (rows as List<dynamic>)
      .whereType<Map>()
      .map((row) => ExpensePoolModel.fromJson(Map<String, dynamic>.from(row)))
      .toList(growable: false);
});

/// Detalle de un fondo. Depende del feed para refrescarse cuando se registra
/// o liquida un gasto.
final poolSummaryProvider = FutureProvider.autoDispose
    .family<PoolSummary?, String>((ref, poolId) async {
  await ref.watch(combinedFeedControllerProvider.future);

  final response = await Supabase.instance.client.rpc(
    'get_pool_summary_v1',
    params: {'p_pool_id': poolId},
  );
  if (response is! Map) return null;
  final map = Map<String, dynamic>.from(response);
  if (map['found'] != true) return null;
  return PoolSummary.fromJson(map);
});

// keepAlive: las mutaciones cruzan awaits después de cerrar el sheet que las
// disparó (misma trampa del Ref disposed que el resto de finanzas).
final poolMutationsProvider = Provider(PoolMutations.new);

class PoolMutations {
  final Ref _ref;

  PoolMutations(this._ref);

  Future<void> create({required String name, required String emoji}) async {
    final householdId = await _ref.read(householdIdProvider.future);
    final userId = _ref.read(currentUserIdProvider);
    if (householdId == null || userId == null) return;

    await Supabase.instance.client.from('expense_pools').insert({
      'household_id': householdId,
      'name': name,
      'emoji': emoji,
      'created_by': userId,
    });
    log.i('Pool created name=$name');
    _ref.invalidate(activePoolsProvider);
  }

  Future<void> close(String poolId) async {
    await Supabase.instance.client.from('expense_pools').update({
      'status': 'closed',
      'closed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', poolId);
    log.i('Pool closed id=$poolId');
    _ref.invalidate(activePoolsProvider);
  }
}
