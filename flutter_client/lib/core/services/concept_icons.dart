import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_environment.dart';
import 'logger_service.dart';

/// Iconos ilustrados para conceptos (premios, duelos, logros, metas de ahorro).
///
/// Reusan el bucket `shopping-icons` de Supabase Storage, bajo la carpeta
/// `concepts/`, con un manifest propio (`concepts_manifest.json`) que mapea
/// clave -> versión. Igual que los iconos de compras, se cachean local tras la
/// primera carga y permiten agregar/actualizar sin tocar la app.
///
/// Como las secciones guardan el EMOJI crudo (no una clave), acá hay un mapa
/// emoji -> clave para resolver el PNG correspondiente. Lo que no esté mapeado
/// sigue mostrando su emoji del sistema (fallback).
class ConceptIcons {
  static String get baseUrl =>
      '${AppEnvironment.supabaseUrl}/storage/v1/object/public/shopping-icons';

  static String urlFor(String key, String version) =>
      '$baseUrl/concepts/$key.png?v=$version';

  /// Emoji del sistema -> clave del PNG ilustrado.
  /// Cubre los pickers de premios (couple + family), templates, duelos,
  /// logros y metas de ahorro.
  static const Map<String, String> emojiToKey = {
    // Premios
    '🎁': 'gift',
    '☕': 'coffee_treat',
    '💆': 'massage',
    '🎬': 'movie_night',
    '🍦': 'ice_cream_cone',
    '💌': 'love_note',
    '🍫': 'chocolate_treat',
    '🍷': 'wine_glass',
    '🛁': 'bath',
    '🌅': 'sunset',
    '💝': 'heart_gift',
    '🍽️': 'dinner_out',
    '🍽': 'dinner_out',
    '🍕': 'pizza',
    '🎮': 'gaming',
    '🎲': 'board_game',
    '🧺': 'picnic',
    '⭐': 'star_reward',
    '📵': 'phone_off',
    '🏖️': 'day_off',
    '🏖': 'day_off',
    // Duelos / desafíos
    '🕯️': 'candle',
    '🕯': 'candle',
    '✨': 'sparkles',
    '🎤': 'microphone',
    '🎨': 'art_palette',
    '🍿': 'popcorn_bucket',
    '📸': 'camera',
    '✉️': 'letter',
    '✉': 'letter',
    '🤗': 'hug',
    '📖': 'book',
    '✈️': 'plane',
    '✈': 'plane',
    '🧩': 'puzzle',
    '🍳': 'cooking',
    '🥂': 'cheers',
    '🎵': 'music_note',
    '🏺': 'vase',
    '🥐': 'croissant',
    '🌊': 'wave',
    '🧭': 'compass',
    '🎭': 'theater',
    '🥬': 'leafy_green',
    '👂': 'ear_listen',
    '🌄': 'sunrise',
    '🙏': 'pray',
    '📦': 'box',
    '🙈': 'see_no_evil',
    '🎙️': 'old_mic',
    '🎙': 'old_mic',
    '🎞️': 'film_reel',
    '🎞': 'film_reel',
    '✅': 'check_done',
    '🔥': 'fire_streak',
    '🛌': 'bed_rest',
    '🌌': 'stargazing',
    '⏳': 'hourglass',
    '🖼️': 'picture_frame',
    '🖼': 'picture_frame',
    '🎟️': 'ticket',
    '🎟': 'ticket',
    // Logros
    '🏆': 'trophy',
    '🏅': 'medal',
    '👑': 'crown',
    '🌱': 'seedling',
    '🚀': 'rocket',
    '❤️': 'heart',
    '❤': 'heart',
    '💖': 'sparkle_heart',
    '♾️': 'infinity',
    '♾': 'infinity',
    '💃': 'dancer',
    '💎': 'gem',
    '🎯': 'target',
    '🔒': 'lock',
    // Metas de ahorro
    '💰': 'money_bag',
    '🏡': 'house_goal',
    '🚗': 'car',
    '💍': 'ring',
    '🛋️': 'sofa',
    '🛋': 'sofa',
    '🍼': 'baby_bottle',
    '🎓': 'graduation',
    '🐶': 'dog_pet',
    '💻': 'laptop',
    '🐷': 'piggy_bank',
  };

  /// Devuelve la clave del PNG para un emoji, o null si no está mapeado.
  static String? keyForEmoji(String? emoji) {
    if (emoji == null || emoji.isEmpty) return null;
    return emojiToKey[emoji.trim()];
  }
}

const String _prefsKey = 'concept_icon_manifest_v1';

class ConceptIconManifestNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    _init();
    return const {};
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_prefsKey);
      if (cached != null) {
        final map = (jsonDecode(cached) as Map)
            .map((k, v) => MapEntry(k as String, v.toString()));
        state = map;
      }
    } catch (e) {
      log.d('concept_icons: failed to read cached manifest: $e');
    }
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final url = '${ConceptIcons.baseUrl}/concepts_manifest.json';
      final resp =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final map = decoded.map((k, v) => MapEntry(k, v.toString()));
        state = map;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, jsonEncode(map));
      }
    } catch (e) {
      if (kDebugMode) {
        log.w('concept icon manifest refresh failed', error: e);
      }
    }
  }
}

final conceptIconManifestProvider =
    NotifierProvider<ConceptIconManifestNotifier, Map<String, String>>(
  ConceptIconManifestNotifier.new,
);
