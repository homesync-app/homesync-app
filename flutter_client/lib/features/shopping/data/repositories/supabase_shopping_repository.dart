import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/offline/offline_action.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/config/app_environment.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/repository_error_handler.dart';
import '../../domain/models/shopping_model.dart';
import '../../domain/repositories/shopping_repository.dart';
import 'package:uuid/uuid.dart';

class SupabaseShoppingRepository
    with RepositoryErrorHandler
    implements ShoppingRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final Ref _ref;
  final OfflineQueueService _offlineQueue = OfflineQueueService();
  static const Uuid _uuid = Uuid();

  SupabaseShoppingRepository({required Ref ref}) : _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);
  bool get _isAdminTestingActive {
    final admin = _ref.read(adminProvider);
    return AppEnvironment.enableAdminTesting &&
        admin.isAdminUser &&
        admin.selectedHouseholdId != null;
  }

  Future<void> _queueAction(OfflineAction action) async {
    await _offlineQueue.enqueueAction(
      actionType: action.type,
      payload: action.toMap(),
    );
  }

  @override
  Future<Either<Failure, List<ShoppingItemModel>>> fetchItems(
      String householdId) async {
    return executeWithHandling(() async {
      final response = await _fetchItemsResponse(householdId);

      final items = (response as List)
          .map((e) => ShoppingItemModel.fromJson(_mapShoppingRow(e)))
          .toList();
      log.i(
        'ShoppingRepository.fetchItems household=$householdId count=${items.length} adminQa=$_isAdminTestingActive',
      );
      return items;
    }, context: 'SupabaseShoppingRepository.fetchItems', isOnline: _isOnline);
  }

  Future<dynamic> _fetchItemsResponse(String householdId) async {
    if (!_isAdminTestingActive) {
      return _fetchItemsDirect(householdId);
    }

    try {
      return await _client.rpc(
        'qa_admin_get_shopping_items',
        params: {'p_household_id': householdId},
      );
    } on PostgrestException catch (error) {
      if (_isMissingShouldSyncColumn(error)) {
        log.w(
          'ShoppingRepository.fetchItems QA RPC fallback household=$householdId reason=${error.message}',
        );
        return _fetchItemsDirect(householdId);
      }
      rethrow;
    }
  }

  Future<dynamic> _fetchItemsDirect(String householdId) {
    return _client
        .from('shopping_items')
        .select(
            '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
        .eq('household_id', householdId)
        .order('completed', ascending: true)
        .order('created_at', ascending: false);
  }

  bool _isMissingShouldSyncColumn(PostgrestException error) {
    return error.code == '42703' && error.message.contains('should_sync');
  }

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
    return executeWithHandling(() async {
      final itemId = clientId ?? _uuid.v4();
      final response = _isAdminTestingActive
          ? await _client.rpc(
              'qa_admin_add_shopping_item',
              params: {
                'p_id': itemId,
                'p_household_id': householdId,
                'p_name': name.trim(),
                'p_added_by': userId,
                'p_quantity':
                    quantity?.trim().isEmpty == true ? null : quantity?.trim(),
                'p_unit': unit?.trim().isEmpty == true ? null : unit?.trim(),
                'p_category': category,
                'p_emoji': emoji,
                'p_note': note?.trim().isEmpty == true ? null : note?.trim(),
              },
            )
          : await _client
              .from('shopping_items')
              .insert({
                'id': itemId,
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

      final mapped = response is List ? _mapShoppingRow(response.first) : _mapShoppingRow(response);
      log.i(
        'ShoppingRepository.addItem household=$householdId name=$name adminQa=$_isAdminTestingActive',
      );
      return ShoppingItemModel.fromJson(mapped);
    },
        context: 'SupabaseShoppingRepository.addItem',
        isOnline: _isOnline,
        onOffline: () async {
          final itemId = clientId ?? _uuid.v4();
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableInsert,
              target: 'shopping_items',
              values: {
                'id': itemId,
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
              },
            ),
          );
          return ShoppingItemModel(
            id: itemId,
            householdId: householdId,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            emoji: emoji,
            note: note,
            addedBy: userId,
            completed: false,
            createdAt: DateTime.now(),
            shouldSync: true,
          );
        });
  }

  @override
  Future<Either<Failure, void>> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  }) async {
    return executeWithHandling(() async {
      if (_isAdminTestingActive) {
        final householdId = await _resolveHouseholdIdForItem(itemId);
        if (householdId == null) {
          throw Exception('No pudimos resolver el hogar QA del item');
        }
        await _client.rpc(
          'qa_admin_toggle_shopping_item',
          params: {
            'p_item_id': itemId,
            'p_household_id': householdId,
            'p_completed': completed,
            'p_user_id': userId,
          },
        );
      } else {
        await _client.from('shopping_items').update({
          'completed': completed,
          'completed_by': completed ? userId : null,
          'completed_at': completed ? DateTime.now().toIso8601String() : null,
        }).eq('id', itemId);
      }
    },
        context: 'SupabaseShoppingRepository.toggleItem',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: 'shopping_items',
              values: {
                'completed': completed,
                'completed_by': completed ? userId : null,
                'completed_at': completed ? DateTime.now().toIso8601String() : null,
              },
              filters: [OfflineFilter(column: 'id', value: itemId)],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    return executeWithHandling(() async {
      if (_isAdminTestingActive) {
        final householdId = await _resolveHouseholdIdForItem(itemId);
        if (householdId == null) {
          throw Exception('No pudimos resolver el hogar QA del item');
        }
        await _client.rpc(
          'qa_admin_delete_shopping_item',
          params: {'p_item_id': itemId, 'p_household_id': householdId},
        );
      } else {
        await _client.from('shopping_items').delete().eq('id', itemId);
      }
    },
        context: 'SupabaseShoppingRepository.deleteItem',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableDelete,
              target: 'shopping_items',
              filters: [OfflineFilter(column: 'id', value: itemId)],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> clearCompleted(String householdId) async {
    return executeWithHandling(() async {
      if (_isAdminTestingActive) {
        await _client.rpc(
          'qa_admin_clear_completed_shopping_items',
          params: {'p_household_id': householdId},
        );
      } else {
        await _client
            .from('shopping_items')
            .delete()
            .eq('household_id', householdId)
            .eq('completed', true);
      }
    },
        context: 'SupabaseShoppingRepository.clearCompleted',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableDelete,
              target: 'shopping_items',
              filters: [
                OfflineFilter(column: 'household_id', value: householdId),
                const OfflineFilter(column: 'completed', value: true),
              ],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> uncompleteAll(String householdId) async {
    return executeWithHandling(() async {
      if (_isAdminTestingActive) {
        await _client.rpc(
          'qa_admin_uncomplete_all_shopping_items',
          params: {'p_household_id': householdId},
        );
      } else {
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
    },
        context: 'SupabaseShoppingRepository.uncompleteAll',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: 'shopping_items',
              values: {
                'completed': false,
                'completed_by': null,
                'completed_at': null,
              },
              filters: [
                OfflineFilter(column: 'household_id', value: householdId),
                const OfflineFilter(column: 'completed', value: true),
              ],
            ),
          );
        });
  }

  Map<String, dynamic> _mapShoppingRow(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    if (map.containsKey('added_by_user') || map.containsKey('completed_by_user')) {
      return map;
    }

    return {
      'id': map['id'],
      'household_id': map['household_id'],
      'name': map['name'],
      'quantity': map['quantity'],
      'unit': map['unit'],
      'category': map['category'],
      'emoji': map['emoji'],
      'note': map['note'],
      'added_by': map['added_by'],
      'completed': map['completed'],
      'completed_by': map['completed_by'],
      'completed_at': map['completed_at'],
      'created_at': map['created_at'],
      'should_sync': map['should_sync'] ?? true,
      'added_by_user': {'full_name': map['added_by_name']},
      'completed_by_user': {'full_name': map['completed_by_name']},
    };
  }

  Future<String?> _resolveHouseholdIdForItem(String itemId) async {
    final admin = _ref.read(adminProvider);
    return admin.selectedHouseholdId;
  }
}
