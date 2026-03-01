import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class ToggleShoppingItemUseCase {
  final ShoppingRepository repository;

  ToggleShoppingItemUseCase(this.repository);

  Future<void> execute({
    required String itemId,
    required bool completed,
    required String? userId,
  }) {
    if (itemId.isEmpty) throw ArgumentError('itemId is required');
    if (completed && (userId == null || userId.isEmpty)) {
      throw ArgumentError('userId is required when marking as completed');
    }

    return repository.toggleItem(
      itemId: itemId,
      completed: completed,
      userId: userId,
    );
  }
}
