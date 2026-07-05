// ─────────────────────────────────────────────────────────────────────────────
// Regression: a finance mutation must NOT throw "Cannot use the Ref ... after it
// has been disposed" when its auto-dispose controller is torn down mid-RPC.
//
// The original bug: `ExpenseController` is invoked via `ref.read(...notifier)`
// (no listener), so it could be auto-disposed while `settleDebt`/`saveExpense`
// was still awaiting the RPC. The post-await `ref.read(isOnlineProvider)` /
// `ref.invalidate(...)` then threw, and the settle surfaced as a failure even
// though the row was already written. The fix guards that tail with
// `ref.mounted`. This test drives that exact race.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';

/// Repository whose `settleDebt` can be paused mid-call so the test can dispose
/// the controller while the RPC is in flight. All read methods return benign
/// values so the controller's `build()` never interferes.
class _GatedExpenseRepository implements ExpenseRepository {
  _GatedExpenseRepository({this.onSettleEntered, this.settleGate});

  /// Completes as soon as `settleDebt` is entered (RPC "in flight").
  final Completer<void>? onSettleEntered;

  /// If set, `settleDebt` awaits this before returning — lets the test interleave
  /// a disposal between "entered" and "returned".
  final Future<void>? settleGate;

  int settleCalls = 0;

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String requestId,
  }) async {
    settleCalls++;
    onSettleEntered?.complete();
    if (settleGate != null) await settleGate;
    return const Right<Failure, void>(null);
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
    String householdId,
  ) async =>
      const Right([]);

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError(
        'Unexpected repo call: ${invocation.memberName}',
      );

  // Explicit no-op stubs for the rest of the interface so `implements` is
  // satisfied without each becoming a noSuchMethod surprise if build() touches
  // them. They are not exercised by these tests.
  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
          String householdId,) async =>
      const Right([]);
  @override
  Future<Either<Failure, String>> getHouseholdId(String userId) async =>
      const Right('h1');
  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
          String expenseId,) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, void>> saveExpense({
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
    String? receiptPath,
  }) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, void>> deleteExpense(String id) =>
      throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> getPersonalFinanceSummary(
          String userId, String householdId,) async =>
      {'balance': 0.0, 'income': 0.0, 'expense': 0.0, 'variation': 0.0};
  @override
  Future<Either<Failure, List<FeedItemModel>>> getCombinedFeed(
          String householdId,) async =>
      const Right([]);
  @override
  Future<Either<Failure, List<ExpenseTemplateModel>>> getTemplates(
          String householdId,) async =>
      const Right([]);
  @override
  Future<Either<Failure, Unit>> saveTemplate(ExpenseTemplateModel template) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> toggleTemplateActivity(String id, bool active) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Map<String, dynamic>>> payPlannedExpense({
    required String plannedId,
    required double amount,
    required DateTime paidAt,
    required String paidBy,
  }) =>
      throw UnimplementedError();
  @override
  Future<Either<Failure, Unit>> processRecurringExpenses(
          String householdId,) async =>
      const Right(unit);
  @override
  Future<Either<Failure, List<FeedItemModel>>> getMonthlyPendingPlannedExpenses(
          String householdId, {required DateTime month,}) async =>
      const Right([]);
  @override
  Future<Either<Failure, Unit>> deletePlannedExpense(String id) =>
      throw UnimplementedError();
}

void main() {
  test(
      'settleDebt completes (no Ref-after-dispose) when the controller is '
      'disposed mid-RPC', () async {
    final entered = Completer<void>();
    final gate = Completer<void>();
    final repo = _GatedExpenseRepository(
      onSettleEntered: entered,
      settleGate: gate.future,
    );

    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repo),
        householdIdProvider.overrideWith((ref) => 'h1'),
        isOnlineProvider.overrideWith((ref) => true),
      ],
    );
    addTearDown(container.dispose);

    // Keep the auto-dispose provider alive via a single listener, then grab the
    // live notifier.
    final sub = container.listen(expenseControllerProvider, (_, __) {});
    final notifier = container.read(expenseControllerProvider.notifier);

    final future = notifier.settleDebt(
      fromUserId: 'user-a',
      toUserId: 'user-b',
      amount: 100,
      requestId: 'req-1',
    );

    // Wait until we're inside the RPC, then remove the ONLY listener so the
    // auto-dispose controller is fully torn down (its Ref unmounted) while the
    // RPC is still in flight — the exact race that used to throw on the
    // post-await ref.read(isOnlineProvider) / ref.invalidate(...).
    await entered.future;
    sub.close();
    await container.pump();

    // Let the RPC finish; the ref.mounted guard must let this complete cleanly.
    gate.complete();
    await expectLater(future, completes);
    expect(repo.settleCalls, 1);
  });

  test('settleDebt completes normally when the controller stays mounted',
      () async {
    final repo = _GatedExpenseRepository();
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repo),
        householdIdProvider.overrideWith((ref) => 'h1'),
        isOnlineProvider.overrideWith((ref) => true),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen(expenseControllerProvider, (_, __) {});
    addTearDown(sub.close);
    final notifier = container.read(expenseControllerProvider.notifier);

    await expectLater(
      notifier.settleDebt(
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100,
        requestId: 'req-2',
      ),
      completes,
    );
    expect(repo.settleCalls, 1);
  });
}
