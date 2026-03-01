import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class DeleteShoppingItemUseCase {
  final ShoppingRepository repository;

  DeleteShoppingItemUseCase(this.repository);

  Future<void> execute(String itemId) {
    if (itemId.isEmpty) throw ArgumentError('itemId is required');
    return repository.deleteItem(itemId);
  }
}
