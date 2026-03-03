import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/services/logger_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShoppingItem model
// ─────────────────────────────────────────────────────────────────────────────

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
    this.emoji = '🛒',
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
      emoji: map['emoji'] as String? ?? '🛒',
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

  ShoppingItem copyWith(
      {bool? completed, String? completedBy, DateTime? completedAt}) {
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

// ─────────────────────────────────────────────────────────────────────────────
// ShoppingService
// ─────────────────────────────────────────────────────────────────────────────

class ShoppingService {
  final _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  // ── Helpers ──────────────────────────────────────────────────────────────

  // Local event stream to notify other screens of completion instantly
  static final StreamController<void> _localChanges =
      StreamController<void>.broadcast();
  static Stream<void> get localChanges => _localChanges.stream;

  Future<String?> _getHouseholdId() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();
    return row?['household_id'] as String?;
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<List<ShoppingItem>> fetchItems() async {
    final householdId = await _getHouseholdId();
    if (householdId == null) return [];

    // Fetch items with user names joined
    final raw = await _client
        .from('shopping_items')
        .select(
            '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
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
    String emoji = '🛒',
    String? note,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

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
          'added_by': user.id,
          'completed': false,
        })
        .select(
            '*, added_by_user:users!added_by(full_name), completed_by_user:users!completed_by(full_name)')
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

  // ── Realtime ─────────────────────────────────────────────────────────────

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
    log.i('ShoppingService: Realtime subscribed for household $householdId');
  }

  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shopping categories
// ─────────────────────────────────────────────────────────────────────────────

class ShoppingCategories {
  static const List<Map<String, dynamic>> all = [
    {'id': 'general', 'name': 'General', 'emoji': '🛒', 'color': 0xFF6366F1},
    {
      'id': 'fruits',
      'name': 'Frutas y verd.',
      'emoji': '🥦',
      'color': 0xFF22C55E
    },
    {'id': 'meat', 'name': 'Carnes', 'emoji': '🥩', 'color': 0xFFEF4444},
    {'id': 'dairy', 'name': 'Lácteos', 'emoji': '🥛', 'color': 0xFF3B82F6},
    {'id': 'bakery', 'name': 'Panadería', 'emoji': '🍞', 'color': 0xFFF59E0B},
    {'id': 'pantry', 'name': 'Despensa', 'emoji': '🥫', 'color': 0xFFD97706},
    {'id': 'frozen', 'name': 'Congelados', 'emoji': '🧊', 'color': 0xFF0284C7},
    {'id': 'cleaning', 'name': 'Limpieza', 'emoji': '🧴', 'color': 0xFF8B5CF6},
    {'id': 'drinks', 'name': 'Bebidas', 'emoji': '🧃', 'color': 0xFF06B6D4},
    {'id': 'snacks', 'name': 'Snacks', 'emoji': '🍫', 'color': 0xFFEC4899},
    {'id': 'pharmacy', 'name': 'Farmacia', 'emoji': '💊', 'color': 0xFF10B981},
    {'id': 'pets', 'name': 'Mascotas', 'emoji': '🐕', 'color': 0xFFA16207},
  ];

  static String emojiFor(String id) =>
      all.firstWhere((c) => c['id'] == id, orElse: () => all.first)['emoji']
          as String;

  static String nameFor(String id) =>
      all.firstWhere((c) => c['id'] == id, orElse: () => all.first)['name']
          as String;

  static int colorFor(String id) =>
      all.firstWhere((c) => c['id'] == id, orElse: () => all.first)['color']
          as int;
}
