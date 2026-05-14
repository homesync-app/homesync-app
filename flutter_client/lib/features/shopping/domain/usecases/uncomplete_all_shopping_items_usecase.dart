import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class UncompleteAllShoppingItemsUseCase {
  final ShoppingRepository repository;

  UncompleteAllShoppingItemsUseCase(this.repository);

  Future<Either<Failure, void>> execute(String householdId) {
    if (householdId.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('householdId is required')),);
    }
    return repository.uncompleteAll(householdId);
  }
}
