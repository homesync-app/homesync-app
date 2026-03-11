import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class DeleteShoppingItemUseCase {
  final ShoppingRepository repository;

  DeleteShoppingItemUseCase(this.repository);

  Future<Either<Failure, void>> execute(String itemId) {
    if (itemId.isEmpty) {
      return Future.value(const Left(ValidationFailure('itemId is required')));
    }
    return repository.deleteItem(itemId);
  }
}
