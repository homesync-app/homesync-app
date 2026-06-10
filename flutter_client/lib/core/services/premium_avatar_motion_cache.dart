import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/shared/widgets/premium_animated_avatar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Archivos WebP animados por avatar premium, alojados en Supabase Storage
/// (bucket publico `avatars`, carpeta `premium_animated/`). NO van en el APK:
/// se descargan bajo demanda la primera vez que hacen falta y quedan en el
/// cache local de la app.
///
/// Si un id figura aca, el avatar tiene variante animada.
const Map<String, Map<AvatarMotion, String>> kAnimatedPremiumAvatarFiles = {
  'premium_orange_cat': {
    AvatarMotion.idle: 'premium_orange_cat.webp',
    AvatarMotion.victory: 'premium_orange_cat_victory.webp',
    AvatarMotion.versus: 'premium_orange_cat_versus.webp',
    AvatarMotion.celebrate: 'premium_orange_cat_celebrate.webp',
  },
};

/// Descarga y cachea los WebP de movimientos de los avatares premium.
class PremiumAvatarMotionCache {
  PremiumAvatarMotionCache._();

  /// Evita descargas duplicadas del mismo avatar en paralelo.
  static final Map<String, Future<Map<AvatarMotion, String>?>> _inflight = {};

  static String _publicUrl(String fileName) =>
      '${AppEnvironment.supabaseUrl}/storage/v1/object/public/avatars/'
      'premium_animated/$fileName';

  static Future<Directory> _cacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/premium_avatar_motions');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Rutas locales de los movimientos de [avatarId], descargando los que
  /// falten. Devuelve null si el avatar no tiene variante animada o si no
  /// se pudo obtener al menos el movimiento idle.
  static Future<Map<AvatarMotion, String>?> ensure(String avatarId) {
    final files = kAnimatedPremiumAvatarFiles[avatarId];
    if (files == null || kIsWeb) return Future.value(null);
    return _inflight.putIfAbsent(
      avatarId,
      () => _ensure(avatarId, files).whenComplete(
        () => _inflight.remove(avatarId),
      ),
    );
  }

  /// Dispara la descarga sin esperar el resultado (ej. al elegir el avatar
  /// en el picker, para que ya este listo cuando el home lo muestre).
  static void prefetch(String avatarId) {
    unawaited(
      ensure(avatarId).catchError((Object e) {
        log.w('prefetch avatar animado $avatarId fallo: $e');
        return null;
      }),
    );
  }

  static Future<Map<AvatarMotion, String>?> _ensure(
    String avatarId,
    Map<AvatarMotion, String> files,
  ) async {
    final dir = await _cacheDir();
    final paths = <AvatarMotion, String>{};

    for (final entry in files.entries) {
      final target = File('${dir.path}/${entry.value}');
      if (target.existsSync() && target.lengthSync() > 0) {
        paths[entry.key] = target.path;
        continue;
      }
      try {
        final res = await http.get(Uri.parse(_publicUrl(entry.value)));
        if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
          throw Exception('HTTP ${res.statusCode}');
        }
        // Escritura atomica: nunca dejar un webp a medias en el cache.
        final tmp = File('${target.path}.tmp');
        await tmp.writeAsBytes(res.bodyBytes, flush: true);
        await tmp.rename(target.path);
        paths[entry.key] = target.path;
      } catch (e) {
        log.w('No se pudo descargar ${entry.value}: $e');
      }
    }

    // Sin idle no hay animacion ambiental: mejor quedarse con el PNG.
    if (!paths.containsKey(AvatarMotion.idle)) return null;
    return paths;
  }
}

/// Rutas locales de los WebP de un avatar premium (descargandolos si hace
/// falta). data == null => sin variante animada disponible: usar PNG.
final premiumAvatarMotionPathsProvider =
    FutureProvider.family<Map<AvatarMotion, String>?, String>(
  (ref, avatarId) => PremiumAvatarMotionCache.ensure(avatarId),
);
