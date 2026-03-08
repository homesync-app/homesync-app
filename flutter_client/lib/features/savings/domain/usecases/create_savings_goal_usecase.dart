import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class CreateSavingsGoalUseCase {
  final SavingsRepository repository;

  CreateSavingsGoalUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  }) {
    if (householdId.isEmpty) {
      return Future.value(const Left(ValidationFailure('householdId is required')));
    }
    if (title.isEmpty) {
      return Future.value(const Left(ValidationFailure('title is required')));
    }
    if (targetAmount <= 0) {
      return Future.value(
          const Left(ValidationFailure('targetAmount must be greater than zero')));
    }

    return repository.createGoal(
      householdId: householdId,
      title: title,
      targetAmount: targetAmount,
      color: color,
      icon: icon,
    );
  }
}
