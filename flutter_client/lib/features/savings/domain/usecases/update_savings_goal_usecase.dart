import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class UpdateSavingsGoalUseCase {
  final SavingsRepository repository;

  UpdateSavingsGoalUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String goalId,
    String? title,
    double? targetAmount,
    String? color,
    String? icon,
    DateTime? targetDate,
  }) {
    if (goalId.isEmpty) {
      return Future.value(const Left(ValidationFailure('goalId is required')));
    }
    if (targetAmount != null && targetAmount <= 0) {
      return Future.value(
        const Left(ValidationFailure('targetAmount must be greater than zero')),
      );
    }
    return repository.updateGoal(
      goalId: goalId,
      title: title,
      targetAmount: targetAmount,
      color: color,
      icon: icon,
      targetDate: targetDate,
    );
  }
}
