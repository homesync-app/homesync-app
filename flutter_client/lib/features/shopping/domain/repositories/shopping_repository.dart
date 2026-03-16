import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../models/shopping_model.dart';

abstract class ShoppingRepository {
  Future<Either<Failure, List<ShoppingItemModel>>> fetchItems(
      String householdId);

  Future<Either<Failure, ShoppingItemModel>> addItem({
    required String householdId,
    required String name,
    required String userId,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
    bool shouldSync = true,
  });

  Future<Either<Failure, void>> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  });

  Future<Either<Failure, void>> deleteItem(String itemId);

  Future<Either<Failure, void>> clearCompleted(String householdId);

  Future<Either<Failure, void>> uncompleteAll(String householdId);
}
