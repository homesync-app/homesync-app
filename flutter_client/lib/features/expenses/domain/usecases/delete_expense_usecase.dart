import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository _repository;

  DeleteExpenseUseCase(this._repository);

  Future<Either<Failure, void>> call(String expenseId) async {
    if (expenseId.isEmpty) {
      return left(
          const ValidationFailure('El ID del gasto no puede estar vacío'),);
    }
    return await _repository.deleteExpense(expenseId);
  }
}
