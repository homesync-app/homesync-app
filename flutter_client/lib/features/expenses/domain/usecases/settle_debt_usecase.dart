import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class SettleDebtUseCase {
  final ExpenseRepository _repository;

  SettleDebtUseCase(this._repository);

  Future<void> call({
    required String householdId,
    required String toUserId,
    required double amount,
  }) async {
    if (householdId.isEmpty) throw Exception('El ID del hogar no puede estar vacío');
    if (toUserId.isEmpty) throw Exception('El usuario destino no puede estar vacío');
    if (amount <= 0) throw Exception('El monto a saldar debe ser mayor a 0');
    
    await _repository.settleDebt(
      householdId: householdId,
      toUserId: toUserId,
      amount: amount,
    );
  }
}
