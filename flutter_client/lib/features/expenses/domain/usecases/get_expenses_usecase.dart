import '../models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository _repository;

  GetExpensesUseCase(this._repository);

  Future<List<ExpenseModel>> call(String householdId) async {
    if (householdId.isEmpty) {
      throw Exception('El ID del hogar no puede estar vacío');
    }
    return await _repository.getRecentExpenses(householdId);
  }
}
