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
final expensesAndBalancesProvider =
    StreamProvider<Map<String, dynamic>>((ref) async* {
  final householdIdAsync = await ref.watch(householdIdProvider.future);
  if (householdIdAsync == null) {
    yield {
      'expenses': <ExpenseModel>[],
      'balances': <HouseholdBalanceModel>[],
      'householdId': ''
    };
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

    return {
      'expenses': expenses,
      'balances': balances,
      'householdId': householdIdAsync
    };
  }

  // Initial fetch
  yield await snapshot();

  // Realtime subscription setup
  final expensesChannel =
      client.channel('expenses_stream_$householdIdAsync').onPostgresChanges(
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

  final splitsChannel =
      client.channel('splits_stream_$householdIdAsync').onPostgresChanges(
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

// --- Filtering and Summaries ---

final personalFinanceSummaryProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  final householdId = await ref.watch(householdIdProvider.future);

  if (userId == null || householdId == null) {
    log.w(
        'SummaryProvider: Missing userId ($userId) or householdId ($householdId)');
    return {};
  }

  try {
    final response = await client.rpc('get_personal_finance_summary', params: {
      'p_user_id': userId,
      'p_household_id': householdId,
    });

    if (response == null) return {};
    return Map<String, dynamic>.from(response);
  } catch (e) {
    log.e('Error fetching personal summary: $e');
    return {};
  }
});

class ExpenseFilters {
  final String type; // 'all', 'income', 'expense'
  final String sharing; // 'all', 'mine', 'shared'

  ExpenseFilters({this.type = 'all', this.sharing = 'all'});

  ExpenseFilters copyWith({String? type, String? sharing}) {
    return ExpenseFilters(
      type: type ?? this.type,
      sharing: sharing ?? this.sharing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseFilters &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          sharing == other.sharing;

  @override
  int get hashCode => type.hashCode ^ sharing.hashCode;
}

final expenseFiltersProvider =
    StateProvider<ExpenseFilters>((ref) => ExpenseFilters());

final filteredExpensesProvider =
    FutureProvider<List<ExpenseModel>>((ref) async {
  final filters = ref.watch(expenseFiltersProvider);
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return [];

  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client.rpc('get_filtered_expenses', params: {
      'p_household_id': householdId,
      'p_type': filters.type,
      'p_sharing': filters.sharing,
      'p_limit': 100,
      'p_offset': 0,
    });

    if (response == null) return [];
    final List<dynamic> records = response as List<dynamic>;
    log.d(
        'Finance: Fetched ${records.length} records for filter: ${filters.type}/${filters.sharing}');
    return records
        .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    log.e('Error fetching filtered expenses: $e');
    return [];
  }
});
