import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/shopping_service.dart'; // Reuse ShoppingItem model

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(Supabase.instance.client);
});

class ShoppingRepository {
  final SupabaseClient _client;

  ShoppingRepository(this._client);

  Future<List<ShoppingItem>> fetchItems(String householdId) async {
    final raw = await _client
        .from('shopping_items')
        .select('*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
        .eq('household_id', householdId)
        .order('completed', ascending: true)
        .order('created_at', ascending: false);

    return (raw as List)
        .map((e) => ShoppingItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ShoppingItem> addItem({
    required String householdId,
    required String name,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final raw = await _client
        .from('shopping_items')
        .insert({
          'household_id': householdId,
          'name': name.trim(),
          'quantity': quantity?.trim().isEmpty == true ? null : quantity?.trim(),
          'unit': unit?.trim().isEmpty == true ? null : unit?.trim(),
          'category': category,
          'emoji': emoji,
          'note': note?.trim().isEmpty == true ? null : note?.trim(),
          'added_by': user.id,
          'completed': false,
        })
        .select('*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
        .single();

    return ShoppingItem.fromMap(Map<String, dynamic>.from(raw));
  }

  Future<void> toggleItem(String itemId, bool completed) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('shopping_items').update({
      'completed': completed,
      'completed_by': completed ? user.id : null,
      'completed_at': completed ? DateTime.now().toIso8601String() : null,
    }).eq('id', itemId);
  }

  Future<void> deleteItem(String itemId) async {
    await _client.from('shopping_items').delete().eq('id', itemId);
  }
}
