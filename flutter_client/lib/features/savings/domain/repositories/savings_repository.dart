import '../models/savings_model.dart';

abstract class SavingsRepository {
  Future<List<SavingsGoalModel>> getGoals({required String householdId});
  
  Future<List<SavingsContributionModel>> getGoalContributions({required String goalId});
  
  Future<void> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  });
  
  Future<void> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  });
  
  Future<void> deleteGoal({required String goalId});
}
