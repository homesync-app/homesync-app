import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';

import '../models/shopping_model.dart';

class AddShoppingItemUseCase {
  final ShoppingRepository repository;

  AddShoppingItemUseCase(this.repository);

  Future<Either<Failure, ShoppingItemModel>> execute({
    required String householdId,
    required String name,
    required String userId,
    String? clientId,
    String? nameKey,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
    bool shouldSync = true,
  }) {
    if (householdId.isEmpty) {
      return Future.value(
          const Left(ValidationFailure('householdId is required')),);
    }
    if (name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('name is required')));
    }
    if (userId.isEmpty) {
      return Future.value(const Left(ValidationFailure('userId is required')));
    }

    return repository.addItem(
      householdId: householdId,
      name: name,
      userId: userId,
      clientId: clientId,
      nameKey: nameKey,
      quantity: quantity,
      unit: unit,
      category: category,
      emoji: emoji,
      note: note,
      shouldSync: shouldSync,
    );
  }
}
