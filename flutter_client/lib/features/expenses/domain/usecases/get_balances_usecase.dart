import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

class GetBalancesUseCase {
  final ExpenseRepository _repository;

  GetBalancesUseCase(this._repository);

  Future<Either<Failure, List<HouseholdBalanceModel>>> call(
      String householdId) async {
    if (householdId.isEmpty) {
      return left(
          const ValidationFailure('El ID del hogar no puede estar vacío'));
    }
    return await _repository.getHouseholdBalances(householdId);
  }
}
