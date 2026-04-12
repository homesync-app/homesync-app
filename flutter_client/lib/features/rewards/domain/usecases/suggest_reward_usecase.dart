import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../repositories/reward_repository.dart';

/// Use case: suggest (propose) a new reward.
class SuggestRewardUseCase {
  final RewardRepository _repository;

  const SuggestRewardUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String householdId,
    required String userId,
    required String title,
    String? description,
    required int cost,
    String icon = 'gift',
  }) async {
    if (title.trim().isEmpty) {
      return const Left(ValidationFailure('El titulo no puede estar vacio'));
    }
    if (cost <= 0) {
      return const Left(ValidationFailure('El costo debe ser mayor a 0'));
    }

    return _repository.suggestReward(
      householdId: householdId,
      createdBy: userId,
      title: title.trim(),
      description: description,
      cost: cost,
      icon: icon,
    );
  }
}
