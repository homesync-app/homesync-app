import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/dashboard/domain/models/love_note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';

class LoveNotesNotifier extends Notifier<List<LoveNoteModel>> {
  static const _storageKey = 'love_notes_storage';

  @override
  List<LoveNoteModel> build() {
    unawaited(_loadNotes());
    return [];
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      state = decoded.map((e) => LoveNoteModel.fromJson(e)).toList();
    }
  }

  Future<void> sendNote(String content, String fromId, String toId) async {
    // Solo si es Premium (doble verificación, aunque la UI ya lo bloquea)
    if (!(ref.read(premiumProvider).valueOrNull ?? false)) return;

    final note = LoveNoteModel(
      id: const Uuid().v4(),
      fromUserId: fromId,
      toUserId: toId,
      content: content,
      createdAt: DateTime.now(),
    );

    state = [note, ...state];
    await _saveNotes();
  }

  Future<void> markAsRead(String id) async {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n
    ];
    await _saveNotes();
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }
}

final loveNotesProvider =
    NotifierProvider<LoveNotesNotifier, List<LoveNoteModel>>(() {
  return LoveNotesNotifier();
});

final incomingLoveNotesProvider = Provider<List<LoveNoteModel>>((ref) {
  final notes = ref.watch(loveNotesProvider);
  // En un caso real, filtraríamos por toUserId == currentUserId
  // Para el demo, mostramos todas las que no son "mías" o simplemente todas las nuevas
  return notes.where((n) => !n.isRead).toList();
});
