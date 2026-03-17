import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ThemeModeNotifier — persists light/dark/system preference
// ─────────────────────────────────────────────────────────────────────────────

const _kThemeKey = 'app_theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  /// Call once at startup to restore saved preference
  Future<void> init(SharedPreferences prefs) async {
    final saved = prefs.getString(_kThemeKey);
    state = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kThemeKey,
        switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        });
  }

  void toggle() {
    setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// PrimaryColorNotifier — custom app color (Premium feature)
// ─────────────────────────────────────────────────────────────────────────────

const _kPrimaryColorKey = 'app_primary_color';

class PrimaryColorNotifier extends Notifier<Color> {
  @override
  Color build() => const Color(0xFFEE652B); // Orange default

  Future<void> init(SharedPreferences prefs) async {
    final saved = prefs.getInt(_kPrimaryColorKey);
    if (saved != null) {
      state = Color(saved);
    }
  }

  Future<void> setColor(Color color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPrimaryColorKey, color.value);
  }
}

final primaryColorProvider = NotifierProvider<PrimaryColorNotifier, Color>(
  PrimaryColorNotifier.new,
);
