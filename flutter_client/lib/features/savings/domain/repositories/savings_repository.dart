import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../models/savings_model.dart';

abstract class SavingsRepository {
  Future<Either<Failure, List<SavingsGoalModel>>> getGoals({
    required String householdId,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<SavingsContributionModel>>> getGoalContributions({
    required String goalId,
  });

  Future<Either<Failure, void>> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
    DateTime? targetDate,
  });

  Future<Either<Failure, void>> updateGoal({
    required String goalId,
    String? title,
    double? targetAmount,
    String? color,
    String? icon,
    DateTime? targetDate,
  });

  Future<Either<Failure, void>> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
    String splitType = 'personal',
    List<Map<String, dynamic>> participants = const [],
  });

  Future<Either<Failure, void>> archiveGoal({required String goalId});

  Future<Either<Failure, void>> deleteGoal({required String goalId});
}
