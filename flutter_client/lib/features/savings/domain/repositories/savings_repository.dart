import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/savings_model.dart';

abstract class SavingsRepository {
  Future<Either<Failure, List<SavingsGoalModel>>> getGoals(
      {required String householdId});

  Future<Either<Failure, List<SavingsContributionModel>>> getGoalContributions(
      {required String goalId});

  Future<Either<Failure, void>> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  });

  Future<Either<Failure, void>> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  });

  Future<Either<Failure, void>> deleteGoal({required String goalId});
}
