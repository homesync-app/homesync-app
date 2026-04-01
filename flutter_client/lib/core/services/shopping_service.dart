import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/config/app_environment.dart';

class ShoppingItem {
  final String id;
  final String householdId;
  final String name;
  final String? quantity;
  final String? unit;
  final String category;
  final String emoji;
  final String? note;
  final String? addedBy;
  final String? addedByName;
  final bool completed;
  final String? completedBy;
  final String? completedByName;
  final DateTime? completedAt;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.householdId,
    required this.name,
    this.quantity,
    this.unit,
    this.category = 'general',
    this.emoji = '??',
    this.note,
    this.addedBy,
    this.addedByName,
    this.completed = false,
    this.completedBy,
    this.completedByName,
    this.completedAt,
    required this.createdAt,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String,
      householdId: map['household_id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as String?,
      unit: map['unit'] as String?,
      category: map['category'] as String? ?? 'general',
      emoji: map['emoji'] as String? ?? '??',
      note: map['note'] as String?,
      addedBy: map['added_by'] as String?,
      addedByName: (map['added_by_user'] as Map?)?['full_name'] as String?,
      completed: map['completed'] as bool? ?? false,
      completedBy: map['completed_by'] as String?,
      completedByName:
          (map['completed_by_user'] as Map?)?['full_name'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get displayQuantity {
    if (quantity == null && unit == null) return '';
    if (unit == null) return quantity!;
    return '$quantity $unit';
  }

  String get addedByDisplay {
    if (addedByName == null) return '';
    return addedByName!.split(' ').first;
  }

  String get completedByDisplay {
    if (completedByName == null) return '';
    return completedByName!.split(' ').first;
  }

  ShoppingItem copyWith({
    bool? completed,
    String? completedBy,
    DateTime? completedAt,
  }) {
    return ShoppingItem(
      id: id,
      householdId: householdId,
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      emoji: emoji,
      note: note,
      addedBy: addedBy,
      addedByName: addedByName,
      completed: completed ?? this.completed,
      completedBy: completedBy ?? this.completedBy,
      completedByName: completedByName,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}

class ShoppingService {
  ShoppingService({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  static final StreamController<void> _localChanges =
      StreamController<void>.broadcast();
  static Stream<void> get localChanges => _localChanges.stream;

  Future<String?> _getCurrentUserId() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }
    if (!AppEnvironment.usesFirebaseJwtForSupabase) {
      return _client.auth.currentUser?.id;
    }
    return null;
  }

  Future<String?> _getHouseholdId() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return null;
    final row = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();
    return row?['household_id'] as String?;
  }

  Future<List<ShoppingItem>> fetchItems() async {
    final householdId = await _getHouseholdId();
    if (householdId == null) return [];

    final raw = await _client
        .from('shopping_items')
        .select(
          '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)',
        )
        .eq('household_id', householdId)
        .order('completed', ascending: true)
        .order('created_at', ascending: false);

    return (raw as List)
        .map((e) => ShoppingItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ShoppingItem> addItem({
    required String name,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = '??',
    String? note,
  }) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception('No autenticado');

    final householdId = await _getHouseholdId();
    if (householdId == null) throw Exception('Sin hogar');

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
          '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)',
        )
        .single();

    return ShoppingItem.fromMap(Map<String, dynamic>.from(raw));
  }

  Future<void> toggleItem(String itemId, bool completed) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;

    await _client.from('shopping_items').update({
      'completed': completed,
      'completed_by': completed ? userId : null,
      'completed_at': completed ? DateTime.now().toIso8601String() : null,
    }).eq('id', itemId);

    _localChanges.add(null);
  }

  Future<void> deleteItem(String itemId) async {
    await _client.from('shopping_items').delete().eq('id', itemId);
  }

  Future<void> clearCompleted(String householdId) async {
    final id = await _getHouseholdId() ?? householdId;
    await _client
        .from('shopping_items')
        .delete()
        .eq('household_id', id)
        .eq('completed', true);
  }

  Future<void> uncompleteAll() async {
    final householdId = await _getHouseholdId();
    if (householdId == null) return;
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

  Future<void> subscribeToChanges({
    required String householdId,
    required VoidCallback onChanged,
  }) async {
    await _channel?.unsubscribe();
    _channel = _client
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
          callback: (_) => onChanged(),
        )
        .subscribe();
    log.i('ShoppingService: realtime subscribed for household $householdId');
  }

  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
