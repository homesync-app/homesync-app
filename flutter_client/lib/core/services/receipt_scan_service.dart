import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:homesync_client/features/expenses/domain/models/receipt_scan_result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de escaneo de tickets.
///
/// Flujo:
/// [scan] — pick imagen → comprimir → mandar base64 a Edge Function → OCR.
///
/// La imagen NO toca Supabase Storage. El OCR es efímero y la app persiste
/// únicamente datos estructurados del gasto.
class ReceiptScanService {
  final SupabaseClient _supabase;
  final _picker = ImagePicker();

  ReceiptScanService(this._supabase);

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
    final imageBytes = await imageFile.readAsBytes();

    debugPrint(
      '[ReceiptScan] Imagen comprimida: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB',
    );

    // 3. Convertir a base64 para mandar a la Edge Function
    final base64Image = base64Encode(imageBytes);

    // 4. Guardrail de tamaño: rechazar antes de invocar si el payload es muy grande.
    //    La Edge Function también valida, pero falla rápido en cliente es mejor UX.
    //    Base64 de 3.5 MB imagen ≈ ~4.7 MB de string. Rechazamos > 5 MB.
    const int maxBase64Bytes = 5 * 1024 * 1024;
    if (base64Image.length > maxBase64Bytes) {
      throw Exception(
        'La imagen es demasiado grande (${(imageBytes.length / 1024 / 1024).toStringAsFixed(1)} MB). '
        'Intentá con otra foto o desde galería.',
      );
    }

    // 5. Llamar a la Edge Function (OCR, sin tocar Storage)
    //
    //    El FunctionsClient del SDK cachea el Authorization header internamente
    //    y no lo actualiza dinámicamente como sí hace PostgREST. En modo
    debugPrint('[ReceiptScan] Getting Firebase ID token for Edge Function...');
    final accessToken =
        await fa.FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (accessToken == null) {
      throw Exception('Sesión expirada. Por favor iniciá sesión nuevamente.');
    }

    debugPrint('[ReceiptScan] Invocando Edge Function scan-receipt...');
    late final FunctionResponse response;
    try {
      response = await _supabase.functions.invoke(
        'scan-receipt',
        body: {
          'imageBase64': base64Image,
          'mimeType': 'image/webp',
        },
        headers: {'Authorization': 'Bearer $accessToken'},
      );
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
      rethrow;
    }

    debugPrint(
      '[ReceiptScan] Respuesta status=${response.status} data=${response.data}',
    );

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

    debugPrint(
      '[ReceiptScan] OCR ok merchant=${data['merchant']} amount=${data['amount']}',
    );
    return ReceiptScanResult.fromJson(data, imageFile.path);
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
      debugPrint('[ReceiptScan] Ticket no disponible: $e');
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

  @override
  String toString() {
    return 'Demasiados escaneos seguidos. Esperá unos segundos y volvé a intentar.';
  }
}
