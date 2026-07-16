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

  /// Radio concéntrico: una superficie anidada dentro de otra redondeada se ve
  /// bien cuando `outer = inner + padding`. Dado el radio del contenedor y el
  /// padding entre ambos, devuelve el radio del hijo (piso en [xs] para que
  /// paddings grandes no degeneren en esquinas rectas). Con padding > 24 las
  /// capas se leen como superficies independientes: elegí el radio a mano.
  static BorderRadius inner(double outerRadius, double padding) {
    final floor = outerRadius < xs ? outerRadius : xs;
    final radius = outerRadius - padding;
    return BorderRadius.circular(radius < floor ? floor : radius);
  }
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

/// Type scale for HomeSync. When everything is bold, nothing is — contrast
/// comes from SIZE first, weight second.
///
/// Reach for these roles before writing a literal `fontSize:`; a raw size in
/// a feature screen needs an intentional reason. Styles carry no color on
/// purpose: apply it from `context.theme` via `.copyWith(color: ...)`.
///
/// - [heroAmount]: THE number or headline of a screen. One per screen.
/// - [screenTitle]: screen-level titles.
/// - [sectionTitle]: section headers inside a screen.
/// - [cardTitle]: titles inside cards and list rows.
/// - [body] / [bodyStrong]: running text and its emphasized variant.
/// - [caption]: metadata, helper copy, timestamps.
/// - [eyebrow]: tracked uppercase kickers above titles (pair with
///   `.toUpperCase()` on the string).
class AppTypography {
  /// Weight alias for hero sizes. Prefer the [TextStyle] roles below.
  static const FontWeight hero = FontWeight.w900;

  /// Tight tracking is reserved for hero sizes (26+); body text stays at 0.
  static const double heroLetterSpacing = -0.8;

  static const TextStyle heroAmount = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    height: 1.1,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.12,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    height: 1.15,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.1,
  );
}

/// Escala de motion de HomeSync.
/// - [fast] 160ms: feedback de press, micro-fades.
/// - [normal] 220ms: pop-in de contenido, switchers, cambio de tab.
/// - [slow] 360ms: entrada de bloques/pantallas, draw-ins cortos.
/// Curva por defecto: [standard]. Los draw-ins de charts y las
/// celebraciones pueden exceder la escala deliberadamente.
class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve standard = Curves.easeOutCubic;

  static const SpringDescription snappyPageSpring = SpringDescription(
    mass: 0.5,
    stiffness: 200,
    damping: 18,
  );

  /// true cuando el OS pide reducir movimiento o hay lector de pantalla
  /// activo: los loops ambientales quedan quietos y las entradas se vuelven
  /// fade puro. No apagar indicadores de carga ni fades de comprensión.
  static bool reduce(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media == null) return false;
    return media.disableAnimations || media.accessibleNavigation;
  }
}
