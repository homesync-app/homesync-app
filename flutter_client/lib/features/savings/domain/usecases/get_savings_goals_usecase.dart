import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class GetSavingsGoalsUseCase {
  final SavingsRepository repository;

  GetSavingsGoalsUseCase(this.repository);

  Future<Either<Failure, List<SavingsGoalModel>>> execute(String householdId) {
    if (householdId.isEmpty) {
      return Future.value(Left(ValidationFailure('householdId is required')));
    }
    return repository.getGoals(householdId: householdId);
  }
}
