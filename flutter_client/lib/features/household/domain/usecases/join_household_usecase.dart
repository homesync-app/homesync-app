import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../repositories/household_repository.dart';

class JoinHouseholdUseCase {
  final HouseholdRepository _repository;

  const JoinHouseholdUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized.length != 6) {
      return Future.value(
        const Left(ValidationFailure('El codigo debe tener 6 caracteres')),
      );
    }
    return _repository.joinHousehold(normalized);
  }
}
