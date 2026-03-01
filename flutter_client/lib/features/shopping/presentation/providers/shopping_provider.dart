import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

import '../../domain/models/shopping_model.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../../domain/usecases/get_shopping_items_usecase.dart';
import '../../domain/usecases/add_shopping_item_usecase.dart';
import '../../domain/usecases/toggle_shopping_item_usecase.dart';
import '../../domain/usecases/delete_shopping_item_usecase.dart';
import '../../domain/usecases/clear_completed_shopping_items_usecase.dart';
import '../../domain/usecases/uncomplete_all_shopping_items_usecase.dart';
import '../../data/repositories/supabase_shopping_repository.dart';

// --- Repositories & Use Cases ---

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return SupabaseShoppingRepository();
});

final getShoppingItemsUseCaseProvider = Provider<GetShoppingItemsUseCase>((ref) {
  return GetShoppingItemsUseCase(ref.watch(shoppingRepositoryProvider));
});

final addShoppingItemUseCaseProvider = Provider<AddShoppingItemUseCase>((ref) {
  return AddShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
});

final toggleShoppingItemUseCaseProvider = Provider<ToggleShoppingItemUseCase>((ref) {
  return ToggleShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
});

final deleteShoppingItemUseCaseProvider = Provider<DeleteShoppingItemUseCase>((ref) {
  return DeleteShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
});

final clearCompletedShoppingItemsUseCaseProvider = Provider<ClearCompletedShoppingItemsUseCase>((ref) {
  return ClearCompletedShoppingItemsUseCase(ref.watch(shoppingRepositoryProvider));
});

final uncompleteAllShoppingItemsUseCaseProvider = Provider<UncompleteAllShoppingItemsUseCase>((ref) {
  return UncompleteAllShoppingItemsUseCase(ref.watch(shoppingRepositoryProvider));
});

// --- Realtime Streams Setup (Optional future refactor, but for now we'll do AsyncNotifier) ---

final shoppingItemsProvider = AsyncNotifierProvider<ShoppingItemsNotifier, List<ShoppingItemModel>>(() {
  return ShoppingItemsNotifier();
});

class ShoppingItemsNotifier extends AsyncNotifier<List<ShoppingItemModel>> {
  RealtimeChannel? _channel;

  @override
  Future<List<ShoppingItemModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];
    
    _channel?.unsubscribe();
    _channel = Supabase.instance.client
        .channel('shopping:$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (_) {
            _refresh();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    final getItems = ref.watch(getShoppingItemsUseCaseProvider);
    return getItems.execute(householdId);
  }

  Future<void> _refresh() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;
    state = await AsyncValue.guard(() async {
      return ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
    });
  }

  Future<void> addItem({
    required String name,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
  }) async {
    final householdId = await ref.read(householdIdProvider.future);
    final userId = ref.read(currentUserIdProvider);
    
    if (householdId == null || userId == null) throw Exception('Authentication or Household required');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addShoppingItemUseCaseProvider).execute(
        householdId: householdId,
        name: name,
        userId: userId,
        quantity: quantity,
        unit: unit,
        category: category,
        emoji: emoji,
        note: note,
      );
      final getItems = ref.read(getShoppingItemsUseCaseProvider);
      return getItems.execute(householdId);
    });
  }

  Future<void> toggleItem(String itemId, bool completed) async {
    final householdId = await ref.read(householdIdProvider.future);
    final userId = ref.read(currentUserIdProvider);
    if (householdId == null) return;
    
    // We update UI optimistically, or wait for server. Let's wait for server to keep it simple and sure
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(toggleShoppingItemUseCaseProvider).execute(
        itemId: itemId,
        completed: completed,
        userId: userId,
      );
      final getItems = ref.read(getShoppingItemsUseCaseProvider);
      return getItems.execute(householdId);
    });
  }

  Future<void> deleteItem(String itemId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteShoppingItemUseCaseProvider).execute(itemId);
      final getItems = ref.read(getShoppingItemsUseCaseProvider);
      return getItems.execute(householdId);
    });
  }

  Future<void> clearCompleted() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(clearCompletedShoppingItemsUseCaseProvider).execute(householdId);
      final getItems = ref.read(getShoppingItemsUseCaseProvider);
      return getItems.execute(householdId);
    });
  }

  Future<void> uncompleteAll() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(uncompleteAllShoppingItemsUseCaseProvider).execute(householdId);
      final getItems = ref.read(getShoppingItemsUseCaseProvider);
      return getItems.execute(householdId);
    });
  }
}
