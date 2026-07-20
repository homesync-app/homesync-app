import 'dart:async';

import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/performance_monitor.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/supabase_expense_repository.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/expense_template_model.dart';
import '../../domain/models/feed_item_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/get_balances_usecase.dart';
import '../../domain/usecases/get_combined_feed_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/get_personal_finance_summary_usecase.dart';

part 'expense_provider.g.dart';

// --- Providers ---

// keepAlive: the repository holds onto its [Ref] and reads it after async
// gaps (online checks, admin-testing flags, analytics, currentUserId — see
// SupabaseExpenseRepository). As an auto-dispose provider it was torn down
// the instant a caller's `ref.read` returned and the home view invalidated
// sibling providers, so an in-flight saveExpense/settleDebt RPC would resume
// after its await and throw "Cannot use the Ref ... after it has been
// disposed" — surfacing as a failed settle even though the row was written.
@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseExpenseRepository(client, ref);
}

@riverpod
GetExpensesUseCase getExpensesUseCase(Ref ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetExpensesUseCase(repo);
}

@riverpod
GetCombinedFeedUseCase getCombinedFeedUseCase(Ref ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetCombinedFeedUseCase(repo);
}

@riverpod
GetBalancesUseCase getBalancesUseCase(Ref ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return GetBalancesUseCase(repo);
}

@riverpod
GetPersonalFinanceSummaryUseCase getPersonalFinanceSummaryUseCase(
  Ref ref,
) {
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

@Riverpod(keepAlive: true)
class ExpenseBalances extends _$ExpenseBalances {
  @override
  Future<List<HouseholdBalanceModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final bootstrap = await ref.watch(homeBootstrapProvider.future);
    if (bootstrap?.householdId == householdId &&
        BootstrapSeedGate.instance.consume(BootstrapSection.expenseBalances)) {
      return bootstrap!.expenseBalances
          .map(HouseholdBalanceModel.fromJson)
          .toList(growable: false);
    }

    final useCase = ref.watch(getBalancesUseCaseProvider);
    final result = await PerformanceMonitor.measureFuture(
      'provider.expense_balances',
      () => useCase(householdId),
      context: {'householdId': householdId},
      warnAfterMs: 900,
    );
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
    final result = await PerformanceMonitor.measureFuture(
      'provider.expense_controller.initial_expenses',
      () => useCase(householdId),
      context: {'householdId': householdId},
      warnAfterMs: 900,
    );
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
    String? poolId,
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
      poolId: poolId,
    );

    if (result.isLeft()) {
      final failure = result.getLeft().toNullable()!;
      log.w('Save expense failed: ${failure.message}');
      throw failure;
    }

    // The write already succeeded above; the cache refresh below is best-effort.
    // Guard `ref` because this auto-dispose controller can be torn down during
    // the await (a caller's `ref.read` keeps no listener), and touching a
    // disposed Ref throws "Cannot use the Ref ... after it has been disposed".
    if (ref.mounted && ref.read(isOnlineProvider)) {
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(combinedFeedControllerProvider);
      ref.invalidate(recentActivityRemoteProvider);
    }
  }

  Future<void> deleteExpense(String id) async {
    final previousExpenses = state.value;
    final combinedFeedNotifier =
        ref.read(combinedFeedControllerProvider.notifier);
    final previousFeed = ref.read(combinedFeedControllerProvider).value;
    final hiddenExpenseIds = ref.read(hiddenRecentExpenseIdsProvider.notifier);

    if (previousExpenses != null) {
      state = AsyncData(
        previousExpenses.where((expense) => expense.id != id).toList(),
      );
    }
    combinedFeedNotifier.removeRealExpenseLocally(id);
    hiddenExpenseIds.hide(id);

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
        hiddenExpenseIds.restore(id);
        throw failure;
      },
      (_) {},
    );

    if (ref.mounted && ref.read(isOnlineProvider)) {
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(combinedFeedControllerProvider);
      ref.invalidate(recentActivityRemoteProvider);
    }
  }

  Future<void> settleDebt({
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? requestId,
    String? poolId,
  }) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final repo = ref.read(expenseRepositoryProvider);
    // The idempotency key must be minted ONCE per settlement intent and reused
    // across retries (otherwise a retry after an ambiguous timeout creates a
    // duplicate settlement). Callers that can retry must pass a stable
    // [requestId]; we only mint a fresh one as a fallback for one-shot callers.
    final effectiveRequestId = requestId ?? const Uuid().v4();
    final result = await repo.settleDebt(
      householdId: householdId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
      requestId: effectiveRequestId,
      poolId: poolId,
    );

    result.fold(
      (failure) {
        log.w('Settle debt failed: ${failure.message}');
        throw failure;
      },
      (_) {},
    );

    // The settlement row is already written; this cache refresh is best-effort.
    // `ref.mounted` guards against the controller being auto-disposed during the
    // RPC await — otherwise the tail throws "Cannot use the Ref ... after it has
    // been disposed" and the settle surfaces as failed even though it succeeded.
    if (ref.mounted && ref.read(isOnlineProvider)) {
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(combinedFeedControllerProvider);
      ref.invalidate(recentActivityRemoteProvider);
    }
  }
}

@riverpod
class CombinedFeedController extends _$CombinedFeedController {
  @override
  Future<List<FeedItemModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final repo = ref.watch(expenseRepositoryProvider);
    unawaited(_processRecurringExpensesInBackground(repo, householdId));

    final bootstrap = await ref.watch(homeBootstrapProvider.future);
    if (bootstrap?.householdId == householdId &&
        BootstrapSeedGate.instance.consume(BootstrapSection.combinedFeed)) {
      return bootstrap!.combinedFeed
          .map(FeedItemModel.fromJson)
          .toList(growable: false);
    }

    // Fire-and-forget: recurring expense processing is a DB-writing RPC that
    // takes ~700ms on cold start. Awaiting it blocked the feed query behind it
    // and added roughly a second to TTI. We still throttle it to once every
    // 24h via SharedPreferences, but let the feed load in parallel and refresh
    // itself if new rows land.
    final useCase = ref.watch(getCombinedFeedUseCaseProvider);
    final result = await PerformanceMonitor.measureFuture(
      'provider.combined_feed',
      () => useCase(householdId),
      context: {'householdId': householdId},
      warnAfterMs: 900,
    );
    return result.fold(
      (failure) {
        log.w('CombinedFeed build failed: ${failure.message}');
        throw failure;
      },
      (feed) => feed,
    );
  }

  Future<void> _processRecurringExpensesInBackground(
    ExpenseRepository repo,
    String householdId,
  ) async {
    try {
      final now = DateTime.now();
      final storageKey = 'homesync_last_recurring_run_$householdId';
      final prefs = await SharedPreferences.getInstance();
      final lastRunStr = prefs.getString(storageKey);
      final lastRun = lastRunStr != null ? DateTime.tryParse(lastRunStr) : null;
      final shouldRun =
          lastRun == null || now.difference(lastRun).inHours >= 24;
      if (!shouldRun) return;
      await repo.processRecurringExpenses(householdId);
      await prefs.setString(storageKey, now.toIso8601String());
      if (!ref.mounted) return;
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(monthlyPendingPlannedExpensesProvider);
      ref.invalidate(recentActivityRemoteProvider);
      ref.invalidateSelf();
    } catch (e, stack) {
      log.w(
        'CombinedFeed recurring expense processing failed: $e',
        error: e,
        stackTrace: stack,
      );
    }
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
        // El pago ya está escrito; el refresh es best-effort. `ref.mounted`
        // protege contra el auto-dispose del controller durante el await del
        // RPC (mismo patrón que ExpenseController.settleDebt).
        if (ref.mounted && ref.read(isOnlineProvider)) {
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidate(personalFinanceSummaryProvider);
          ref.invalidate(recentActivityRemoteProvider);
          // El pago crea un gasto real con splits: la deuda entre miembros
          // cambia y el widget de división del Inicio debe reflejarlo.
          ref.invalidate(expenseBalancesProvider);
          ref.invalidateSelf();
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
        if (ref.mounted && ref.read(isOnlineProvider)) {
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidateSelf();
        }
      },
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  void removeRealExpenseLocally(String expenseId) {
    final currentFeed = state.value;
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

    await result.fold(
      (l) {
        log.w('Save template failed: ${l.message}');
        throw l;
      },
      (r) async {
        if (!ref.mounted) return;
        final householdId = await ref.read(householdIdProvider.future);
        if (householdId != null) {
          await repo.processRecurringExpenses(householdId);
        }
        if (ref.mounted && ref.read(isOnlineProvider)) {
          ref.invalidate(combinedFeedControllerProvider);
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidate(personalFinanceSummaryProvider);
          ref.invalidateSelf();
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
        if (ref.mounted && ref.read(isOnlineProvider)) {
          ref.invalidate(combinedFeedControllerProvider);
          ref.invalidate(monthlyPendingPlannedExpensesProvider);
          ref.invalidateSelf();
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

/// Parte del usuario en un movimiento pendiente: personal/gift completos solo
/// para su payer; el resto respeta el ratio anclado del hogar cuando reparten
/// exactamente dos (mismo criterio que ExpenseSplitBuilder) y partes iguales
/// si no. Quien no reparte (p. ej. un teen en familia) no tiene parte.
double _projectedShareForUser({
  required FeedItemModel item,
  required String userId,
  required List<String> splitMemberIds,
  required double defaultRatio,
  required String? anchorId,
}) {
  final splitType = (item.splitType ?? 'equal').toLowerCase();

  if (splitType == 'personal' || splitType == 'gift') {
    return item.payerId == userId ? item.amount : 0.0;
  }

  // Miembros aún no cargados: mostrar el monto completo es menos engañoso que
  // inventar una división (y en solo-mode el único adulto ES el total).
  if (splitMemberIds.isEmpty) return item.amount;
  if (!splitMemberIds.contains(userId)) return 0.0;

  if (splitMemberIds.length == 2 &&
      defaultRatio != 0.5 &&
      anchorId != null &&
      splitMemberIds.contains(anchorId)) {
    return item.amount * (userId == anchorId ? defaultRatio : 1.0 - defaultRatio);
  }

  return item.amount / splitMemberIds.length;
}

@riverpod
Future<List<FeedItemModel>> monthlyPendingPlannedExpenses(
  Ref ref,
) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return const <FeedItemModel>[];

  final repo = ref.watch(expenseRepositoryProvider);
  final processResult = await repo.processRecurringExpenses(householdId);
  processResult.fold(
    (failure) => log.w(
      'Monthly pending recurring processing failed: ${failure.message}',
    ),
    (_) {},
  );

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
  Ref ref,
) async {
  final feedAsync = await ref.watch(combinedFeedControllerProvider.future);
  final monthlyPendingItems =
      await ref.watch(monthlyPendingPlannedExpensesProvider.future);
  final members = await ref.watch(householdMembersProvider.future);
  final household = await ref.watch(currentHouseholdProvider.future);
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return const MonthlyProjectionData(spent: 0, pending: 0);

  double spent = 0.0;
  double pending = 0.0;
  final now = DateTime.now();
  // Rent/bills split between adults only — kids and teens don't share
  // household expenses (mirrors pay_planned_expense's split-member filter).
  // Friends/roommates households have no "kids", everyone splits.
  final isFriendsOrRoommates = const {'friends', 'roommates'}
      .contains(household?.householdType.toLowerCase());
  final splitMembers = isFriendsOrRoommates
      ? members
      : members.where((m) => m.isAdult).toList();
  final splitMemberIds =
      splitMembers.map((m) => m.userId).toList(growable: false);
  // Integrated/shared economy (couple or family): pending planned expenses count
  // in full toward the household rather than being split per member.
  final isSharedEconomy = household?.financeMode == 'shared';

  for (final item in feedAsync) {
    // Only current month
    if (item.date.month != now.month || item.date.year != now.year) continue;

    // "Pagado" cuenta solo GASTOS: un ingreso no es plata gastada y una
    // liquidación duplicaría el gasto original que ya contó (mismo criterio
    // que FamilyFinanceSection).
    if (item.isRealExpense && item.transactionType == 'expense') {
      // "Pagado" shows REAL money that left a wallet, never debts/shares:
      //  - shared (unified) economy: the whole household's spend — both members
      //    see the same figure;
      //  - divided economy: only what the CURRENT user actually paid. When the
      //    partner pays a shared bill it does NOT move "Pagado"; it surfaces as
      //    a debt (per the configured split) in the Inicio/division widget.
      if (isSharedEconomy) {
        spent += item.amount;
      } else if (item.payerId == userId) {
        spent += item.amount;
      }
    }
  }

  for (final item in monthlyPendingItems) {
    // Los planificados de ingreso (sueldo recurrente) no son gasto proyectado.
    if (item.transactionType != 'expense') continue;
    pending += isSharedEconomy
        ? item.amount
        : _projectedShareForUser(
            item: item,
            userId: userId,
            splitMemberIds: splitMemberIds,
            defaultRatio: household?.defaultSplitRatio ?? 0.5,
            anchorId: household?.splitRatioAnchorId,
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

