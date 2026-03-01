import '../models/shopping_model.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class GetShoppingItemsUseCase {
  final ShoppingRepository repository;

  GetShoppingItemsUseCase(this.repository);

  Future<List<ShoppingItemModel>> execute(String householdId) {
    if (householdId.isEmpty) throw ArgumentError('householdId is required');
    return repository.fetchItems(householdId);
  }
}
