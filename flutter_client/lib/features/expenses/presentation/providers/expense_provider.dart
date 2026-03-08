import 'package:homesync_client/core/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/constants/app_constants.dart';
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

part 'expense_provider.g.dart';

// --- Repositories & Use Cases ---

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(ExpenseRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseExpenseRepository(client, ref);
}

@riverpod
GetExpensesUseCase getExpensesUseCase(GetExpensesUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetExpensesUseCase(repo);
}

@riverpod
GetBalancesUseCase getBalancesUseCase(GetBalancesUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetBalancesUseCase(repo);
}

@riverpod
SaveExpenseUseCase saveExpenseUseCase(SaveExpenseUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return SaveExpenseUseCase(repo);
}

@riverpod
DeleteExpenseUseCase deleteExpenseUseCase(DeleteExpenseUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return DeleteExpenseUseCase(repo);
}

@riverpod
SettleDebtUseCase settleDebtUseCase(SettleDebtUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return SettleDebtUseCase(repo);
}

// ── Controller ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ExpenseController extends _$ExpenseController {
  @override
  Future<List<ExpenseModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final filters = ref.watch(expenseFiltersNotifierProvider);
    return _fetchExpenses(householdId, filters);
  }

  Future<List<ExpenseModel>> _fetchExpenses(String householdId, ExpenseFilters filters) async {
    final client = ref.read(supabaseClientProvider);
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
      return records
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log.e('Error fetching expenses: $e');
      return [];
    }
  }

  Future<void> saveExpense({
    String? id,
    required String householdId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime paidAt,
    String? description,
    required SplitType splitType,
    String type = 'expense',
    List<Map<String, dynamic>>? splits,
  }) async {
    final useCase = ref.read(saveExpenseUseCaseProvider);
    final result = await useCase(
      id: id,
      householdId: householdId,
      title: title,
      amount: amount,
      category: category,
      paidBy: paidBy,
      paidAt: paidAt,
      description: description,
      splitType: splitType,
      type: type,
      splits: splits,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidateSelf();
        // Also invalidate summary and balances
        ref.invalidate(personalFinanceSummaryProvider);
        ref.invalidate(expensesAndBalancesProvider);
        ref.invalidate(expenseBalancesProvider);
      },
    );
  }

  Future<void> deleteExpense(String id) async {
    final useCase = ref.read(deleteExpenseUseCaseProvider);
    final result = await useCase(id);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidateSelf();
        ref.invalidate(personalFinanceSummaryProvider);
        ref.invalidate(expensesAndBalancesProvider);
        ref.invalidate(expenseBalancesProvider);
      },
    );
  }

  Future<void> settleDebt({
    required String householdId,
    required String toUserId,
    required double amount,
  }) async {
    final useCase = ref.read(settleDebtUseCaseProvider);
    final result = await useCase(
      householdId: householdId,
      toUserId: toUserId,
      amount: amount,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        ref.invalidateSelf();
        ref.invalidate(personalFinanceSummaryProvider);
        ref.invalidate(expensesAndBalancesProvider);
        ref.invalidate(expenseBalancesProvider);
      },
    );
  }
}

// --- State Providers ---

/// Provides the combined expenses and balances state stream
@Riverpod(keepAlive: true)
Stream<Map<String, dynamic>> expensesAndBalances(ExpensesAndBalancesRef ref) async* {
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
            table: AppConstants.tableExpenses,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'household_id',
              value: householdIdAsync,
            ),
            callback: (payload) {
              log.i('Realtime expense change detected: ${payload.eventType}');
              ref.invalidateSelf();
            },
          );

  expensesChannel.subscribe();

  final splitsChannel =
      client.channel('splits_stream_$householdIdAsync').onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.tableExpenseSplits,
            callback: (payload) {
              log.i('Realtime expense split change detected: ${payload.eventType}');
              ref.invalidateSelf();
            },
          );

  splitsChannel.subscribe();

  ref.onDispose(() {
    client.removeChannel(expensesChannel);
    client.removeChannel(splitsChannel);
  });
}

@riverpod
Future<Map<String, dynamic>> personalFinanceSummary(PersonalFinanceSummaryRef ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  final householdId = await ref.watch(householdIdProvider.future);

  if (userId == null || householdId == null) {
    log.w('SummaryProvider: Missing userId ($userId) or householdId ($householdId)');
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
}

// --- Filtering and Summaries ---

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

@riverpod
class ExpenseFiltersNotifier extends _$ExpenseFiltersNotifier {
  @override
  ExpenseFilters build() => ExpenseFilters();

  void updateFilters({String? type, String? sharing}) {
    state = state.copyWith(type: type, sharing: sharing);
  }
}

@riverpod
Future<List<ExpenseModel>> filteredExpenses(FilteredExpensesRef ref) async {
  final filters = ref.watch(expenseFiltersNotifierProvider);
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
    log.d('Finance: Fetched ${records.length} records for filter: ${filters.type}/${filters.sharing}');
    return records
        .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    log.e('Error fetching filtered expenses: $e');
    return [];
  }
}

@riverpod
Future<List<HouseholdBalanceModel>> expenseBalances(ExpenseBalancesRef ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return [];

  final useCase = ref.watch(getBalancesUseCaseProvider);
  final result = await useCase(householdId);

  return result.fold((_) => [], (r) => r);
}

