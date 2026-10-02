import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/expenses/domain/models/receipt_scan_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de escaneo de tickets.
///
/// Flujo:
/// [scan] — capturar (escáner de documentos en Android, si no image_picker)
/// → comprimir → mandar bytes a Edge Function → OCR.
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
    // 1. Capturar imagen
    final picked = await _capture(source);
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
      final details = e.details;
      if (e.status == 429) {
        final retryAfter = details is Map
            ? (details['retryAfterSeconds'] as num?)?.toInt()
            : null;
        if (details is Map && details['error'] == 'daily_limit') {
          throw const ScanDailyLimitException();
        }
        throw ScanRateLimitException(retryAfterSeconds: retryAfter ?? 60);
      }
      if (e.status == 413) {
        throw ScanImageTooLargeException(
          sizeMb: imageBytes.length / 1024 / 1024,
        );
      }
      if (e.status == 401) throw const ScanAuthException();
      // 422 (la IA no devolvió datos legibles) y 502 (Gemini no respondió):
      // para el usuario es lo mismo, el ticket no se pudo leer.
      throw ScanFailedException(status: e.status);
    } on TimeoutException {
      throw const ScanTimeoutException();
    }

    log.d('[ReceiptScan] Respuesta status=${response.status}');


    final rawData = response.data;
    final responseData =
        rawData is Map<String, dynamic> ? rawData : const <String, dynamic>{};
    final data = responseData['data'] as Map<String, dynamic>?;
    if (response.status != 200 || data == null) {
      log.w('[ReceiptScan] Invalid response status=${response.status}');
      throw ScanFailedException(status: response.status);
    }

    log.d(
      '[ReceiptScan] OCR ok merchant=${data['merchant']} amount=${data['amount']}',
    );
    return ReceiptScanResult.fromJson(
      data,
      imageFile.path,
      logId: responseData['logId'] as String?,
      isDuplicate: responseData['duplicateScan'] as bool? ?? false,
      possibleDuplicate: switch (responseData['possibleDuplicate']) {
        final Map<String, dynamic> dup => PossibleDuplicateExpense.fromJson(dup),
        _ => null,
      },
    );
  }

  /// Cámara en Android: escáner de documentos de ML Kit (Google Play
  /// services). Detecta los bordes del ticket, lo recorta y lo endereza, así
  /// la resolución que ve Gemini se gasta en el ticket y no en la mesa. No
  /// pide permiso de cámara (la UI es de Play services).
  ///
  /// Si el escáner no está disponible (sin Play services, módulo que no se
  /// pudo bajar) cae a la cámara de image_picker. Galería: siempre
  /// image_picker (Android Photo Picker, sin permisos).
  Future<XFile?> _capture(ImageSource source) async {
    if (source == ImageSource.camera && Platform.isAndroid) {
      final scanner = DocumentScanner(
        options: DocumentScannerOptions(
          mode: ScannerMode.base,
          pageLimit: 1,
          documentFormats: const {DocumentFormat.jpeg},
        ),
      );
      try {
        final result = await scanner.scanDocument();
        final path = result.images?.firstOrNull;
        if (path != null) return XFile(path);
        return null;
      } on PlatformException catch (e) {
        if ((e.message ?? '').toLowerCase().contains('cancel')) return null;
        log.w('[ReceiptScan] Document scanner unavailable, falling back to camera', error: e);
      } finally {
        unawaited(scanner.close());
      }
    }
    return _picker.pickImage(
      source: source,
      // Sin achicar de más: un ticket largo en vertical quedaba en ~640 px de
      // ancho con el tope anterior de 1920 en el lado largo. La compresión a
      // WebP de abajo lo lleva a lado corto ≥1024.
      maxWidth: 2048,
      maxHeight: 4096,
      imageQuality: 90,
      requestFullMetadata:
          false, // usa Android Photo Picker sin pedir permisos de galería completa
    );
  }

  /// Recuerda cómo llama el hogar a este comercio (CUIT) para que el próximo
  /// ticket del mismo comercio venga con ese nombre y categoría. Best-effort.
  Future<void> rememberMerchant({
    required String taxId,
    required String title,
    String? category,
  }) async {
    try {
      await _supabase.rpc<void>(
        'remember_merchant_preference',
        params: {
          'p_tax_id': taxId,
          'p_title': title,
          'p_category': category,
        },
      );
    } catch (e, st) {
      log.w(
        '[ReceiptScan] remember_merchant_preference failed',
        error: e,
        stackTrace: st,
      );
    }
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

/// El servidor aplicó el techo diario de scans por usuario.
class ScanDailyLimitException implements Exception {
  const ScanDailyLimitException();
}

/// El ticket no se pudo leer: la IA no respondió (502) o no devolvió datos
/// usables (422). El mensaje al usuario es el mismo; [status] queda para logs.
class ScanFailedException implements Exception {
  final int status;

  const ScanFailedException({required this.status});

  @override
  String toString() => 'ScanFailedException(status: $status)';
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
