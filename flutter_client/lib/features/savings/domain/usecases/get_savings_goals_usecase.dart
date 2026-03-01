import '../models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';

class GetSavingsGoalsUseCase {
  final SavingsRepository repository;

  GetSavingsGoalsUseCase(this.repository);

  Future<List<SavingsGoalModel>> execute(String householdId) {
    if (householdId.isEmpty) throw ArgumentError('householdId is required');
    return repository.getGoals(householdId: householdId);
  }
}
