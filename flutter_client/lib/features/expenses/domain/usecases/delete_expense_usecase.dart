import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository _repository;

  DeleteExpenseUseCase(this._repository);

  Future<void> call(String expenseId) async {
    if (expenseId.isEmpty) throw Exception('El ID del gasto no puede estar vacío');
    await _repository.deleteExpense(expenseId);
  }
}
