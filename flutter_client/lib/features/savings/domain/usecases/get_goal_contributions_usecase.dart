import '../models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class GetGoalContributionsUseCase {
  final SavingsRepository repository;

  GetGoalContributionsUseCase(this.repository);

  Future<List<SavingsContributionModel>> execute(String goalId) {
    if (goalId.isEmpty) throw ArgumentError('goalId is required');
    return repository.getGoalContributions(goalId: goalId);
  }
}
