import '../repositories/rewards_repository_interface.dart';

/// Use case: suggest (propose) a new reward.
class SuggestRewardUseCase {
  final RewardsRepositoryInterface _repository;

  const SuggestRewardUseCase(this._repository);

  Future<void> call({
    required String householdId,
    required String userId,
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
  }) async {
    // Business rules:
    if (title.trim().isEmpty)
      throw ArgumentError('El título no puede estar vacío');
    if (cost <= 0) throw ArgumentError('El costo debe ser mayor a 0');

    await _repository.suggestReward(
      householdId: householdId,
      userId: userId,
      title: title.trim(),
      description: description,
      cost: cost,
      icon: icon,
    );
  }
}
