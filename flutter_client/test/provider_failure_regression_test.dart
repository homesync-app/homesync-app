import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_template_model.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FailingExpenseRepository implements ExpenseRepository {
  @override
  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
    String householdId,
  ) async =>
      const Left(ServerFailure('expense repo boom'));

  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
    String householdId,
  ) async =>
      const Right([]);

  @override
  Future<Either<Failure, String>> getHouseholdId(String userId) async =>
      const Right('h1');

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
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async =>
      throw UnimplementedError();

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

  @override
  Future<Either<Failure, Unit>> deletePlannedExpense(String id) async =>
      throw UnimplementedError();
}

class _FailingShoppingRepository implements ShoppingRepository {
  @override
  Future<Either<Failure, List<ShoppingItemModel>>> fetchItems(
    String householdId,
  ) async =>
      const Left(ServerFailure('shopping repo boom'));

  @override
  Future<Either<Failure, ShoppingItemModel>> addItem({
    required String householdId,
    required String name,
    required String userId,
    String? clientId,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
    bool shouldSync = true,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> clearCompleted(String householdId) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> uncompleteAll(String householdId) async =>
      throw UnimplementedError();
}

class _FailingSavingsRepository implements SavingsRepository {
  @override
  Future<Either<Failure, List<SavingsGoalModel>>> getGoals({
    required String householdId,
    int? limit,
    int? offset,
  }) async =>
      const Left(ServerFailure('savings repo boom'));

  @override
  Future<Either<Failure, List<SavingsContributionModel>>> getGoalContributions({
    required String goalId,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteGoal({required String goalId}) async =>
      throw UnimplementedError();
}

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  RealtimeChannel channel(String name,
          {RealtimeChannelConfig opts = const RealtimeChannelConfig()}) =>
      _FakeRealtimeChannel();
}

class _FakeRealtimeChannel extends Fake implements RealtimeChannel {
  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    dynamic filter,
    required void Function(PostgresChangePayload payload) callback,
  }) =>
      this;

  @override
  RealtimeChannel subscribe(
          [void Function(RealtimeSubscribeStatus status, Object? error)?
              callback,
          Duration? timeout]) =>
      this;

  @override
  Future<String> unsubscribe([Duration? timeout]) async => 'ok';
}

void main() {
  test('expenseControllerProvider exposes ServerFailure as provider error',
      () async {
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(_FailingExpenseRepository()),
        householdIdProvider.overrideWith((ref) => 'h1'),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(expenseControllerProvider.future),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'expense repo boom',
        ),
      ),
    );

    final state = container.read(expenseControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<ServerFailure>());
  });

  test('shoppingItemsProvider exposes ServerFailure as provider error',
      () async {
    final container = ProviderContainer(
      overrides: [
        shoppingRepositoryProvider.overrideWithValue(_FailingShoppingRepository()),
        householdIdProvider.overrideWith((ref) => 'h1'),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(shoppingItemsProvider.future),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'shopping repo boom',
        ),
      ),
    );

    final state = container.read(shoppingItemsProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<ServerFailure>());
  });

  test('savingsGoalsProvider exposes ServerFailure as provider error',
      () async {
    final container = ProviderContainer(
      overrides: [
        savingsRepositoryProvider.overrideWithValue(_FailingSavingsRepository()),
        householdIdProvider.overrideWith((ref) => 'h1'),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(savingsGoalsProvider.future),
      throwsA(
        isA<ServerFailure>().having(
          (failure) => failure.message,
          'message',
          'savings repo boom',
        ),
      ),
    );

    final state = container.read(savingsGoalsProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<ServerFailure>());
  });
}
