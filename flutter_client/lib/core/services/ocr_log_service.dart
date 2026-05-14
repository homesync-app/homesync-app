import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Logger de uso del OCR para análisis offline desde el panel admin.
///
/// Captura, por cada scan:
/// - Items crudos devueltos por la IA
/// - Resultado del matcher (matched / to_add / unrecognized / dropped)
/// - Acción final del usuario (confirmed / cancelled)
///
/// Privacidad: NO guarda imágenes ni datos personales más allá de los
/// nombres de productos del ticket. Se inserta con la sesión del usuario,
/// solo admins pueden leer (RLS).
class OcrLogService {
  OcrLogService(this._client);

  final SupabaseClient _client;

  /// Inserta una fila inicial con la respuesta de la IA. Devuelve el id
  /// del log, que se usa para los subsiguientes updates. Falla silenciosa:
  /// si el insert no funciona, simplemente no hay tracking, sin romper UX.
  Future<String?> logScan({
    required String? merchant,
    required double? confidence,
    required List<String> rawItems,
    required String? householdId,
    required String tier,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final inserted = await _client
          .from('ocr_scan_logs')
          .insert({
            'user_id': userId,
            'household_id': householdId,
            'ai_merchant': merchant,
            'ai_confidence': confidence,
            'ai_raw_items': rawItems,
            'tier': tier,
          })
          .select('id')
          .single();
      return inserted['id'] as String?;
    } catch (e) {
      debugPrint('[OcrLog] insert failed: $e');
      return null;
    }
  }

  Future<void> updateMatcherResult({
    required String logId,
    required Map<String, dynamic> matcherResult,
  }) async {
    try {
      await _client
          .from('ocr_scan_logs')
          .update({'matcher_result': matcherResult}).eq('id', logId);
    } catch (e) {
      debugPrint('[OcrLog] update matcher failed: $e');
    }
  }

  Future<void> updateUserAction({
    required String logId,
    required String action, // 'confirmed' | 'cancelled'
  }) async {
    try {
      await _client
          .from('ocr_scan_logs')
          .update({'user_action': action}).eq('id', logId);
    } catch (e) {
      debugPrint('[OcrLog] update action failed: $e');
    }
  }
}
