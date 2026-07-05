import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// System chrome for HomeSync: true edge-to-edge with transparent bars.
///
/// The app draws behind both the status bar and the gesture/navigation bar,
/// so the warm background bleeds to the physical edges of the screen instead
/// of being framed by system scrims. Icon brightness flips with the theme.
class AppSystemUi {
  AppSystemUi._();

  /// Call once before `runApp`.
  static Future<void> init() async {
    if (kIsWeb) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Cached styles for theme wiring.
  static final SystemUiOverlayStyle light = styleFor(Brightness.light);
  static final SystemUiOverlayStyle dark = styleFor(Brightness.dark);

  /// Overlay style matching a theme brightness: transparent bars, no Android
  /// contrast scrim, and icons that contrast with the app's background.
  ///
  /// Used both by the root [AnnotatedRegion] (screens without an AppBar) and
  /// by `appBarTheme.systemOverlayStyle` (AppBar overrides the region).
  static SystemUiOverlayStyle styleFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      // iOS reads the bar style from the surface brightness, not icon color.
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
