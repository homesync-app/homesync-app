import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class CreateSavingsGoalUseCase {
  final SavingsRepository repository;

  CreateSavingsGoalUseCase(this.repository);

  Future<void> execute({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  }) {
    if (householdId.isEmpty) throw ArgumentError('householdId is required');
    if (title.isEmpty) throw ArgumentError('title is required');
    if (targetAmount <= 0)
      throw ArgumentError('targetAmount must be greater than zero');

    return repository.createGoal(
      householdId: householdId,
      title: title,
      targetAmount: targetAmount,
      color: color,
      icon: icon,
    );
  }
}
