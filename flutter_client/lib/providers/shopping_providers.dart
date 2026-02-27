import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/repositories/shopping_repository.dart';
import 'package:homesync_client/services/shopping_service.dart';
import 'package:homesync_client/providers/core_providers.dart';

final shoppingItemsProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return [];
  
  final repo = ref.read(shoppingRepositoryProvider);
  return repo.fetchItems(householdId);
});
