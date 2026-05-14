import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

import '../models/savings_model.dart';

class GetGoalContributionsUseCase {
  final SavingsRepository repository;

  GetGoalContributionsUseCase(this.repository);

  Future<Either<Failure, List<SavingsContributionModel>>> execute(
      String goalId,) {
    if (goalId.isEmpty) {
      return Future.value(const Left(ValidationFailure('goalId is required')));
    }
    return repository.getGoalContributions(goalId: goalId);
  }
}
