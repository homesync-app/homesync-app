import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class ClearCompletedShoppingItemsUseCase {
  final ShoppingRepository repository;

  ClearCompletedShoppingItemsUseCase(this.repository);

  Future<Either<Failure, void>> execute(String householdId) {
    if (householdId.isEmpty) {
      return Future.value(const Left(ValidationFailure('householdId is required')));
    }
    return repository.clearCompleted(householdId);
  }
}
