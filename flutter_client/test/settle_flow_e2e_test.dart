// ─────────────────────────────────────────────────────────────────────────────
// Settle flow integration ("E2E" against a stateful fake backend).
//
// Drives the real ExpenseController + ExpenseBalances providers and their
// invalidation wiring: a household with a negative balance is settled, the
// balance provider must refresh to 0, and a retry with the SAME request_id must
// be idempotent (server resolves to one settlement, not two).
// ─────────────────────────────────────────────────────────────────────────────
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

/// Stateful fake backend: holds the current user's balance and enforces
/// request_id idempotency exactly like `settle_debt_v1`.
class _SettleFakeRepository implements ExpenseRepository {
  _SettleFakeRepository({required this.balance});

  double balance;
  final Set<String> settledRequestIds = {};
  int settleCallCount = 0;

  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
    String householdId,
  ) async =>
      Right([HouseholdBalanceModel(userId: 'me', balance: balance)]);

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String requestId,
  }) async {
    settleCallCount++;
    // New intent → settle once. A repeated request_id is a no-op (idempotent).
    if (settledRequestIds.add(requestId)) {
      balance = 0;
    }
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

  // Benign stubs so the controller's build() can never trip on a noSuchMethod.
  @override
  Future<Either<Failure, String>> getHouseholdId(String userId) async =>
      const Right('h1');
  @override
  Future<Map<String, dynamic>> getPersonalFinanceSummary(
    String userId,
    String householdId,
  ) async =>
      {'balance': 0.0, 'income': 0.0, 'expense': 0.0, 'variation': 0.0};
  @override
  Future<Either<Failure, List<FeedItemModel>>> getCombinedFeed(
    String householdId,
  ) async =>
      const Right([]);
  @override
  Future<Either<Failure, List<ExpenseTemplateModel>>> getTemplates(
    String householdId,
  ) async =>
      const Right([]);
  @override
  Future<Either<Failure, Unit>> processRecurringExpenses(
    String householdId,
  ) async =>
      const Right(unit);
  @override
  Future<Either<Failure, List<FeedItemModel>>> getMonthlyPendingPlannedExpenses(
    String householdId, {
    required DateTime month,
  }) async =>
      const Right([]);
}

void main() {
  test(
      'settling a negative balance refreshes it to 0 and is idempotent on '
      'retry', () async {
    final repo = _SettleFakeRepository(balance: -10000);
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repo),
        householdIdProvider.overrideWith((ref) => 'h1'),
        homeBootstrapProvider.overrideWith((ref) async => null),
        isOnlineProvider.overrideWith((ref) => true),
      ],
    );
    addTearDown(container.dispose);

    // Keep the auto-dispose controller + the balances provider alive for the
    // duration of the flow.
    addTearDown(
      container.listen(expenseControllerProvider, (_, __) {}).close,
    );
    addTearDown(
      container.listen(expenseBalancesProvider, (_, __) {}).close,
    );

    // Starting state: I owe 10.000.
    final before = await container.read(expenseBalancesProvider.future);
    expect(before.single.balance, -10000);

    // Settle.
    const intentKey = 'settle-intent-1';
    await container.read(expenseControllerProvider.notifier).settleDebt(
          fromUserId: 'me',
          toUserId: 'partner',
          amount: 10000,
          requestId: intentKey,
        );

    // settleDebt invalidated expenseBalancesProvider → it refetches the now-0
    // balance from the fake backend.
    final after = await container.read(expenseBalancesProvider.future);
    expect(after.single.balance, 0);
    expect(repo.settleCallCount, 1);

    // Retry the SAME intent (e.g. a double-tap or a retry after a timeout). The
    // server is hit again but resolves to the single existing settlement.
    await container.read(expenseControllerProvider.notifier).settleDebt(
          fromUserId: 'me',
          toUserId: 'partner',
          amount: 10000,
          requestId: intentKey,
        );

    final afterRetry = await container.read(expenseBalancesProvider.future);
    expect(afterRetry.single.balance, 0);
    expect(repo.settleCallCount, 2, reason: 'the retry still calls the server');
    expect(
      repo.settledRequestIds.length,
      1,
      reason: 'but the same request_id maps to exactly one settlement',
    );
  });
}
