import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:homesync_client/features/expenses/domain/models/receipt_scan_result.dart';

/// Servicio de escaneo de tickets.
///
/// Flujo:
/// 1. [scan] — pick imagen → comprimir → mandar base64 a Edge Function → OCR
/// 2. [uploadReceipt] — subir a Storage solo cuando el usuario confirma el gasto
///
/// La imagen NO toca Supabase Storage hasta confirmar. Así no acumulamos
/// basura de escaneos cancelados y el storage se mantiene limpio.
class ReceiptScanService {
  final SupabaseClient _supabase;
  final _picker = ImagePicker();
  static const _uuid = Uuid();

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
      imageQuality: 90, // calidad inicial antes de comprimir
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
        '[ReceiptScan] Imagen comprimida: ${(imageBytes.length / 1024).toStringAsFixed(1)} KB');

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
    //    Verificar que el JWT no esté expirado antes de invocar.
    //    functions.invoke no dispara el auto-refresh a diferencia de las llamadas
    //    a PostgREST, y el timer de refresh puede perderse tras un backgrounding.
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw Exception('Sesión expirada. Por favor iniciá sesión nuevamente.');
    }
    final nowSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if ((session.expiresAt ?? 0) <= nowSecs + 60) {
      debugPrint('[ReceiptScan] JWT próximo a expirar, refrescando sesión...');
      await _supabase.auth.refreshSession();
    }

    debugPrint('[ReceiptScan] Invocando Edge Function scan-receipt...');
    final response = await _supabase.functions.invoke(
      'scan-receipt',
      body: {
        'imageBase64': base64Image,
        'mimeType': 'image/webp',
      },
    );

    debugPrint('[ReceiptScan] Respuesta status=${response.status} data=${response.data}');

    if (response.status != 200 || response.data == null) {
      throw Exception('Error en el escaneo (status ${response.status}): ${response.data}');
    }

    final data = response.data['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Respuesta inválida del servidor de OCR: ${response.data}');
    }

    debugPrint('[ReceiptScan] OCR ok merchant=${data['merchant']} amount=${data['amount']}');
    return ReceiptScanResult.fromJson(data, imageFile.path);
  }

  /// Sube la imagen comprimida a Supabase Storage y devuelve el receipt_path.
  ///
  /// Llamar SOLO cuando el usuario confirmó el gasto.
  /// [householdId] y [expenseId] se usan para construir el path.
  Future<String> uploadReceipt({
    required String localImagePath,
    required String householdId,
    String? expenseId,
  }) async {
    final fileName = expenseId ?? _uuid.v4();
    final storagePath = '$householdId/$fileName.webp';
    final imageBytes = await File(localImagePath).readAsBytes();

    await _supabase.storage.from('receipts').uploadBinary(
      storagePath,
      imageBytes,
      fileOptions: const FileOptions(
        contentType: 'image/webp',
        upsert: true,
      ),
    );

    debugPrint('[ReceiptScan] Imagen subida a Storage: receipts/$storagePath');
    return storagePath;
  }

  /// Genera una URL firmada de corta duración para mostrar el ticket en UI.
  ///
  /// No persistir esta URL. Siempre generarla fresh al abrir el detalle.
  /// [expiresIn] en segundos (default: 1 hora).
  Future<String?> getSignedUrl(String receiptPath,
      {int expiresIn = 3600}) async {
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
