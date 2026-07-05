import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
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

    log.d(
      '[CustomAvatar] Imagen comprimida: '
      '${(imageBytes.length / 1024).toStringAsFixed(1)} KB',
    );

    const maxBase64Bytes = 5 * 1024 * 1024;
    if (base64Image.length > maxBase64Bytes) {
      throw const CustomAvatarGenerationException(
        CustomAvatarErrorCode.imageTooLarge,
        'La imagen es demasiado grande. Probá con otra foto.',
      );
    }

    final accessToken =
        await fa.FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (accessToken == null) {
      throw const CustomAvatarGenerationException(
        CustomAvatarErrorCode.sessionExpired,
        'Sesión expirada. Iniciá sesión nuevamente.',
      );
    }

    log.d('[CustomAvatar] Invocando Edge Function...');
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
            CustomAvatarErrorCode.timeout,
            'La generación tardó demasiado. Probá de nuevo en un momento.',
          );
        },
      );
    } on FunctionException catch (e) {
      final details = e.details;
      log.w(
        '[CustomAvatar] FunctionException status=${e.status} details=$details',
        error: e,
      );
      if (e.status == 429) {
        throw const CustomAvatarGenerationException(
          CustomAvatarErrorCode.monthlyLimitReached,
          'Ya usaste tu creación de avatar de este mes. Vas a poder crear otro el mes que viene.',
        );
      }
      if (e.status == 403) {
        throw const CustomAvatarGenerationException(
          CustomAvatarErrorCode.premiumRequired,
          'Esta función es para usuarios Premium.',
        );
      }
      throw _exceptionFromFunctionDetails(details) ??
          CustomAvatarGenerationException(
            CustomAvatarErrorCode.createFailed,
            'No se pudo crear el avatar (${e.status}). Probá de nuevo.',
          );
    } catch (e) {
      log.e('[CustomAvatar] Error inesperado', error: e);
      if (e is CustomAvatarGenerationException) rethrow;
      throw const CustomAvatarGenerationException(
        CustomAvatarErrorCode.createFailed,
        'No se pudo crear el avatar. Probá de nuevo.',
      );
    }

    log.d(
      '[CustomAvatar] Respuesta status=${response.status} data=${response.data}',
    );
    if (response.status != 200 || response.data == null) {
      throw CustomAvatarGenerationException(
        CustomAvatarErrorCode.createFailed,
        'No se pudo crear el avatar (status ${response.status}).',
      );
    }

    final data = response.data as Map<String, dynamic>;
    final avatarUrl = data['avatarUrl'] as String?;
    if (avatarUrl == null || avatarUrl.trim().isEmpty) {
      throw const CustomAvatarGenerationException(
        CustomAvatarErrorCode.invalidResult,
        'El generador no devolvió un avatar válido.',
      );
    }

    return avatarUrl;
  }

  Future<void> deleteAvatar({required String avatarId}) async {
    final accessToken =
        await fa.FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (accessToken == null) {
      throw const CustomAvatarGenerationException(
        CustomAvatarErrorCode.sessionExpired,
        'Sesión expirada. Iniciá sesión nuevamente.',
      );
    }

    try {
      final response = await _supabase.functions.invoke(
        'delete-custom-avatar',
        body: {'avatarId': avatarId},
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw const CustomAvatarGenerationException(
            CustomAvatarErrorCode.deleteFailed,
            'No se pudo eliminar el avatar. Probá de nuevo en un momento.',
          );
        },
      );

      if (response.status != 200) {
        throw CustomAvatarGenerationException(
          CustomAvatarErrorCode.deleteFailed,
          'No se pudo eliminar el avatar (status ${response.status}).',
        );
      }
    } on FunctionException catch (e) {
      log.w(
        '[CustomAvatar] Delete FunctionException status=${e.status} '
        'details=${e.details}',
        error: e,
      );
      throw const CustomAvatarGenerationException(
        CustomAvatarErrorCode.deleteFailed,
        'No se pudo eliminar el avatar. Probá de nuevo.',
      );
    } catch (e) {
      log.e('[CustomAvatar] Error eliminando avatar', error: e);
      if (e is CustomAvatarGenerationException) rethrow;
      throw const CustomAvatarGenerationException(
        CustomAvatarErrorCode.deleteFailed,
        'No se pudo eliminar el avatar. Probá de nuevo.',
      );
    }
  }

  static CustomAvatarGenerationException? _exceptionFromFunctionDetails(
    Object? details,
  ) {
    if (details is Map) {
      final error = details['error']?.toString();
      if (error == 'monthly_limit_reached') {
        return const CustomAvatarGenerationException(
          CustomAvatarErrorCode.monthlyLimitReached,
          'Ya usaste tu creación de avatar de este mes. Vas a poder crear otro el mes que viene.',
        );
      }
      if (error == 'premium_required') {
        return const CustomAvatarGenerationException(
          CustomAvatarErrorCode.premiumRequired,
          'Esta función es para usuarios Premium.',
        );
      }
      if (error == 'image_too_large') {
        return const CustomAvatarGenerationException(
          CustomAvatarErrorCode.imageTooLarge,
          'La imagen es demasiado grande. Probá con otra foto.',
        );
      }
      if (error == 'upload_failed') {
        return const CustomAvatarGenerationException(
          CustomAvatarErrorCode.saveFailed,
          'No se pudo guardar el avatar generado.',
        );
      }
      if (error == 'generation_failed') {
        final message = details['message']?.toString();
        final detail = details['detail']?.toString();
        final server = (message != null && message.trim().isNotEmpty)
            ? message
            : (detail != null && detail.trim().isNotEmpty ? detail : null);
        if (server != null) {
          return CustomAvatarGenerationException(
            CustomAvatarErrorCode.serverMessage,
            server,
            serverMessage: server,
          );
        }
      }
      if (error == 'OPENAI_API_KEY missing') {
        return const CustomAvatarGenerationException(
          CustomAvatarErrorCode.createFailed,
          'Falta configurar la API key de OpenAI en Supabase.',
        );
      }
    }
    return null;
  }
}

/// Semantic error codes so the UI can localize; [message] is only the
/// log/`toString` fallback (kept in Spanish for legacy paths without context).
enum CustomAvatarErrorCode {
  imageTooLarge,
  sessionExpired,
  timeout,
  monthlyLimitReached,
  premiumRequired,
  createFailed,
  invalidResult,
  deleteFailed,
  saveFailed,

  /// A human-readable message came from the server (`serverMessage`); show it
  /// verbatim.
  serverMessage,
}

class CustomAvatarGenerationException implements Exception {
  final CustomAvatarErrorCode code;
  final String message;
  final String? serverMessage;

  const CustomAvatarGenerationException(
    this.code,
    this.message, {
    this.serverMessage,
  });

  /// User-facing text following the app locale. Falls back to the Spanish
  /// [message] for codes carrying server-provided text.
  String localized(AppLocalizations t) {
    switch (code) {
      case CustomAvatarErrorCode.imageTooLarge:
        return t.avatarErrorImageTooLarge;
      case CustomAvatarErrorCode.sessionExpired:
        return t.avatarErrorSessionExpired;
      case CustomAvatarErrorCode.timeout:
        return t.avatarErrorTimeout;
      case CustomAvatarErrorCode.monthlyLimitReached:
        return t.avatarErrorMonthlyLimit;
      case CustomAvatarErrorCode.premiumRequired:
        return t.avatarErrorPremiumRequired;
      case CustomAvatarErrorCode.createFailed:
        return t.avatarErrorCreateFailed;
      case CustomAvatarErrorCode.invalidResult:
        return t.avatarErrorInvalidResult;
      case CustomAvatarErrorCode.deleteFailed:
        return t.avatarErrorDeleteFailed;
      case CustomAvatarErrorCode.saveFailed:
        return t.avatarErrorSaveFailed;
      case CustomAvatarErrorCode.serverMessage:
        return serverMessage ?? message;
    }
  }

  @override
  String toString() => message;
}
