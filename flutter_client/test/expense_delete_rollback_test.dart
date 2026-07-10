// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — Expense delete optimistic-rollback tests
//
// Guards the highest-severity financial path that had no coverage: the
// optimistic delete in [ExpenseController.deleteExpense]. The notifier removes
// the expense from THREE mirrors before the server confirms (the expense list,
// the combined feed, and the hidden-id set used by recent activity). If the
// repo call fails, all three MUST be restored and the failure rethrown —
// otherwise a user sees an expense "disappear" from the UI while it still lives
// in the database, the exact kind of silent financial bug we cannot ship.
//
// These run against the REAL ExpenseController/CombinedFeedController wired
// through Riverpod (only the repository and environment are faked), unlike the
// hand-rolled simulator in expense_e2e_test.dart.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _householdId = 'h1';

ExpenseModel _expense(String id, {double amount = 100.0}) => ExpenseModel(
      id: id,
      title: 'Expense $id',
      amount: amount,
      category: 'food',
      householdId: _householdId,
      paidBy: 'user-1',
      paidAt: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
    );

FeedItemModel _feedItem(String id, {double amount = 100.0}) => FeedItemModel(
      recordType: 'expense', // makes isRealExpense true → eligible for removal
      transactionType: 'expense',
      id: id,
      title: 'Expense $id',
      amount: amount,
      payerId: 'user-1',
      date: DateTime(2026, 1, 1),
      status: 'paid',
    );

/// Fake repo seeded with two expenses. [failDelete] forces the delete RPC to
/// return a Left so we can assert the rollback path.
class _FakeExpenseRepository implements ExpenseRepository {
  _FakeExpenseRepository({required this.failDelete});

  final bool failDelete;
  final List<ExpenseModel> _expenses = [_expense('e1'), _expense('e2')];
  final List<String> deleteCalls = [];

  @override
  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
    String householdId,
  ) async =>
      Right(List.of(_expenses));

  @override
  Future<Either<Failure, List<FeedItemModel>>> getCombinedFeed(
    String householdId,
  ) async =>
      Right([_feedItem('e1'), _feedItem('e2')]);

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    deleteCalls.add(id);
    if (failDelete) {
      return const Left(ServerFailure('delete boom'));
    }
    _expenses.removeWhere((e) => e.id == id);
    return const Right(null);
  }

  // ── Collaborators touched during build / background work ──────────────────
  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
    String householdId,
  ) async =>
      const Right([]);

  @override
  Future<Either<Failure, Unit>> processRecurringExpenses(
    String householdId,
  ) async =>
      const Right(unit);

  @override
  Future<Either<Failure, String>> getHouseholdId(String userId) async =>
      const Right(_householdId);

  @override
  Future<Map<String, dynamic>> getPersonalFinanceSummary(
    String userId,
    String householdId,
  ) async =>
      {'balance': 0.0, 'income': 0.0, 'expense': 0.0, 'variation': 0.0};

  // ── Unused by this flow ───────────────────────────────────────────────────
  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
    String expenseId,
  ) async =>
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
    String? poolId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String requestId,
    String? poolId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<ExpenseTemplateModel>>> getTemplates(
    String householdId,
  ) async =>
      const Right([]);

  @override
  Future<Either<Failure, Unit>> saveTemplate(
    ExpenseTemplateModel template,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> toggleTemplateActivity(
    String id,
    bool active,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Map<String, dynamic>>> payPlannedExpense({
    required String plannedId,
    required double amount,
    required DateTime paidAt,
    required String paidBy,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<FeedItemModel>>> getMonthlyPendingPlannedExpenses(
    String householdId, {
    required DateTime month,
  }) async =>
      const Right([]);

  @override
  Future<Either<Failure, Unit>> deletePlannedExpense(String id) async =>
      throw UnimplementedError();
}

Future<ProviderContainer> _bootContainer(_FakeExpenseRepository repo) async {
  final container = ProviderContainer(
    overrides: [
      expenseRepositoryProvider.overrideWithValue(repo),
      householdIdProvider.overrideWith((ref) => _householdId),
      homeBootstrapProvider.overrideWith((ref) async => null),
      // Keep the delete path focused: offline skips the downstream
      // invalidations that would otherwise re-fetch and muddy assertions.
      isOnlineProvider.overrideWith((ref) => false),
    ],
  );
  addTearDown(container.dispose);

  // Load both mirrors so deleteExpense captures real "previous" snapshots.
  await container.read(expenseControllerProvider.future);
  await container.read(combinedFeedControllerProvider.future);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // A recent "last run" timestamp makes CombinedFeedController's fire-and-
    // forget recurring-expense job no-op, so it never invalidates the feed
    // mid-test and makes assertions flaky.
    SharedPreferences.setMockInitialValues({
      'homesync_last_recurring_run_$_householdId':
          DateTime.now().toIso8601String(),
    });
  });

  group('ExpenseController.deleteExpense', () {
    test('successful delete removes the expense from every mirror', () async {
      final repo = _FakeExpenseRepository(failDelete: false);
      final container = await _bootContainer(repo);

      await container
          .read(expenseControllerProvider.notifier)
          .deleteExpense('e1');

      final expenses = container.read(expenseControllerProvider).requireValue;
      final feed = container.read(combinedFeedControllerProvider).requireValue;
      final hidden = container.read(hiddenRecentExpenseIdsProvider);

      expect(expenses.map((e) => e.id), ['e2']);
      expect(feed.map((f) => f.id), ['e2']);
      expect(hidden, contains('e1'));
      expect(repo.deleteCalls, ['e1']);
    });

    test('failed delete rolls back all three mirrors and rethrows', () async {
      final repo = _FakeExpenseRepository(failDelete: true);
      final container = await _bootContainer(repo);

      await expectLater(
        container.read(expenseControllerProvider.notifier).deleteExpense('e1'),
        throwsA(isA<ServerFailure>()),
      );

      final expenses = container.read(expenseControllerProvider).requireValue;
      final feed = container.read(combinedFeedControllerProvider).requireValue;
      final hidden = container.read(hiddenRecentExpenseIdsProvider);

      // List restored to its pre-delete contents.
      expect(expenses.map((e) => e.id), ['e1', 'e2']);
      // Feed restored — e1 must reappear.
      expect(feed.map((f) => f.id), ['e1', 'e2']);
      // Hidden-id set restored — e1 must NOT stay hidden, or it vanishes from
      // recent activity despite the server still holding it.
      expect(hidden, isNot(contains('e1')));
      // The server WAS asked to delete (the optimistic update was real).
      expect(repo.deleteCalls, ['e1']);
    });
  });
}
