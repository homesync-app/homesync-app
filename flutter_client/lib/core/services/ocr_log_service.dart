import 'package:supabase_flutter/supabase_flutter.dart';

import 'logger_service.dart';

/// Actualiza el log de uso del OCR para análisis offline desde el panel admin.
///
/// La fila de `ocr_scan_logs` la inserta la Edge Function scan-receipt ANTES
/// de llamar a Gemini (sirve también de rate limit por intentos) y su id viaja
/// en la respuesta como `logId`. El cliente solo la completa con:
/// - Resultado del matcher (matched / to_add / unrecognized / dropped)
/// - Acción final del usuario (confirmed / cancelled)
///
/// Privacidad: NO se guardan imágenes ni datos personales más allá de los
/// nombres de productos del ticket. Solo admins pueden leer (RLS); el update
/// usa la sesión del usuario y la RLS exige user_id = current_app_user_id().
class OcrLogService {
  OcrLogService(this._client);

  final SupabaseClient _client;

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

  /// Registra la acción final del usuario y, al confirmar, los valores que
  /// realmente guardó en el gasto. Comparar final_amount contra ai_amount
  /// desde el panel admin mide la precisión real del OCR en el campo que
  /// más importa: un usuario que corrige el monto a mano en cada scan es un
  /// scan fallido aunque figure 'confirmed'.
  Future<void> updateUserAction({
    required String logId,
    required String action, // 'confirmed' | 'cancelled'
    double? finalAmount,
    String? finalCategory,
    bool? amountEdited,
  }) async {
    try {
      await _client.from('ocr_scan_logs').update({
        'user_action': action,
        if (finalAmount != null) 'final_amount': finalAmount,
        if (finalCategory != null) 'final_category': finalCategory,
        if (amountEdited != null) 'amount_edited': amountEdited,
      }).eq('id', logId);
    } catch (e, st) {
      log.e('[OcrLog] update action failed', error: e, stackTrace: st);
    }
  }
}
