import '../models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class GetBalancesUseCase {
  final ExpenseRepository _repository;

  GetBalancesUseCase(this._repository);

  Future<List<HouseholdBalanceModel>> call(String householdId) async {
    if (householdId.isEmpty) {
      throw Exception('El ID del hogar no puede estar vacío');
    }
    return await _repository.getHouseholdBalances(householdId);
  }
}
