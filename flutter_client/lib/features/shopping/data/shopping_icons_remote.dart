import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_environment.dart';

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
    } catch (_) {}
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
        debugPrint('shopping icon manifest refresh failed: $e');
      }
    }
  }
}

final shoppingIconManifestProvider =
    NotifierProvider<ShoppingIconManifestNotifier, Map<String, String>>(
  ShoppingIconManifestNotifier.new,
);
