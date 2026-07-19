import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/expenses/domain/models/receipt_scan_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de escaneo de tickets.
///
/// Flujo:
/// [scan] — pick imagen → comprimir → mandar bytes a Edge Function → OCR.
///
/// La imagen NO toca Supabase Storage. El OCR es efímero y la app persiste
/// únicamente datos estructurados del gasto.
class ReceiptScanService {
  final SupabaseClient _supabase;
  final _picker = ImagePicker();

  ReceiptScanService(this._supabase);

  /// Límite de imagen comprimida: 5 MB de bytes crudos (igual que el servidor).
  static const int _maxImageBytes = 5 * 1024 * 1024;

  /// Timeout de extremo a extremo del invoke (la Edge Function ya tiene sus
  /// propios timeouts internos contra Gemini; esto cubre red móvil colgada).
  static const Duration _invokeTimeout = Duration(seconds: 60);

  /// Escanea un ticket y devuelve el resultado del OCR.
  /// [source] puede ser [ImageSource.camera] o [ImageSource.gallery].
  /// Devuelve null si el usuario canceló.
  Future<ReceiptScanResult?> scan({required ImageSource source}) async {
    // 1. Pick imagen
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
      requestFullMetadata:
          false, // usa Android Photo Picker sin pedir permisos de galería completa
    );
    if (picked == null) return null;

    // 2. Comprimir agresivamente a WebP ~60-120 KB
    //    El OCR de Gemini funciona bien con esta resolución.
    final tempPath = '${picked.path}_receipt.webp';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      tempPath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 70,
      format: CompressFormat.webp,
    );

    final XFile imageFile = compressed ?? picked;
    final Uint8List imageBytes;
    try {
      imageBytes = await imageFile.readAsBytes();
    } finally {
      // El WebP temporal ya no se necesita en disco una vez leído; sin esto se
      // acumulan en el cache dir hasta que el OS decida limpiarlo.
      if (compressed != null && compressed.path != picked.path) {
        try {
          await File(compressed.path).delete();
        } catch (_) {
          // Best-effort: si no se pudo borrar, el OS limpia el cache dir.
        }
      }
    }

    log.d(
      '[ReceiptScan] Imagen comprimida: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB',
    );

    // 3. Guardrail de tamaño: rechazar antes de invocar si el payload es muy
    //    grande. La Edge Function también valida (413), pero fallar rápido en
    //    cliente es mejor UX. Mismo límite que el servidor: 5 MB crudos.
    if (imageBytes.length > _maxImageBytes) {
      throw ScanImageTooLargeException(
        sizeMb: imageBytes.length / 1024 / 1024,
      );
    }

    // 4. Llamar a la Edge Function (OCR, sin tocar Storage)
    //
    //    El FunctionsClient del SDK cachea el Authorization header internamente
    //    y no lo actualiza dinámicamente como sí hace PostgREST, por eso lo
    //    pasamos explícito. getIdToken() SIN forzar refresh: el SDK de Firebase
    //    devuelve el token cacheado si sigue válido y solo renueva cuando
    //    expira — forzarlo agregaba un round-trip (~300-500 ms) a cada scan.
    final accessToken = await fa.FirebaseAuth.instance.currentUser?.getIdToken();
    if (accessToken == null) {
      throw const ScanAuthException();
    }

    // Fecha local del dispositivo: a las 22:00 de Argentina, UTC ya es
    // "mañana". El servidor la usa como referencia de "hoy" para el prompt y
    // la validación de fecha del ticket.
    final now = DateTime.now();
    final todayLocal = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    log.d('[ReceiptScan] Invocando Edge Function scan-receipt...');
    late final FunctionResponse response;
    try {
      // Bytes crudos (application/octet-stream): evita el 33% de overhead de
      // base64-en-JSON en el upload desde red móvil.
      response = await _supabase.functions
          .invoke(
            'scan-receipt',
            body: imageBytes,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'x-mime-type': 'image/webp',
              'x-today-local': todayLocal,
            },
          )
          .timeout(_invokeTimeout);
    } on FunctionException catch (e) {
      // El SDK lanza FunctionException para respuestas no-2xx antes de que
      // podamos ver response.status. El 429 acá es el anti-abuso liviano del
      // servidor (no un límite por tier: el OCR es gratis para todos).
      if (e.status == 429) {
        final details = e.details;
        final retryAfter = details is Map
            ? (details['retryAfterSeconds'] as num?)?.toInt()
            : null;
        throw ScanRateLimitException(retryAfterSeconds: retryAfter ?? 60);
      }
      if (e.status == 413) {
        throw ScanImageTooLargeException(
          sizeMb: imageBytes.length / 1024 / 1024,
        );
      }
      rethrow;
    } on TimeoutException {
      throw const ScanTimeoutException();
    }

    log.d('[ReceiptScan] Respuesta status=${response.status}');

    if (response.status != 200 || response.data == null) {
      throw Exception(
        'Error en el escaneo (status ${response.status}): ${response.data}',
      );
    }

    final responseData = response.data as Map<String, dynamic>;
    final data = responseData['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception(
        'Respuesta inválida del servidor de OCR: ${response.data}',
      );
    }

    log.d(
      '[ReceiptScan] OCR ok merchant=${data['merchant']} amount=${data['amount']}',
    );
    return ReceiptScanResult.fromJson(
      data,
      imageFile.path,
      logId: responseData['logId'] as String?,
      isDuplicate: responseData['duplicateScan'] as bool? ?? false,
    );
  }

  /// Genera una URL firmada de corta duración para mostrar el ticket en UI.
  ///
  /// Compatibilidad para tickets ya guardados antes del cambio de política.
  /// No persistir esta URL. Siempre generarla fresh al abrir el detalle.
  /// [expiresIn] en segundos (default: 1 hora).
  Future<String?> getSignedUrl(
    String receiptPath, {
    int expiresIn = 3600,
  }) async {
    try {
      final signedUrl = await _supabase.storage
          .from('receipts')
          .createSignedUrl(receiptPath, expiresIn);
      return signedUrl;
    } catch (e) {
      // El archivo puede haber vencido (>60 días) — devolver null es correcto.
      log.w('[ReceiptScan] Ticket no disponible', error: e);
      return null;
    }
  }
}

/// Excepción lanzada cuando el servidor aplica el anti-abuso de scans.
///
/// NO es un límite por plan (el OCR es gratis para todos). Es un freno corto
/// para evitar que un usuario loopee el endpoint pago de Gemini. El usuario
/// puede reintentar pasados [retryAfterSeconds].
class ScanRateLimitException implements Exception {
  final int retryAfterSeconds;

  const ScanRateLimitException({required this.retryAfterSeconds});
}

/// La imagen comprimida supera el límite de 5 MB (cliente o servidor 413).
class ScanImageTooLargeException implements Exception {
  final double sizeMb;

  const ScanImageTooLargeException({required this.sizeMb});
}

/// No hay sesión de Firebase activa (token null).
class ScanAuthException implements Exception {
  const ScanAuthException();
}

/// El invoke superó el timeout de extremo a extremo (red móvil colgada).
class ScanTimeoutException implements Exception {
  const ScanTimeoutException();
}
