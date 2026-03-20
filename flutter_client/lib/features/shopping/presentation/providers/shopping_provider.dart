import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import '../../domain/models/shopping_model.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../../domain/usecases/get_shopping_items_usecase.dart';
import '../../domain/usecases/add_shopping_item_usecase.dart';
import '../../domain/usecases/toggle_shopping_item_usecase.dart';
import '../../domain/usecases/delete_shopping_item_usecase.dart';
import '../../domain/usecases/clear_completed_shopping_items_usecase.dart';
import '../../domain/usecases/uncomplete_all_shopping_items_usecase.dart';
import '../../data/repositories/supabase_shopping_repository.dart';
import 'package:uuid/uuid.dart';

part 'shopping_provider.g.dart';

// ── Repositories & Use Cases ──────────────────────────────────────────────────

@riverpod
ShoppingRepository shoppingRepository(ShoppingRepositoryRef ref) {
  return SupabaseShoppingRepository(ref: ref);
}

@riverpod
GetShoppingItemsUseCase getShoppingItemsUseCase(GetShoppingItemsUseCaseRef ref) {
  return GetShoppingItemsUseCase(ref.watch(shoppingRepositoryProvider));
}

@riverpod
AddShoppingItemUseCase addShoppingItemUseCase(AddShoppingItemUseCaseRef ref) {
  return AddShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
}

@riverpod
ToggleShoppingItemUseCase toggleShoppingItemUseCase(ToggleShoppingItemUseCaseRef ref) {
  return ToggleShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
}

@riverpod
DeleteShoppingItemUseCase deleteShoppingItemUseCase(DeleteShoppingItemUseCaseRef ref) {
  return DeleteShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
}

@riverpod
ClearCompletedShoppingItemsUseCase clearCompletedShoppingItemsUseCase(ClearCompletedShoppingItemsUseCaseRef ref) {
  return ClearCompletedShoppingItemsUseCase(ref.watch(shoppingRepositoryProvider));
}

@riverpod
UncompleteAllShoppingItemsUseCase uncompleteAllShoppingItemsUseCase(UncompleteAllShoppingItemsUseCaseRef ref) {
  return UncompleteAllShoppingItemsUseCase(ref.watch(shoppingRepositoryProvider));
}

// ── Main Shopping Controller ──────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ShoppingItems extends _$ShoppingItems {
  RealtimeChannel? _channel;
  static const Uuid _uuid = Uuid();

  @override
  Future<List<ShoppingItemModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    _setupRealtime(householdId);

    final getItems = ref.watch(getShoppingItemsUseCaseProvider);
    final result = await getItems.execute(householdId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  void _setupRealtime(String householdId) {
    _channel?.unsubscribe();
    final client = ref.read(supabaseClientProvider);
    
    _channel = client
        .channel('shopping_realtime_$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableShoppingItems,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (payload) {
            log.i('Realtime shopping change detected: ${payload.eventType}');
            silentRefresh();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItems());
  }

  Future<void> silentRefresh() async {
    state = await AsyncValue.guard(() => _fetchItems());
  }

  Future<List<ShoppingItemModel>> _fetchItems() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return [];
    
    final result = await ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
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

    if (householdId == null || userId == null) {
      throw Exception('Authentication or Household required');
    }

    final oldState = state.value ?? [];
    
    final clientId = _uuid.v4();
    // Create optimistic temporary item
    final tempItem = ShoppingItemModel(
      id: clientId,
      householdId: householdId,
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      emoji: emoji,
      note: note,
      addedBy: userId,
      createdAt: DateTime.now(),
      completed: false,
      shouldSync: true,
    );

    // Update state immediately
    state = AsyncValue.data([tempItem, ...oldState]);

    try {
      final result = await ref.read(addShoppingItemUseCaseProvider).execute(
            householdId: householdId,
            name: name,
            userId: userId,
            clientId: clientId,
            quantity: quantity,
            unit: unit,
            category: category,
            emoji: emoji,
            note: note,
          );
      
      result.fold(
        (failure) {
          log.e('Failed to add item: ${failure.message}');
          state = AsyncValue.data(oldState); // Rollback
        },
        (newItem) {
          // Replace temp item with real one to get the proper ID
          final currentState = state.value ?? [];
          state = AsyncValue.data(
            currentState.map((item) => item.id == tempItem.id ? newItem : item).toList()
          );
        },
      );
    } catch (e) {
      log.e('Error in addItem: $e');
      state = AsyncValue.data(oldState);
    }
  }

  Future<void> toggleItem(String itemId, bool completed) async {
    final householdId = await ref.read(householdIdProvider.future);
    final userId = ref.read(currentUserIdProvider);
    if (householdId == null) return;

    final oldState = state.value ?? [];
    
    // Optimistic Update
    final newState = oldState.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          completed: completed,
          completedBy: completed ? userId : null,
          completedAt: completed ? DateTime.now() : null,
        );
      }
      return item;
    }).toList();
    
    state = AsyncValue.data(newState);

    try {
      final result = await ref.read(toggleShoppingItemUseCaseProvider).execute(
            itemId: itemId,
            completed: completed,
            userId: userId,
          );
      
      if (result.isLeft()) {
        log.e('Failed to toggle item');
        state = AsyncValue.data(oldState); // Rollback
      }
    } catch (e) {
      log.e('Error in toggleItem: $e');
      state = AsyncValue.data(oldState);
    }
  }

  Future<void> deleteItem(String itemId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final oldState = state.value ?? [];
    
    // Optimistic Delete
    state = AsyncValue.data(
      oldState.where((item) => item.id != itemId).toList(),
    );

    try {
      final result = await ref.read(deleteShoppingItemUseCaseProvider).execute(itemId);
      if (result.isLeft()) {
        log.e('Failed to delete item');
        state = AsyncValue.data(oldState); // Rollback
      }
    } catch (e) {
      log.e('Error in deleteItem: $e');
      state = AsyncValue.data(oldState);
    }
  }

  Future<void> clearCompleted() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final oldState = state.value ?? [];
    
    // Optimistic Clear
    state = AsyncValue.data(
      oldState.where((item) => !item.completed).toList(),
    );

    try {
      final result = await ref
          .read(clearCompletedShoppingItemsUseCaseProvider)
          .execute(householdId);
      
      if (result.isLeft()) {
        log.e('Failed to clear completed items');
        state = AsyncValue.data(oldState); // Rollback
      }
    } catch (e) {
      log.e('Error in clearCompleted: $e');
      state = AsyncValue.data(oldState);
    }
  }

  Future<void> uncompleteAll() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final oldState = state.value ?? [];
    
    // Optimistic Uncomplete All
    state = AsyncValue.data(
      oldState.map((item) => item.copyWith(completed: false)).toList(),
    );

    try {
      final result = await ref
          .read(uncompleteAllShoppingItemsUseCaseProvider)
          .execute(householdId);
      
      if (result.isLeft()) {
        log.e('Failed to uncomplete items');
        state = AsyncValue.data(oldState); // Rollback
      }
    } catch (e) {
      log.e('Error in uncompleteAll: $e');
      state = AsyncValue.data(oldState);
    }
  }
}

