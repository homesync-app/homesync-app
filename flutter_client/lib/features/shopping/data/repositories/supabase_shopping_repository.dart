import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/repository_error_handler.dart';
import '../../domain/models/shopping_model.dart';
import '../../domain/repositories/shopping_repository.dart';

class SupabaseShoppingRepository
    with RepositoryErrorHandler
    implements ShoppingRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final Ref _ref;

  SupabaseShoppingRepository({required Ref ref}) : _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  @override
  Future<Either<Failure, List<ShoppingItemModel>>> fetchItems(
      String householdId) async {
    return executeWithHandling(() async {
      final response = await _client
          .from('shopping_items')
          .select(
              '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
          .eq('household_id', householdId)
          .order('completed', ascending: true)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((e) => ShoppingItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return items;
    }, context: 'SupabaseShoppingRepository.fetchItems', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, ShoppingItemModel>> addItem({
    required String householdId,
    required String name,
    required String userId,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '🛒',
    String? note,
  }) async {
    return executeWithHandling(() async {
      final response = await _client
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

      return ShoppingItemModel.fromJson(Map<String, dynamic>.from(response));
    }, context: 'SupabaseShoppingRepository.addItem', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  }) async {
    return executeWithHandling(() async {
      await _client.from('shopping_items').update({
        'completed': completed,
        'completed_by': completed ? userId : null,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      }).eq('id', itemId);
    }, context: 'SupabaseShoppingRepository.toggleItem', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    return executeWithHandling(() async {
      await _client.from('shopping_items').delete().eq('id', itemId);
    }, context: 'SupabaseShoppingRepository.deleteItem', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> clearCompleted(String householdId) async {
    return executeWithHandling(() async {
      await _client
          .from('shopping_items')
          .delete()
          .eq('household_id', householdId)
          .eq('completed', true);
    }, context: 'SupabaseShoppingRepository.clearCompleted', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> uncompleteAll(String householdId) async {
    return executeWithHandling(() async {
      await _client
          .from('shopping_items')
          .update({
            'completed': false,
            'completed_by': null,
            'completed_at': null,
          })
          .eq('household_id', householdId)
          .eq('completed', true);
    }, context: 'SupabaseShoppingRepository.uncompleteAll', isOnline: _isOnline);
  }
}
