import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_environment.dart';
import '../../../core/services/logger_service.dart';

/// Iconos de compras servidos desde Supabase Storage (bucket público
/// `shopping-icons`). Permite agregar/actualizar iconos subiéndolos al storage
/// SIN tocar la app ni la tienda (ni release ni patch):
///   - PNGs en:        shopping-icons/products/[clave].png
///   - manifest en:    shopping-icons/manifest.json  (mapa clave -> version)
///
/// El manifest dice qué claves tienen ícono (así no se intenta cargar por red
/// los ~170 productos que no tienen). La `version` sirve para cache-busting:
/// si actualizás un PNG, subí la versión en el manifest y los clientes lo
/// vuelven a bajar. Todo se cachea local (cached_network_image + el manifest en
/// SharedPreferences), así que tras la 1ª carga funciona offline.
String get shoppingIconsBaseUrl =>
    '${AppEnvironment.supabaseUrl}/storage/v1/object/public/shopping-icons';

String shoppingIconUrl(String key, String version) =>
    '$shoppingIconsBaseUrl/products/$key.png?v=$version';

const String _prefsKey = 'shopping_icon_manifest_v1';

class ShoppingIconManifestNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    _init();
    return const {};
  }

  Future<void> _init() async {
    // 1) cache local primero (rápido / offline)
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_prefsKey);
      if (cached != null) {
        final map = (jsonDecode(cached) as Map)
            .map((k, v) => MapEntry(k as String, v.toString()));
        state = map;
      }
    } catch (e) {
      // Corrupt/legacy cache — safe to ignore, the storage refresh below
      // repopulates it. Log at debug level for diagnosability.
      log.d('shopping_icons: failed to read cached manifest: $e');
    }
    // 2) refresco desde el storage
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final url = '$shoppingIconsBaseUrl/manifest.json';
      final resp = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final map = decoded.map((k, v) => MapEntry(k, v.toString()));
        state = map;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, jsonEncode(map));
      }
    } catch (e) {
      if (kDebugMode) {
        log.w('shopping icon manifest refresh failed', error: e);
      }
    }
  }

  bool _precaching = false;

  /// Descarga todos los íconos del manifest a disco (mismo
  /// [DefaultCacheManager] que usa `CachedNetworkImage`) Y los decodifica
  /// al `ImageCache` de Flutter (memoria), en background.
  ///
  /// El secreto para que el primer frame se dibuje sincrónico (sin
  /// placeholder, sin emoji, sin ícono viejo) es popular la **memoria** del
  /// `ImageCache` además del disco: el widget `Image` consulta esa memoria
  /// antes de ir a disco, y solo si está ahí dispara `wasSynchronouslyLoaded`.
  ///
  /// Pensado para llamarse apenas abre la app / mientras el usuario
  /// configura el hogar en el onboarding: cuando llegue a la lista de
  /// compras los íconos YA están en memoria y se dibujan instantáneo.
  /// Best-effort: un ícono que falle no corta el resto, y nunca lanza.
  Future<void> precacheAllIcons() async {
    if (_precaching) return;
    _precaching = true;
    try {
      if (state.isEmpty) {
        await refresh();
      }
      final manager = DefaultCacheManager();
      final entries = state.entries.toList(growable: false);
      const concurrency = 6;

      // Usamos el mismo `devicePixelRatio` que el widget `Image` usará al
      // construir: la `ImageConfiguration` es parte de la clave del
      // `ImageCache`. Si difiere, el lookup falla y `wasSynchronouslyLoaded`
      // devuelve `false` → vuelve el flash. `platformDispatcher.views.first`
      // es la fuente que usa Flutter cuando no hay `MediaQuery` ancestor
      // (y en la práctica coincide con el de `MediaQuery` en single-display).
      final config = ImageConfiguration(devicePixelRatio: _safeDpr());

      for (var i = 0; i < entries.length; i += concurrency) {
        final batch = entries.skip(i).take(concurrency);
        await Future.wait(
          batch.map(
            (entry) => _precacheOne(
              url: shoppingIconUrl(entry.key, entry.value),
              manager: manager,
              config: config,
            ),
          ),
        );
      }
    } catch (e) {
      log.d('shopping_icons: precache failed: $e');
    } finally {
      _precaching = false;
    }
  }

  Future<void> _precacheOne({
    required String url,
    required CacheManager manager,
    required ImageConfiguration config,
  }) async {
    // 1) Disco: asegura que el archivo está en el cache manager (offline +
    //    cold-start). Best-effort.
    try {
      await manager.downloadFile(url);
    } catch (_) {}

    // 2) Memoria: resolver el `ImageProvider` fuerza la decodificación y
    //    popula el `ImageCache`. El listener cubre el caso sincrónico
    //    (imagen ya en memoria) y el asincrónico (download + decode).
    try {
      final provider = CachedNetworkImageProvider(url);
      final completer = Completer<ImageInfo>();
      final listener = ImageStreamListener(
        (info, _) {
          if (!completer.isCompleted) completer.complete(info);
        },
        onError: (Object e, StackTrace? st) {
          if (!completer.isCompleted) completer.completeError(e, st);
        },
      );
      final stream = provider.resolve(config);
      stream.addListener(listener);
      try {
        await completer.future.timeout(const Duration(seconds: 6));
      } finally {
        stream.removeListener(listener);
      }
    } catch (_) {
      // best-effort: la imagen se cargará on-demand cuando el widget
      // se construya; el `frameBuilder` mostrará el emoji brevemente.
    }
  }

  double _safeDpr() {
    try {
      return WidgetsBinding
          .instance.platformDispatcher.views.first.devicePixelRatio;
    } catch (_) {
      return 1.0;
    }
  }
}

final shoppingIconManifestProvider =
    NotifierProvider<ShoppingIconManifestNotifier, Map<String, String>>(
  ShoppingIconManifestNotifier.new,
);
