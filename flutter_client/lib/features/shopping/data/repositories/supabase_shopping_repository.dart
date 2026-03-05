import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/shopping_model.dart';
import '../../domain/repositories/shopping_repository.dart';

class SupabaseShoppingRepository implements ShoppingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<ShoppingItemModel>> fetchItems(String householdId) async {
    final raw = await _client
        .from('shopping_items')
        .select(
            '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
        .eq('household_id', householdId)
        .order('completed', ascending: true)
        .order('created_at', ascending: false);

    return (raw as List)
        .map((e) => ShoppingItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<ShoppingItemModel> addItem({
    required String householdId,
    required String name,
    required String userId,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
  }) async {
    final raw = await _client
        .from('shopping_items')
        .insert({
          'household_id': householdId,
          'name': name.trim(),
          'quantity':
              quantity?.trim().isEmpty == true ? null : quantity?.trim(),
          'unit': unit?.trim().isEmpty == true ? null : unit?.trim(),
          'category': category,
          'emoji': emoji,
          'note': note?.trim().isEmpty == true ? null : note?.trim(),
          'added_by': userId,
          'completed': false,
        })
        .select(
            '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
        .single();

    return ShoppingItemModel.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  }) async {
    await _client.from('shopping_items').update({
      'completed': completed,
      'completed_by': completed ? userId : null,
      'completed_at': completed ? DateTime.now().toIso8601String() : null,
    }).eq('id', itemId);
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _client.from('shopping_items').delete().eq('id', itemId);
  }

  @override
  Future<void> clearCompleted(String householdId) async {
    await _client
        .from('shopping_items')
        .delete()
        .eq('household_id', householdId)
        .eq('completed', true);
  }

  @override
  Future<void> uncompleteAll(String householdId) async {
    await _client
        .from('shopping_items')
        .update({
          'completed': false,
          'completed_by': null,
          'completed_at': null,
        })
        .eq('household_id', householdId)
        .eq('completed', true);
  }
}
