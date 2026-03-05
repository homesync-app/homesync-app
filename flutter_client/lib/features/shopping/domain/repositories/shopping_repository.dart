import '../models/shopping_model.dart';

abstract class ShoppingRepository {
  Future<List<ShoppingItemModel>> fetchItems(String householdId);

  Future<ShoppingItemModel> addItem({
    required String householdId,
    required String name,
    required String userId,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
  });

  Future<void> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  });

  Future<void> deleteItem(String itemId);

  Future<void> clearCompleted(String householdId);

  Future<void> uncompleteAll(String householdId);
}
