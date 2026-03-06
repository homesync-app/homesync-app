import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class GetGoalContributionsUseCase {
  final SavingsRepository repository;

  GetGoalContributionsUseCase(this.repository);

  Future<Either<Failure, List<SavingsContributionModel>>> execute(String goalId) {
    if (goalId.isEmpty) {
      return Future.value(Left(ValidationFailure('goalId is required')));
    }
    return repository.getGoalContributions(goalId: goalId);
  }
}
