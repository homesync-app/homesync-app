import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/features/dashboard/domain/models/love_note_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoveNotesNotifier extends AsyncNotifier<List<LoveNoteModel>> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  @override
  Future<List<LoveNoteModel>> build() async {
    final currentUserId = ref.watch(currentUserIdProvider);
    if (currentUserId == null) return [];

    // Cargar notas no leídas dirigidas al usuario actual
    final rows = await _supabase
        .from('love_notes')
        .select()
        .eq('to_user_id', currentUserId)
        .eq('is_read', false)
        .order('created_at', ascending: false)
        .limit(10);

    final notes = (rows as List)
        .map((e) => LoveNoteModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Suscripción realtime: llega nota nueva al usuario actual
    _channel?.unsubscribe();
    _channel = _supabase
        .channel('love_notes:$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'love_notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'to_user_id',
            value: currentUserId,
          ),
          callback: (payload) {
            final newNote = LoveNoteModel.fromJson(payload.newRecord);
            state = AsyncData([newNote, ...state.value ?? []]);
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    return notes;
  }

  /// Envía una nota de amor al partner.
  /// Requiere premium (doble verificación además de la UI).
  Future<void> sendNote({
    required String content,
    required String fromUserId,
    required String toUserId,
    required String householdId,
  }) async {
    if (!(ref.read(premiumProvider).value ?? false)) return;
    if (content.trim().isEmpty) return;

    await _supabase.from('love_notes').insert({
      'household_id': householdId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'content': content.trim(),
    });

    // Push notification al partner (fallback si la app está cerrada)
    try {
      final notifService = ref.read(notificationServiceProvider);
      await notifService.notifyMember(
        toUserId: toUserId,
        title: '💌 Tenés una nota especial',
        body: 'Tu pareja te mandó una nota de amor ❤️',
        type: 'love_note',
      );
    } catch (_) {
      // No bloquear si falla la notificación
    }
  }

  /// Marca la nota como leída en Supabase y la saca del estado local.
  Future<void> markAsRead(String id) async {
    await _supabase.from('love_notes').update({'is_read': true}).eq('id', id);

    state = AsyncData(
      (state.value ?? []).where((n) => n.id != id).toList(),
    );
  }
}

final loveNotesProvider =
    AsyncNotifierProvider<LoveNotesNotifier, List<LoveNoteModel>>(
  LoveNotesNotifier.new,
);

/// Primera nota no leída para el usuario actual (la que muestra el sobre).
final pendingLoveNoteProvider = Provider<LoveNoteModel?>((ref) {
  return ref.watch(loveNotesProvider).value?.firstOrNull;
});
