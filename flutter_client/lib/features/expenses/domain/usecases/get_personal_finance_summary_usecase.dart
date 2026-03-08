import '../repositories/expense_repository.dart';

class GetPersonalFinanceSummaryUseCase {
  final ExpenseRepository _repository;

  GetPersonalFinanceSummaryUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required String userId,
    required String householdId,
  }) {
    return _repository.getPersonalFinanceSummary(userId, householdId);
  }
}
