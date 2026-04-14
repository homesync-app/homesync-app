import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Stitch Design - Warm Scandi Theme)
  static const Color primary = Color(0xFFEE652B);
  static const Color primaryLight = Color(0xFFFFF0EA);
  static const Color primaryDark = Color(0xFFD85A23);

  // Backgrounds
  static const Color background = Color(0xFFFFFCF9);
  static const Color backgroundDark = Color(0xFF1B1716);
  static const Color surface = Color(0xFFFFF8F2);
  static const Color surfaceDark = Color(0xFF26211F);
  static const Color cardDark = Color(0xFF2F2927);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color elevatedSurface = Color(0xFFFDF6EF);
  static const Color elevatedSurfaceDark = Color(0xFF342E2B);
  static const Color navSurface = Color(0xFFFFFBF7);
  static const Color navSurfaceDark = Color(0xFF211C1A);

  // Accent Colors
  static const Color sage = Color(0xFF84A59D);
  static const Color accentGold = Color(0xFFFFBD3D);
  static const Color accentTeal = sage;
  static const Color accentRed = Color(0xFFE57373);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentBlue = Color(0xFF5A94E1);
  static const Color accentPurple = Color(0xFF9575CD);
  static const Color accentPeach = Color(0xFFE88D67);
  static const Color accentOrange = Color(0xFFFF8A65);
  static const Color accentYellow = Color(0xFFD4C550);

  // Icon Palette
  static const Color iconPeach = Color(0xFFE88D67);
  static const Color iconSage = Color(0xFF6B8E85);
  static const Color iconBlue = Color(0xFF6B9FE8);
  static const Color iconYellow = Color(0xFFD4C550);
  static const Color iconRed = Color(0xFFE57373);
  static const Color iconGreen = Color(0xFF22C55E);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF4A4443);
  static const Color textSecondary = Color(0xFF8E8480);
  static const Color textMuted = Color(0xFFB2AAA6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color success = accentGreen;
  static const Color error = accentRed;
  static const Color warning = accentGold;
  static const Color info = accentTeal;
  static const Color accent = primary;

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static const Color divider = Color(0xFFF0E4D9);
  static const Color border = Color(0xFFF0E4D9);
  static const Color cardBorder = border;
  static const Color inputBorder = border;
  static const Color surfaceVariant = Color(0xFFFFF4EB);
  static const Color shadow = Color(0x124A4443);
  static const Color shadowBase = Color(0xFF4A4443);
  static const Color cardGhostBorderLight = Color(0x144A4443);
  static const Color cardGhostBorderDark = Color(0x332E2B45);
  static const Color surfaceVariantDark = Color(0xFF2E2927);

  static Color get infoLight => info.withValues(alpha: 0.12);
  static Color get successLight => success.withValues(alpha: 0.12);
  static Color get errorLight => error.withValues(alpha: 0.12);
  static Color get warningLight => warning.withValues(alpha: 0.12);

  // Glassmorphism effects
  static const Color glassWhite = Color(0xB3FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFFEE652B),
    Color(0xFFFF8A65),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF84A59D),
    Color(0xFFA8C4BF),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFFFFCF9),
    Color(0xFFFFF5EE),
  ];
}
