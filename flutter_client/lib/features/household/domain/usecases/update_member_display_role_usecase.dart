import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../repositories/household_repository.dart';

class UpdateMemberDisplayRoleUseCase {
  final HouseholdRepository _repository;

  const UpdateMemberDisplayRoleUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId, String? displayRole) {
    if (userId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('userId is required')),
      );
    }
    return _repository.updateMemberDisplayRole(userId, displayRole);
  }
}
