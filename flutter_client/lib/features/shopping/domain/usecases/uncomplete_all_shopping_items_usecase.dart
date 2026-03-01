import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class UncompleteAllShoppingItemsUseCase {
  final ShoppingRepository repository;

  UncompleteAllShoppingItemsUseCase(this.repository);

  Future<void> execute(String householdId) {
    if (householdId.isEmpty) throw ArgumentError('householdId is required');
    return repository.uncompleteAll(householdId);
  }
}
