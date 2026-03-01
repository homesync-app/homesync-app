import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class DeleteSavingsGoalUseCase {
  final SavingsRepository repository;

  DeleteSavingsGoalUseCase(this.repository);

  Future<void> execute(String goalId) {
    if (goalId.isEmpty) throw ArgumentError('goalId is required');
    return repository.deleteGoal(goalId: goalId);
  }
}
