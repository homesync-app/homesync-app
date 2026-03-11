import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../models/shopping_model.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class GetShoppingItemsUseCase {
  final ShoppingRepository repository;

  GetShoppingItemsUseCase(this.repository);

  Future<Either<Failure, List<ShoppingItemModel>>> execute(String householdId) {
    if (householdId.isEmpty) {
      return Future.value(const Left(ValidationFailure('householdId is required')));
    }
    return repository.fetchItems(householdId);
  }
}
