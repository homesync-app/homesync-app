import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/expense_repository.dart';
import 'core_providers.dart';

// Provides the combined expenses and balances state
final expensesAndBalancesProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final householdIdAsync = await ref.watch(householdIdProvider.future);
  if (householdIdAsync == null) {
    yield {'expenses': [], 'balances': [], 'householdId': ''};
    return;
  }
  
  final repo = ref.read(expenseRepositoryProvider);
  final client = Supabase.instance.client;

  // Let's create a snapshot function
  Future<Map<String, dynamic>> snapshot() async {
    final expenses = await repo.getRecentExpenses(householdIdAsync);
    final balances = await repo.getHouseholdBalances(householdIdAsync);
    return {'expenses': expenses, 'balances': balances, 'householdId': householdIdAsync};
  }

  // Initial fetch
  yield await snapshot();

  // Realtime subscription setup
  final stream = client
      .channel('expenses_stream_$householdIdAsync')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'expenses',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'household_id',
          value: householdIdAsync,
        ),
        callback: (_) {
          ref.invalidateSelf();
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(stream);
  });
});
