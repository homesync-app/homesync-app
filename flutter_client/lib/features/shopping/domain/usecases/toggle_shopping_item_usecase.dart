import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class ToggleShoppingItemUseCase {
  final ShoppingRepository repository;

  ToggleShoppingItemUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String itemId,
    required bool completed,
    required String? userId,
  }) {
    if (itemId.isEmpty) {
      return Future.value(const Left(ValidationFailure('itemId is required')));
    }
    if (completed && (userId == null || userId.isEmpty)) {
      return Future.value(
          const Left(ValidationFailure('userId is required when marking as completed')));
    }

    return repository.toggleItem(
      itemId: itemId,
      completed: completed,
      userId: userId,
    );
  }
}
