import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';

class FakePaginatedSavingsRepository implements SavingsRepository {
  final List<SavingsGoalModel> goals;

  FakePaginatedSavingsRepository(this.goals);

  @override
  Future<Either<Failure, void>> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteGoal({required String goalId}) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<SavingsContributionModel>>> getGoalContributions({
    required String goalId,
  }) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<SavingsGoalModel>>> getGoals({
    required String householdId,
    int? limit,
    int? offset,
  }) async {
    final start = offset ?? 0;
    final size = limit ?? goals.length;
    if (start >= goals.length) {
      return const Right([]);
    }

    final end = (start + size).clamp(0, goals.length);
    return Right(goals.sublist(start, end));
  }
}

SavingsGoalModel _goal(int index) {
  return SavingsGoalModel(
    id: 'goal-$index',
    householdId: 'house-1',
    title: 'Goal $index',
    targetAmount: 1000,
    currentAmount: index * 10,
    color: '#FF7E67',
    icon: 'target',
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  test('paginatedSavingsGoalsProvider loads another page and updates hasMore', () async {
    final container = ProviderContainer(
      overrides: [
        savingsRepositoryProvider.overrideWith(
          (ref) => FakePaginatedSavingsRepository(
            List.generate(15, _goal),
          ),
        ),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(paginatedSavingsGoalsProvider.future);
    expect(initial.items, hasLength(12));
    expect(initial.hasMore, isTrue);

    await container.read(paginatedSavingsGoalsProvider.notifier).loadMore();

    final paged = container.read(paginatedSavingsGoalsProvider).valueOrNull;
    expect(paged, isNotNull);
    expect(paged!.items, hasLength(15));
    expect(paged.hasMore, isFalse);
    expect(paged.isLoadingMore, isFalse);
  });
}
