import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class DeleteSavingsGoalUseCase {
  final SavingsRepository repository;

  DeleteSavingsGoalUseCase(this.repository);

  Future<Either<Failure, void>> execute(String goalId) {
    if (goalId.isEmpty) {
      return Future.value(const Left(ValidationFailure('goalId is required')));
    }
    return repository.deleteGoal(goalId: goalId);
  }
}
