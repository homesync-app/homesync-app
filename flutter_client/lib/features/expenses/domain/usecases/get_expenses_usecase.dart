import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository _repository;

  GetExpensesUseCase(this._repository);

  Future<Either<Failure, List<ExpenseModel>>> call(String householdId) async {
    if (householdId.isEmpty) {
      return left(
          const ValidationFailure('El ID del hogar no puede estar vacío'));
    }
    return await _repository.getRecentExpenses(householdId);
  }
}
