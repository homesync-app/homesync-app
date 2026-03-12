import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/supabase_expense_repository.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/get_combined_feed_usecase.dart';
import '../../domain/usecases/get_balances_usecase.dart';
import '../../domain/usecases/get_personal_finance_summary_usecase.dart';
import '../../domain/models/feed_item_model.dart';
import '../../domain/models/expense_template_model.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';

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
GetCombinedFeedUseCase getCombinedFeedUseCase(GetCombinedFeedUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetCombinedFeedUseCase(repo);
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
    final expenses = await ref.watch(expenseControllerProvider.future);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return {'balance': 0.0, 'income': 0.0, 'expense': 0.0, 'variation': 0.0};

    final now = DateTime.now();
    double income = 0;
    double expense = 0;
    
    for (final e in expenses) {
      // Filter for current month
      if (e.paidAt.month != now.month || e.paidAt.year != now.year) continue;

      if (e.type == 'income') {
        if (e.paidBy == userId) income += e.amount;
      } else if (e.type == 'expense') {
        if (e.paidBy == userId) expense += e.amount;
      } else if (e.type == 'settlement') {
        if (e.paidBy == userId) {
          // I paid my partner, money goes OUT
          expense += e.amount;
        } else {
          // Partner paid me, money comes IN (this assumes settlements have splits/info about receiver)
          // In our settlement logic, if I didn't pay it, I am the one receiving it.
          income += e.amount;
        }
      }
    }

    return {
      'balance': income - expense,
      'income': income,
      'expense': expense,
      'variation': 5.0, // Mock for now, could be calculated vs last month
    };
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
    
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(combinedFeedControllerProvider);
    ref.invalidate(recentActivityProvider);
  }

  Future<void> deleteExpense(String id) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.deleteExpense(id);
    
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(combinedFeedControllerProvider);
    ref.invalidate(recentActivityProvider);
  }

  Future<void> settleDebt({
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final repo = ref.read(expenseRepositoryProvider);
    await repo.settleDebt(
      householdId: householdId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
    );
    
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(combinedFeedControllerProvider);
    // Note: Do not invalidateSelf() here to avoid CircularDependencyError if this is called from within the same family or branch of providers
  }
}

@riverpod
class CombinedFeedController extends _$CombinedFeedController {
  @override
  Future<List<FeedItemModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final repo = ref.watch(expenseRepositoryProvider);
    try {
      await repo.processRecurringExpenses(householdId);
    } catch (e) {
      // Ignore background processing errors to not block the feed
    }

    final useCase = ref.watch(getCombinedFeedUseCaseProvider);
    final result = await useCase(householdId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (feed) => feed,
    );
  }

  Future<Map<String, dynamic>> payPlannedExpense({
    required String plannedId,
    required double amount,
    required DateTime paidAt,
    required String paidBy,
  }) async {
    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.payPlannedExpense(
      plannedId: plannedId,
      amount: amount,
      paidAt: paidAt,
      paidBy: paidBy,
    );

    return result.fold(
      (l) => throw Exception(l.message),
      (r) {
        ref.invalidateSelf();
        ref.invalidate(combinedFeedControllerProvider);
        ref.invalidate(monthlyProjectionProvider);
        ref.invalidate(personalFinanceSummaryProvider);
        ref.invalidate(recentActivityProvider);
        return r;
      },
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class ExpenseTemplateController extends _$ExpenseTemplateController {
  @override
  Future<List<ExpenseTemplateModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final repo = ref.watch(expenseRepositoryProvider);
    final result = await repo.getTemplates(householdId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (templates) => templates,
    );
  }

  Future<void> saveTemplate(ExpenseTemplateModel template) async {
    final repo = ref.watch(expenseRepositoryProvider);
    final result = await repo.saveTemplate(template);
    
    result.fold(
      (l) => throw Exception(l.message),
      (r) {
        ref.invalidateSelf();
        // Generar feed de nuevo porque puede afectar proyecciones
        ref.invalidate(combinedFeedControllerProvider);
        ref.invalidate(monthlyProjectionProvider);
      },
    );
  }

  Future<void> deleteTemplate(String id) async {
    final repo = ref.watch(expenseRepositoryProvider);
    final result = await repo.toggleTemplateActivity(id, false);
    
    result.fold(
      (l) => throw Exception(l.message),
      (r) {
        ref.invalidateSelf();
        ref.invalidate(combinedFeedControllerProvider);
        ref.invalidate(monthlyProjectionProvider);
      },
    );
  }
}

class MonthlyProjectionData {
  final double spent;
  final double pending;
  double get total => spent + pending;
  const MonthlyProjectionData({required this.spent, required this.pending});
}

@riverpod
Future<MonthlyProjectionData> monthlyProjection(MonthlyProjectionRef ref) async {
  final feedAsync = await ref.watch(combinedFeedControllerProvider.future);
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return const MonthlyProjectionData(spent: 0, pending: 0);

  double spent = 0.0;
  double pending = 0.0;
  final now = DateTime.now();

  for (final item in feedAsync) {
    // Only current month
    if (item.date.month != now.month || item.date.year != now.year) continue;

    if (item.isRealExpense) {
      // For real expenses, we estimate user's cashflow impact.
      // If the user paid it, it counts as "spent" from their wallet.
      if (item.payerId == userId) {
        spent += item.amount;
      }
    } else if (item.isPlanned && item.status == 'pending') {
      // For planned expenses, if the user is the default payer, it counts as "pending cashflow".
      if (item.payerId == userId) {
        pending += item.amount;
      }
    }
  }

  return MonthlyProjectionData(spent: spent, pending: pending);
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
