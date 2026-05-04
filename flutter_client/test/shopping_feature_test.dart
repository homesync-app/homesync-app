import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_categories.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:homesync_client/features/shopping/domain/usecases/add_shopping_item_usecase.dart';
import 'package:homesync_client/features/shopping/domain/usecases/get_shopping_items_usecase.dart';
import 'package:homesync_client/features/shopping/domain/usecases/toggle_shopping_item_usecase.dart';

class FakeShoppingRepository implements ShoppingRepository {
  int addCalls = 0;
  int fetchCalls = 0;
  int toggleCalls = 0;

  @override
  Future<Either<Failure, ShoppingItemModel>> addItem({
    required String householdId,
    required String name,
    required String userId,
    String? clientId,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
    bool shouldSync = true,
  }) async {
    addCalls++;
    return Right(
      ShoppingItemModel(
        id: clientId ?? 'item-1',
        householdId: householdId,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        emoji: emoji,
        note: note,
        addedBy: userId,
        createdAt: DateTime(2026, 1, 1),
        shouldSync: shouldSync,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> clearCompleted(String householdId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<ShoppingItemModel>>> fetchItems(
    String householdId,
  ) async {
    fetchCalls++;
    return Right([
      ShoppingItemModel(
        id: 'item-1',
        householdId: householdId,
        name: 'Leche',
        createdAt: DateTime(2026, 1, 1),
      ),
    ]);
  }

  @override
  Future<Either<Failure, void>> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  }) async {
    toggleCalls++;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> uncompleteAll(String householdId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateItem({
    required String itemId,
    required String name,
    required String category,
    required String emoji,
    String? note,
  }) async =>
      const Right(null);
}

void main() {
  group('ShoppingItemModel', () {
    test('parses Supabase payload and exposes display helpers', () {
      final item = ShoppingItemModel.fromJson({
        'id': 'item-1',
        'household_id': 'house-1',
        'name': 'Yerba',
        'quantity': '1',
        'unit': 'kg',
        'category': 'pantry',
        'emoji': '🧉',
        'note': 'Suave',
        'added_by': 'user-1',
        'added_by_user': {'full_name': 'Blas Perez'},
        'completed': true,
        'completed_by': 'user-2',
        'completed_by_user': {'full_name': 'Ana Gomez'},
        'completed_at': '2026-01-02T12:00:00.000Z',
        'created_at': '2026-01-01T12:00:00.000Z',
        'should_sync': false,
      });

      expect(item.displayQuantity, '1 kg');
      expect(item.addedByDisplay, 'Blas');
      expect(item.completedByDisplay, 'Ana');
      expect(item.completed, isTrue);
      expect(item.shouldSync, isFalse);
      expect(item.toJson()['category'], 'pantry');
    });

    test('uses safe defaults when optional backend fields are missing', () {
      final item = ShoppingItemModel.fromJson({
        'id': 'item-1',
        'household_id': 'house-1',
        'name': 'Pan',
        'created_at': '2026-01-01T12:00:00.000Z',
      });

      expect(item.category, 'general');
      expect(item.emoji, '🛒');
      expect(item.completed, isFalse);
      expect(item.displayQuantity, isEmpty);
      expect(item.addedByDisplay, isEmpty);
      expect(item.shouldSync, isTrue);
    });
  });

  group('ShoppingCategories', () {
    test('returns category metadata and falls back to general for unknown ids', () {
      expect(ShoppingCategories.nameFor('dairy'), 'Lácteos');
      expect(ShoppingCategories.emojiFor('dairy'), '🥛');
      expect(ShoppingCategories.colorFor('dairy'), 0xFF3B82F6);

      expect(ShoppingCategories.nameFor('unknown'), 'Frecuentes');
      expect(ShoppingCategories.emojiFor('unknown'), '🛒');
      expect(ShoppingCategories.colorFor('unknown'), 0xFF6366F1);
    });
  });

  group('Shopping use cases', () {
    test('validates required fields before adding an item', () async {
      final repository = FakeShoppingRepository();
      final useCase = AddShoppingItemUseCase(repository);

      final missingHousehold = await useCase.execute(
        householdId: '',
        name: 'Leche',
        userId: 'user-1',
      );
      final missingName = await useCase.execute(
        householdId: 'house-1',
        name: '   ',
        userId: 'user-1',
      );
      final missingUser = await useCase.execute(
        householdId: 'house-1',
        name: 'Leche',
        userId: '',
      );

      expect(missingHousehold.getLeft().toNullable(), isA<ValidationFailure>());
      expect(missingName.getLeft().toNullable(), isA<ValidationFailure>());
      expect(missingUser.getLeft().toNullable(), isA<ValidationFailure>());
      expect(repository.addCalls, 0);
    });

    test('delegates valid add and fetch requests to the repository', () async {
      final repository = FakeShoppingRepository();

      final added = await AddShoppingItemUseCase(repository).execute(
        householdId: 'house-1',
        name: 'Leche',
        userId: 'user-1',
        quantity: '2',
        unit: 'l',
        category: 'dairy',
        emoji: '🥛',
        note: 'Descremada',
      );
      final fetched = await GetShoppingItemsUseCase(repository).execute('house-1');

      expect(added.getRight().toNullable()?.name, 'Leche');
      expect(added.getRight().toNullable()?.displayQuantity, '2 l');
      expect(fetched.getRight().toNullable(), hasLength(1));
      expect(repository.addCalls, 1);
      expect(repository.fetchCalls, 1);
    });

    test('requires a user id only when completing an item', () async {
      final repository = FakeShoppingRepository();
      final useCase = ToggleShoppingItemUseCase(repository);

      final invalidComplete = await useCase.execute(
        itemId: 'item-1',
        completed: true,
        userId: null,
      );
      final validUncomplete = await useCase.execute(
        itemId: 'item-1',
        completed: false,
        userId: null,
      );

      expect(invalidComplete.getLeft().toNullable(), isA<ValidationFailure>());
      expect(validUncomplete.isRight(), isTrue);
      expect(repository.toggleCalls, 1);
    });
  });
}
