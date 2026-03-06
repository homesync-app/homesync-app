import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// --- Repositories & Use Cases ---

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return SupabaseShoppingRepository(ref: ref);
});

final getShoppingItemsUseCaseProvider =
    Provider<GetShoppingItemsUseCase>((ref) {
  return GetShoppingItemsUseCase(ref.watch(shoppingRepositoryProvider));
});

final addShoppingItemUseCaseProvider = Provider<AddShoppingItemUseCase>((ref) {
  return AddShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
});

final toggleShoppingItemUseCaseProvider =
    Provider<ToggleShoppingItemUseCase>((ref) {
  return ToggleShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
});

final deleteShoppingItemUseCaseProvider =
    Provider<DeleteShoppingItemUseCase>((ref) {
  return DeleteShoppingItemUseCase(ref.watch(shoppingRepositoryProvider));
});

final clearCompletedShoppingItemsUseCaseProvider =
    Provider<ClearCompletedShoppingItemsUseCase>((ref) {
  return ClearCompletedShoppingItemsUseCase(
      ref.watch(shoppingRepositoryProvider));
});

final uncompleteAllShoppingItemsUseCaseProvider =
    Provider<UncompleteAllShoppingItemsUseCase>((ref) {
  return UncompleteAllShoppingItemsUseCase(
      ref.watch(shoppingRepositoryProvider));
});

// --- Realtime Streams Setup (Optional future refactor, but for now we'll do AsyncNotifier) ---

final shoppingItemsProvider =
    AsyncNotifierProvider<ShoppingItemsNotifier, List<ShoppingItemModel>>(() {
  return ShoppingItemsNotifier();
});

class ShoppingItemsNotifier extends AsyncNotifier<List<ShoppingItemModel>> {
  RealtimeChannel? _channel;

  @override
  Future<List<ShoppingItemModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

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
            _refresh();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    final getItems = ref.watch(getShoppingItemsUseCaseProvider);
    final result = await getItems.execute(householdId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }

  Future<void> _refresh() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (items) => items,
      );
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

    if (householdId == null || userId == null) {
      throw Exception('Authentication or Household required');
    }

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
      final result = await ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (items) => items,
      );
    });
  }

  Future<void> toggleItem(String itemId, bool completed) async {
    final householdId = await ref.read(householdIdProvider.future);
    final userId = ref.read(currentUserIdProvider);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(toggleShoppingItemUseCaseProvider).execute(
            itemId: itemId,
            completed: completed,
            userId: userId,
          );
      final result = await ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (items) => items,
      );
    });
  }

  Future<void> deleteItem(String itemId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteShoppingItemUseCaseProvider).execute(itemId);
      final result = await ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (items) => items,
      );
    });
  }

  Future<void> clearCompleted() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(clearCompletedShoppingItemsUseCaseProvider)
          .execute(householdId);
      final result = await ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (items) => items,
      );
    });
  }

  Future<void> uncompleteAll() async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(uncompleteAllShoppingItemsUseCaseProvider)
          .execute(householdId);
      final result = await ref.read(getShoppingItemsUseCaseProvider).execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (items) => items,
      );
    });
  }
}
