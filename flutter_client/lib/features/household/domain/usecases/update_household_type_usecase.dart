import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../repositories/household_repository.dart';

class UpdateHouseholdTypeUseCase {
  final HouseholdRepository _repository;

  const UpdateHouseholdTypeUseCase(this._repository);

  Future<Either<Failure, void>> call(String householdId, String type) {
    if (householdId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('householdId is required')),
      );
    }
    if (type.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('type is required')));
    }
    return _repository.updateHouseholdType(householdId, type);
  }
}
