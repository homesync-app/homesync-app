import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../repositories/household_repository.dart';

class UpdateDefaultSplitRatioUseCase {
  final HouseholdRepository _repository;

  const UpdateDefaultSplitRatioUseCase(this._repository);

  Future<Either<Failure, void>> call(String householdId, double ratio) {
    if (householdId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('householdId is required')),
      );
    }
    if (ratio < 0 || ratio > 1) {
      return Future.value(
        const Left(ValidationFailure('ratio must be between 0 and 1')),
      );
    }
    return _repository.updateDefaultSplitRatio(householdId, ratio);
  }
}
