import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

import '../models/savings_model.dart';

class GetSavingsGoalsUseCase {
  final SavingsRepository repository;

  GetSavingsGoalsUseCase(this.repository);

  Future<Either<Failure, List<SavingsGoalModel>>> execute(
    String householdId, {
    int? limit,
    int? offset,
  }) {
    if (householdId.isEmpty) {
      return Future.value(const Left(ValidationFailure('householdId is required')));
    }
    return repository.getGoals(
      householdId: householdId,
      limit: limit,
      offset: offset,
    );
  }
}
