import 'package:flutter/material.dart';

/// Shared visual decisions for HomeSync.
///
/// Keep feature screens inside this scale unless a screen has a specific,
/// intentional reason to feel different.
class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double modal = 32;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get hero => BorderRadius.circular(xxl);
  static BorderRadius get control => BorderRadius.circular(lg);
  static BorderRadius get sheet => const BorderRadius.vertical(
        top: Radius.circular(modal),
      );
}

class AppInsets {
  static const double screenHorizontal = 20;
  static const double screenTop = 16;
  static const double screenBottom = 120;
  static const double sectionGap = 24;
  static const double itemGap = 12;

  static const EdgeInsets screen = EdgeInsets.fromLTRB(
    screenHorizontal,
    screenTop,
    screenHorizontal,
    screenBottom,
  );
  static const EdgeInsets card = EdgeInsets.all(20);
  static const EdgeInsets compactCard = EdgeInsets.all(16);
  static const EdgeInsets section = EdgeInsets.symmetric(
    horizontal: screenHorizontal,
  );
}

class AppControlSizes {
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double minTapTarget = 44;
  static const double buttonHeight = 52;
  static const double fabHeight = 54;
}

class AppElevation {
  static List<BoxShadow> card({
    required Color color,
    required bool isDarkMode,
  }) =>
      [
        BoxShadow(
          color: color.withValues(alpha: isDarkMode ? 0.30 : 0.075),
          blurRadius: isDarkMode ? 24 : 18,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> floating({
    required Color color,
    required bool isDarkMode,
  }) =>
      [
        BoxShadow(
          color: color.withValues(alpha: isDarkMode ? 0.36 : 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> modal({
    required Color color,
    required bool isDarkMode,
  }) =>
      [
        BoxShadow(
          color: color.withValues(alpha: isDarkMode ? 0.48 : 0.12),
          blurRadius: 34,
          offset: const Offset(0, 16),
        ),
      ];
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve standard = Curves.easeOutCubic;
}
