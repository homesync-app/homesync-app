import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../repositories/household_repository.dart';

class GenerateInvitationCodeUseCase {
  final HouseholdRepository _repository;

  const GenerateInvitationCodeUseCase(this._repository);

  Future<Either<Failure, String>> call() {
    return _repository.generateInvitationCode();
  }
}
