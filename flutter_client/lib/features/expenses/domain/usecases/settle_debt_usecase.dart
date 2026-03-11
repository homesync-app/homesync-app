import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class SettleDebtUseCase {
  final ExpenseRepository _repository;

  SettleDebtUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    if (householdId.isEmpty) {
      return left(const ValidationFailure('El ID del hogar no puede estar vacío'));
    }
    if (toUserId.isEmpty) {
      return left(const ValidationFailure('El usuario destino no puede estar vacío'));
    }
    if (amount <= 0) {
      return left(const ValidationFailure('El monto a saldar debe ser mayor a 0'));
    }

    return await _repository.settleDebt(
      householdId: householdId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
    );
  }
}
