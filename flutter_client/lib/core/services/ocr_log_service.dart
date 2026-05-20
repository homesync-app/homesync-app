import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_identity_service.dart';
import 'logger_service.dart';

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
      // OJO: NO usar _client.auth.currentUser?.id. Bajo el bridge de Firebase
      // third-party auth eso devuelve el Firebase UID (sub del JWT), NO el
      // users.id interno de la app. La RLS de ocr_scan_logs chequea
      // current_app_user_id() y rechazaba todos los inserts en silencio.
      final userId = await AppIdentityService.instance.refresh();
      if (userId == null || userId.isEmpty) return null;

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
    } catch (e, st) {
      // log.e va a Crashlytics; debugPrint era invisible en release.
      log.e('[OcrLog] insert failed', error: e, stackTrace: st);
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
    } catch (e, st) {
      log.e('[OcrLog] update matcher failed', error: e, stackTrace: st);
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
    } catch (e, st) {
      log.e('[OcrLog] update action failed', error: e, stackTrace: st);
    }
  }
}
