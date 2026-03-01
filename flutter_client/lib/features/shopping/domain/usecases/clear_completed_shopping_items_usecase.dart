import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class ClearCompletedShoppingItemsUseCase {
  final ShoppingRepository repository;

  ClearCompletedShoppingItemsUseCase(this.repository);

  Future<void> execute(String householdId) {
    if (householdId.isEmpty) throw ArgumentError('householdId is required');
    return repository.clearCompleted(householdId);
  }
}
