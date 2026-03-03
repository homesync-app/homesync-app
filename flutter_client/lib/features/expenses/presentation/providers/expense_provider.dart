import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/supabase_expense_repository.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/get_balances_usecase.dart';
import '../../domain/usecases/save_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/settle_debt_usecase.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

// --- Repositories & Use Cases ---

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseExpenseRepository(client);
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetExpensesUseCase(repo);
});

final getBalancesUseCaseProvider = Provider<GetBalancesUseCase>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetBalancesUseCase(repo);
});

final saveExpenseUseCaseProvider = Provider<SaveExpenseUseCase>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return SaveExpenseUseCase(repo);
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return DeleteExpenseUseCase(repo);
});

final settleDebtUseCaseProvider = Provider<SettleDebtUseCase>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return SettleDebtUseCase(repo);
});

// --- State Provider ---

// Provides the combined expenses and balances state stream
final expensesAndBalancesProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final householdIdAsync = await ref.watch(householdIdProvider.future);
  if (householdIdAsync == null) {
    yield {'expenses': <ExpenseModel>[], 'balances': <HouseholdBalanceModel>[], 'householdId': ''};
    return;
  }
  
  final getExpenses = ref.read(getExpensesUseCaseProvider);
  final getBalances = ref.read(getBalancesUseCaseProvider);
  final client = ref.read(supabaseClientProvider);

  // Snapshot function
  Future<Map<String, dynamic>> snapshot() async {
    final expensesResult = await getExpenses(householdIdAsync);
    final balancesResult = await getBalances(householdIdAsync);
    
    final expenses = expensesResult.fold(
      (f) {
        log.e('Error fetching expenses: ${f.message}');
        return <ExpenseModel>[];
      },
      (r) => r,
    );
    
    final balances = balancesResult.fold(
      (f) {
        log.e('Error fetching balances: ${f.message}');
        return <HouseholdBalanceModel>[];
      },
      (r) => r,
    );

    return {'expenses': expenses, 'balances': balances, 'householdId': householdIdAsync};
  }

  // Initial fetch
  yield await snapshot();

  // Realtime subscription setup
  final expensesChannel = client
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
      );
      
  await expensesChannel.subscribe();

  final splitsChannel = client
      .channel('splits_stream_$householdIdAsync')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'expense_splits',
        callback: (_) {
          ref.invalidateSelf();
        },
      );
      
  await splitsChannel.subscribe();

  ref.onDispose(() {
    client.removeChannel(expensesChannel);
    client.removeChannel(splitsChannel);
  });
});
