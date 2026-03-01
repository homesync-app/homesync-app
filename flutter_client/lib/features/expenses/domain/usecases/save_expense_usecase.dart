import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class SaveExpenseUseCase {
  final ExpenseRepository _repository;

  SaveExpenseUseCase(this._repository);

  Future<void> call({
    String? id,
    required String householdId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime paidAt,
    String? description,
    required SplitType splitType,
    List<Map<String, dynamic>>? splits,
  }) async {
    if (title.isEmpty) throw Exception('El título es requerido');
    if (amount <= 0) throw Exception('El monto debe ser mayor a 0');
    if (householdId.isEmpty) throw Exception('El ID del hogar no puede estar vacío');
    
    await _repository.saveExpense(
      id: id,
      householdId: householdId,
      title: title,
      amount: amount,
      category: category,
      paidBy: paidBy,
      paidAt: paidAt,
      description: description,
      splitType: splitType,
      splits: splits,
    );
  }
}
