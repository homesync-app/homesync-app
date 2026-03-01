import '../models/shopping_model.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

class AddShoppingItemUseCase {
  final ShoppingRepository repository;

  AddShoppingItemUseCase(this.repository);

  Future<ShoppingItemModel> execute({
    required String householdId,
    required String name,
    required String userId,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
  }) {
    if (householdId.isEmpty) throw ArgumentError('householdId is required');
    if (name.trim().isEmpty) throw ArgumentError('name is required');
    if (userId.isEmpty) throw ArgumentError('userId is required');

    return repository.addItem(
      householdId: householdId,
      name: name,
      userId: userId,
      quantity: quantity,
      unit: unit,
      category: category,
      emoji: emoji,
      note: note,
    );
  }
}
