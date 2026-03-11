import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class AddContributionUseCase {
  final SavingsRepository repository;

  AddContributionUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  }) {
    if (goalId.isEmpty) {
      return Future.value(const Left(ValidationFailure('goalId is required')));
    }
    if (userId.isEmpty) {
      return Future.value(const Left(ValidationFailure('userId is required')));
    }
    if (amount <= 0) {
      return Future.value(
          const Left(ValidationFailure('amount must be greater than zero')));
    }

    return repository.addContribution(
      goalId: goalId,
      userId: userId,
      amount: amount,
      note: note,
    );
  }
}
