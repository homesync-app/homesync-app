import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/supabase_expense_repository.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/get_balances_usecase.dart';
import '../../domain/usecases/get_personal_finance_summary_usecase.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

part 'expense_provider.g.dart';

// --- Providers ---

@riverpod
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
GetPersonalFinanceSummaryUseCase getPersonalFinanceSummaryUseCase(GetPersonalFinanceSummaryUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetPersonalFinanceSummaryUseCase(repo);
}

@riverpod
class PersonalFinanceSummary extends _$PersonalFinanceSummary {
  @override
  Future<Map<String, dynamic>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    final userId = ref.read(currentUserIdProvider);
    if (householdId == null || userId == null) return {};

    final useCase = ref.watch(getPersonalFinanceSummaryUseCaseProvider);
    return useCase(userId: userId, householdId: householdId);
  }
}

@riverpod
class ExpenseBalances extends _$ExpenseBalances {
  @override
  Future<List<HouseholdBalanceModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final useCase = ref.watch(getBalancesUseCaseProvider);
    final result = await useCase(householdId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (balances) => balances,
    );
  }
}

@riverpod
class ExpenseController extends _$ExpenseController {
  @override
  Future<List<ExpenseModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final useCase = ref.watch(getExpensesUseCaseProvider);
    final result = await useCase(householdId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (expenses) => expenses,
    );
  }

  Future<void> saveExpense({
    String? id,
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
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final repo = ref.read(expenseRepositoryProvider);
    await repo.saveExpense(
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
    
    ref.invalidateSelf();
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(personalFinanceSummaryProvider);
  }

  Future<void> deleteExpense(String id) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.deleteExpense(id);
    
    ref.invalidateSelf();
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(personalFinanceSummaryProvider);
  }

  Future<void> settleDebt({
    required String toUserId,
    required double amount,
  }) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final repo = ref.read(expenseRepositoryProvider);
    await repo.settleDebt(
      householdId: householdId,
      toUserId: toUserId,
      amount: amount,
    );
    
    ref.invalidateSelf();
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(personalFinanceSummaryProvider);
  }
}

@riverpod
class ExpenseFiltersNotifier extends _$ExpenseFiltersNotifier {
  @override
  Map<String, dynamic> build() => {'category': 'all'};

  void setCategory(String category) {
    state = {...state, 'category': category};
  }
}

@riverpod
class MercadopagoMovements extends _$MercadopagoMovements {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    // Basic stub for movements
    return [];
  }
}
