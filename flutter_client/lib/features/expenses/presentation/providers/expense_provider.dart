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
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';

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
GetPersonalFinanceSummaryUseCase getPersonalFinanceSummaryUseCase(
    GetPersonalFinanceSummaryUseCaseRef ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetPersonalFinanceSummaryUseCase(repo);
}

@riverpod
class PersonalFinanceSummary extends _$PersonalFinanceSummary {
  @override
  Future<Map<String, dynamic>> build() async {
    final userId = ref.read(currentUserIdProvider);
    final householdId = await ref.watch(householdIdProvider.future);
    if (userId == null || householdId == null) {
      return {
        'balance': 0.0,
        'income': 0.0,
        'expense': 0.0,
        'variation': 0.0,
      };
    }

    final useCase = ref.watch(getPersonalFinanceSummaryUseCaseProvider);
    return await useCase(userId: userId, householdId: householdId);
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
      (failure) => throw failure,
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
      (failure) => throw failure,
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
    final result = await repo.saveExpense(
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

    if (result.isLeft()) {
      final failure = result.getLeft().toNullable()!;
      log.w('Save expense failed: ${failure.message}');
      throw failure;
    }

    if (ref.read(isOnlineProvider)) {
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(combinedFeedControllerProvider);
      ref.invalidate(recentActivityProvider);
    }
  }

  Future<void> deleteExpense(String id) async {
    final previousExpenses = state.valueOrNull;
    final combinedFeedNotifier =
        ref.read(combinedFeedControllerProvider.notifier);
    final previousFeed = ref.read(combinedFeedControllerProvider).valueOrNull;

    if (previousExpenses != null) {
      state = AsyncData(
        previousExpenses.where((expense) => expense.id != id).toList(),
      );
    }
    combinedFeedNotifier.removeRealExpenseLocally(id);

    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.deleteExpense(id);

    result.fold(
      (failure) {
        log.w('Delete expense failed: ${failure.message}');
        if (previousExpenses != null) {
          state = AsyncData(previousExpenses);
        }
        if (previousFeed != null) {
          combinedFeedNotifier.replaceLocalFeed(previousFeed);
        }
        throw failure;
      },
      (_) {},
    );

    if (ref.read(isOnlineProvider)) {
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(combinedFeedControllerProvider);
      ref.invalidate(recentActivityProvider);
    }
  }

  Future<void> settleDebt({
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.settleDebt(
      householdId: householdId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
    );

    result.fold(
      (failure) {
        log.w('Settle debt failed: ${failure.message}');
        throw failure;
      },
      (_) {},
    );
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
    } catch (e, stack) {
      // Ignore background processing errors to not block the feed
      log.w(
        'CombinedFeed recurring expense processing failed: $e',
        error: e,
        stackTrace: stack,
      );
    }

    final useCase = ref.watch(getCombinedFeedUseCaseProvider);
    final result = await useCase(householdId);
    return result.fold(
      (failure) {
        log.w('CombinedFeed build failed: ${failure.message}');
        throw failure;
      },
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
      (l) {
        log.w('Pay planned expense failed: ${l.message}');
        throw l;
      },
      (r) {
        if (ref.read(isOnlineProvider)) {
          ref.invalidateSelf();
          ref.invalidate(combinedFeedControllerProvider);
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidate(monthlyProjectionProvider);
          ref.invalidate(personalFinanceSummaryProvider);
          ref.invalidate(recentActivityProvider);
        }
        return r;
      },
    );
  }

  Future<void> discardPlannedExpense(String id) async {
    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.deletePlannedExpense(id);
    result.fold(
      (l) {
        log.w('Discard planned expense failed: ${l.message}');
        throw l;
      },
      (r) {
        if (ref.read(isOnlineProvider)) {
          ref.invalidateSelf();
          ref.invalidate(combinedFeedControllerProvider);
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidate(monthlyProjectionProvider);
        }
      },
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  void removeRealExpenseLocally(String expenseId) {
    final currentFeed = state.valueOrNull;
    if (currentFeed == null) return;

    state = AsyncData(
      currentFeed
          .where((item) => !(item.isRealExpense && item.id == expenseId))
          .toList(),
    );
  }

  void replaceLocalFeed(List<FeedItemModel> feed) {
    state = AsyncData(feed);
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
      (failure) {
        log.w('ExpenseTemplateController build failed: ${failure.message}');
        throw failure;
      },
      (templates) => templates,
    );
  }

  Future<void> saveTemplate(ExpenseTemplateModel template) async {
    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.saveTemplate(template);

    result.fold(
      (l) {
        log.w('Save template failed: ${l.message}');
        throw l;
      },
      (r) {
        if (ref.read(isOnlineProvider)) {
          ref.invalidateSelf();
          ref.invalidate(combinedFeedControllerProvider);
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidate(monthlyProjectionProvider);
        }
      },
    );
  }

  Future<void> deleteTemplate(String id) async {
    final repo = ref.read(expenseRepositoryProvider);
    final result = await repo.toggleTemplateActivity(id, false);

    result.fold(
      (l) {
        log.w('Delete template failed: ${l.message}');
        throw l;
      },
      (r) {
        if (ref.read(isOnlineProvider)) {
          ref.invalidateSelf();
          ref.invalidate(combinedFeedControllerProvider);
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidate(monthlyProjectionProvider);
        }
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

double _projectedShareForUser({
  required FeedItemModel item,
  required String userId,
  required int memberCount,
}) {
  final splitType = (item.splitType ?? 'equal').toLowerCase();

  if (splitType == 'personal' || splitType == 'gift') {
    return item.payerId == userId ? item.amount : 0.0;
  }

  final safeMemberCount = memberCount > 0 ? memberCount : 2;
  return item.amount / safeMemberCount;
}

@riverpod
Future<List<FeedItemModel>> monthlyPendingPlannedExpenses(
    MonthlyPendingPlannedExpensesRef ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return const <FeedItemModel>[];

  final repo = ref.watch(expenseRepositoryProvider);
  final result = await repo.getMonthlyPendingPlannedExpenses(
    householdId,
    month: DateTime.now(),
  );

  return result.fold(
    (failure) {
      log.w('Monthly pending planned expenses failed: ${failure.message}');
      throw failure;
    },
    (items) => items,
  );
}

@riverpod
Future<MonthlyProjectionData> monthlyProjection(
    MonthlyProjectionRef ref) async {
  final feedAsync = await ref.watch(combinedFeedControllerProvider.future);
  final monthlyPendingItems =
      await ref.watch(monthlyPendingPlannedExpensesProvider.future);
  final members = await ref.watch(householdMembersProvider.future);
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return const MonthlyProjectionData(spent: 0, pending: 0);

  double spent = 0.0;
  double pending = 0.0;
  final now = DateTime.now();
  final memberCount = members.isNotEmpty ? members.length : 2;

  for (final item in feedAsync) {
    // Only current month
    if (item.date.month != now.month || item.date.year != now.year) continue;

    if (item.isRealExpense) {
      // For real expenses, we estimate user's cashflow impact.
      // If the user paid it, it counts as "spent" from their wallet.
      if (item.payerId == userId) {
        spent += item.amount;
      }
    }
  }

  for (final item in monthlyPendingItems) {
    pending += _projectedShareForUser(
      item: item,
      userId: userId,
      memberCount: memberCount,
    );
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
