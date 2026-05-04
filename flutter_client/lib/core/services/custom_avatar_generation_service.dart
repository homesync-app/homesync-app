import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomAvatarGenerationService {
  final SupabaseClient _supabase;
  final _picker = ImagePicker();

  CustomAvatarGenerationService(this._supabase);

  Future<String?> generate({required ImageSource source}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 92,
    );
    if (picked == null) return null;

    final tempPath = '${picked.path}_custom_avatar.webp';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      tempPath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 82,
      format: CompressFormat.webp,
    );

    final imageFile = compressed ?? picked;
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    debugPrint(
      '[CustomAvatar] Imagen comprimida: '
      '${(imageBytes.length / 1024).toStringAsFixed(1)} KB',
    );

    const maxBase64Bytes = 5 * 1024 * 1024;
    if (base64Image.length > maxBase64Bytes) {
      throw const CustomAvatarGenerationException(
        'La imagen es demasiado grande. Probá con otra foto.',
      );
    }

    final accessToken =
        await fa.FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (accessToken == null) {
      throw const CustomAvatarGenerationException(
        'Sesión expirada. Iniciá sesión nuevamente.',
      );
    }

    debugPrint('[CustomAvatar] Invocando Edge Function...');
    late final FunctionResponse response;
    try {
      response = await _supabase.functions.invoke(
        'generate-custom-avatar',
        body: {
          'imageBase64': base64Image,
          'mimeType': 'image/webp',
        },
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(
        const Duration(seconds: 90),
        onTimeout: () {
          throw const CustomAvatarGenerationException(
            'La generación tardó demasiado. Probá de nuevo en un momento.',
          );
        },
      );
    } on FunctionException catch (e) {
      final details = e.details;
      debugPrint(
        '[CustomAvatar] FunctionException status=${e.status} '
        'details=$details error=$e',
      );
      if (e.status == 429) {
        throw const CustomAvatarGenerationException(
          'Ya usaste tu creación de avatar de este mes. Vas a poder crear otro el mes que viene.',
        );
      }
      if (e.status == 403) {
        throw const CustomAvatarGenerationException(
          'Esta función es para usuarios Premium.',
        );
      }
      throw CustomAvatarGenerationException(
        _messageFromFunctionDetails(details) ??
            'No se pudo crear el avatar (${e.status}). Probá de nuevo.',
      );
    } catch (e) {
      debugPrint('[CustomAvatar] Error inesperado: $e');
      if (e is CustomAvatarGenerationException) rethrow;
      throw const CustomAvatarGenerationException(
        'No se pudo crear el avatar. Probá de nuevo.',
      );
    }

    debugPrint(
      '[CustomAvatar] Respuesta status=${response.status} data=${response.data}',
    );
    if (response.status != 200 || response.data == null) {
      throw CustomAvatarGenerationException(
        'No se pudo crear el avatar (status ${response.status}).',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final avatarUrl = data['avatarUrl'] as String?;
    if (avatarUrl == null || avatarUrl.trim().isEmpty) {
      throw const CustomAvatarGenerationException(
        'El generador no devolvió un avatar válido.',
      );
    }

    return avatarUrl;
  }

  static String? _messageFromFunctionDetails(Object? details) {
    if (details is Map) {
      final error = details['error']?.toString();
      if (error == 'monthly_limit_reached') {
        return 'Ya usaste tu creación de avatar de este mes. Vas a poder crear otro el mes que viene.';
      }
      if (error == 'premium_required') {
        return 'Esta función es para usuarios Premium.';
      }
      if (error == 'image_too_large') {
        return 'La imagen es demasiado grande. Probá con otra foto.';
      }
      if (error == 'upload_failed') {
        final message = details['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return 'No se pudo guardar el avatar: $message';
        }
        return 'No se pudo guardar el avatar generado.';
      }
      if (error == 'generation_failed') {
        final message = details['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return message;
        }
        final detail = details['detail']?.toString();
        if (detail != null && detail.trim().isNotEmpty) {
          return detail;
        }
      }
      if (error == 'OPENAI_API_KEY missing') {
        return 'Falta configurar la API key de OpenAI en Supabase.';
      }
    }
    return null;
  }
}

class CustomAvatarGenerationException implements Exception {
  final String message;

  const CustomAvatarGenerationException(this.message);

  @override
  String toString() => message;
}
