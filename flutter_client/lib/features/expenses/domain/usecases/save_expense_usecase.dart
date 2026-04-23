import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class SaveExpenseUseCase {
  final ExpenseRepository _repository;

  SaveExpenseUseCase(this._repository);

  Future<Either<Failure, void>> call({
    String? id,
    required String householdId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime paidAt,
    String? description,
    required SplitType splitType,
    String type = 'expense',
    List<Map<String, dynamic>>? splits,
  }) async {
    if (title.isEmpty) {
      return left(const ValidationFailure('El título es requerido'));
    }
    if (amount <= 0) {
      return left(const ValidationFailure('El monto debe ser mayor a 0'));
    }
    if (householdId.isEmpty) {
      return left(
          const ValidationFailure('El ID del hogar no puede estar vacío'),);
    }

    return await _repository.saveExpense(
      id: id,
      householdId: householdId,
      title: title,
      amount: amount,
      category: category,
      paidBy: paidBy,
      paidAt: paidAt,
      description: description,
      splitType: splitType,
      type: type,
      splits: splits,
    );
  }
}
