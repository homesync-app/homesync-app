import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class AddContributionUseCase {
  final SavingsRepository repository;

  AddContributionUseCase(this.repository);

  Future<void> execute({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  }) {
    if (goalId.isEmpty) throw ArgumentError('goalId is required');
    if (userId.isEmpty) throw ArgumentError('userId is required');
    if (amount <= 0) throw ArgumentError('amount must be greater than zero');

    return repository.addContribution(
      goalId: goalId,
      userId: userId,
      amount: amount,
      note: note,
    );
  }
}
