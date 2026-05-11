import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/theme_provider.dart'
    show sharedPreferencesProvider;

// ─────────────────────────────────────────────────────────────────────────────
// LocaleNotifier — persists app language preference (es / en / system)
//
// Stored as 'es', 'en' or 'system' under SharedPreferences key 'app_locale'.
// `state == null` means "follow the system locale", which is what MaterialApp
// expects: passing `locale: null` lets Flutter resolve the best supported
// locale from the OS settings.
// ─────────────────────────────────────────────────────────────────────────────

const _kLocaleKey = 'app_locale';

const supportedLanguageCodes = {'es', 'en'};

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_kLocaleKey);
    return _decode(saved);
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    final encoded = _encode(locale);
    if (encoded == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, encoded);
    }
  }

  Locale? _decode(String? raw) {
    if (raw == null || raw == 'system') return null;
    if (supportedLanguageCodes.contains(raw)) {
      return Locale(raw);
    }
    return null;
  }

  String? _encode(Locale? locale) {
    if (locale == null) return null;
    if (!supportedLanguageCodes.contains(locale.languageCode)) return null;
    return locale.languageCode;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
