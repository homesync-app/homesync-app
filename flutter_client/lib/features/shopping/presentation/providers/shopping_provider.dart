import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/supabase_shopping_repository.dart';
import '../../data/shopping_predefined.dart';
import '../../domain/models/shopping_model.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../../domain/usecases/add_shopping_item_usecase.dart';
import '../../domain/usecases/clear_completed_shopping_items_usecase.dart';
import '../../domain/usecases/delete_shopping_item_usecase.dart';
import '../../domain/usecases/get_shopping_items_usecase.dart';
import '../../domain/usecases/toggle_shopping_item_usecase.dart';
import '../../domain/usecases/uncomplete_all_shopping_items_usecase.dart';

part 'shopping_provider.g.dart';

// ── Repositories & Use Cases ──────────────────────────────────────────────────

@riverpod
ShoppingRepository shoppingRepository(ShoppingRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseShoppingRepository(client: client, ref: ref);
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
      (failure) => throw failure,
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
      (failure) => throw failure,
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
            currentState.map((item) => item.id == tempItem.id ? newItem : item).toList(),
          );
          // Log si el item no está en el catálogo predefinido (para admin analytics)
          _logCatalogRequestIfNeeded(name, emoji);
        },
      );
    } catch (e, stack) {
      log.e('Error in addItem: $e', error: e, stackTrace: stack);
      state = AsyncValue.data(oldState);
    }
  }

  /// Registra el item en shopping_catalog_requests si no existe en el catálogo.
  /// Fire-and-forget: nunca bloquea ni propaga errores al usuario.
  void _logCatalogRequestIfNeeded(String name, String emoji) {
    final match = ReceiptMatcher.findPredefined(name);
    if (match != null) return; // Está en el catálogo, no hace falta loguear

    // Verificar también coincidencia exacta por nombre (case insensitive)
    final nameLower = name.toLowerCase().trim();
    final inCatalog = ShoppingPredefined.itemsPerCategory.values
        .expand((list) => list)
        .any((item) => (item['name'] ?? '').toLowerCase() == nameLower);
    if (inCatalog) return;

    // Log async sin await — no bloquea el flujo
    final client = ref.read(supabaseClientProvider);
    client.rpc('upsert_catalog_request', params: {
      'p_name': name.trim(),
      'p_emoji': emoji,
    },).then((_) {
      log.d('Catalog request logged: $name');
    }).catchError((e) {
      log.w('Could not log catalog request: $e');
    });
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
    } catch (e, stack) {
      log.e('Error in toggleItem: $e', error: e, stackTrace: stack);
      state = AsyncValue.data(oldState);
    }
  }

  Future<void> updateItem({
    required String itemId,
    required String name,
    required String category,
    required String emoji,
    String? note,
  }) async {
    final oldState = state.value ?? [];

    // Optimistic update
    state = AsyncValue.data(
      oldState.map((item) {
        if (item.id != itemId) return item;
        return ShoppingItemModel(
          id: item.id,
          householdId: item.householdId,
          name: name,
          quantity: item.quantity,
          unit: item.unit,
          category: category,
          emoji: emoji,
          note: note ?? item.note,
          addedBy: item.addedBy,
          addedByName: item.addedByName,
          completed: item.completed,
          completedBy: item.completedBy,
          completedByName: item.completedByName,
          completedAt: item.completedAt,
          createdAt: item.createdAt,
          shouldSync: item.shouldSync,
        );
      }).toList(),
    );

    try {
      final result = await ref.read(shoppingRepositoryProvider).updateItem(
            itemId: itemId,
            name: name,
            category: category,
            emoji: emoji,
            note: note,
          );
      if (result.isLeft()) {
        log.e('Failed to update item');
        state = AsyncValue.data(oldState);
      }
    } catch (e) {
      log.e('Error in updateItem: $e');
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
    } catch (e, stack) {
      log.e('Error in deleteItem: $e', error: e, stackTrace: stack);
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
    } catch (e, stack) {
      log.e('Error in clearCompleted: $e', error: e, stackTrace: stack);
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
    } catch (e, stack) {
      log.e('Error in uncompleteAll: $e', error: e, stackTrace: stack);
      state = AsyncValue.data(oldState);
    }
  }
}

