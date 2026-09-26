import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/dashboard/domain/models/love_note_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoveNotesNotifier extends AsyncNotifier<List<LoveNoteModel>> {
  RealtimeChannel? _channel;

  SupabaseClient get _supabase => ref.read(supabaseClientProvider);

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
            // Un payload con forma inesperada no debe tirar una excepcion no
            // capturada en el zone del canal realtime.
            try {
              final newNote = LoveNoteModel.fromJson(payload.newRecord);
              state = AsyncData([newNote, ...state.value ?? []]);
            } catch (error, stackTrace) {
              log.w(
                'love_notes realtime payload invalido',
                error: error,
                stackTrace: stackTrace,
              );
            }
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    return notes;
  }

  /// Largo máximo de una nota: entra entera en el sobre sin scroll.
  static const int maxLength = 280;

  /// Envía una nota a la pareja. Es gratis: es el gesto más chico que la app
  /// ofrece para cuidar el vínculo, y cobrarlo lo volvía invisible.
  ///
  /// [pushTitle] y [pushBody] llegan ya localizados desde la UI. Si falla el
  /// insert, el error sube para que la UI lo muestre; el push es best-effort.
  Future<void> sendNote({
    required String content,
    required String fromUserId,
    required String toUserId,
    required String householdId,
    required String pushTitle,
    required String pushBody,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    await _supabase.from('love_notes').insert({
      'household_id': householdId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'content': trimmed.length > maxLength
          ? trimmed.substring(0, maxLength)
          : trimmed,
    });

    // Push al partner (fallback si la app está cerrada). No bloquea el envío.
    try {
      final notifService = ref.read(notificationServiceProvider);
      await notifService.notifyMember(
        toUserId: toUserId,
        title: pushTitle,
        body: pushBody,
        type: 'love_note',
      );
    } catch (error, stackTrace) {
      log.w(
        'love note push failed',
        error: error,
        stackTrace: stackTrace,
      );
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
