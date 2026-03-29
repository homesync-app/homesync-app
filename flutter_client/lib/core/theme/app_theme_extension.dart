import 'package:flutter/material.dart';
import 'app_colors.dart';

extension AppThemeExtension on BuildContext {
  AppThemeColors get theme => AppThemeColors(this);
}

class AppThemeColors {
  final BuildContext context;
  AppThemeColors(this.context);

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  Color get primary => Theme.of(context).colorScheme.primary;
  Color get primaryContainer => Theme.of(context).colorScheme.primaryContainer;
  Color get onPrimaryContainer =>
      Theme.of(context).colorScheme.onPrimaryContainer;

  Color get surface => Theme.of(context).colorScheme.surface;
  Color get surfaceVariant =>
      isDarkMode ? AppColors.surfaceDark : AppColors.surfaceVariant;
  Color get background => Theme.of(context).scaffoldBackgroundColor;
  Color get elevatedSurface =>
      isDarkMode ? AppColors.elevatedSurfaceDark : AppColors.elevatedSurface;
  Color get navigationSurface =>
      isDarkMode ? AppColors.navSurfaceDark : AppColors.navSurface;

  Color get textPrimary => Theme.of(context).colorScheme.onSurface;
  Color get textSecondary =>
      isDarkMode ? const Color(0xFFB8AEA7) : AppColors.textSecondary;
  Color get textMuted =>
      isDarkMode ? const Color(0xFF7C726E) : AppColors.textMuted;

  Color get border => isDarkMode ? const Color(0xFF433A36) : AppColors.border;
  Color get cardBorder => border;
  Color get inputBorder => border;

  Color get shadow =>
      isDarkMode ? Colors.black.withValues(alpha: 0.3) : AppColors.shadow;

  Color get shadowBase => isDarkMode ? Colors.black : AppColors.shadowBase;

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: shadowBase.withValues(alpha: isDarkMode ? 0.34 : 0.09),
          blurRadius: isDarkMode ? 26 : 22,
          offset: const Offset(0, 12),
        ),
      ];

  List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: shadowBase.withValues(alpha: isDarkMode ? 0.5 : 0.12),
          blurRadius: isDarkMode ? 36 : 30,
          offset: const Offset(0, 16),
        ),
      ];

  Color get success => AppColors.success;
  Color get error => AppColors.error;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;

  Color get scaffoldBackground => background;
  Color get surfaceContainer => isDarkMode ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
  Color get divider => isDarkMode ? Colors.white12 : Colors.black12;

  Color get glassWhite =>
      isDarkMode ? const Color(0x33000000) : AppColors.glassWhite;
  Color get glassBorder =>
      isDarkMode ? const Color(0x33FFFFFF) : AppColors.glassBorder;

  List<Color> get heroGradient => isDarkMode
      ? const [Color(0xFF3A2B25), Color(0xFF241E1B)]
      : const [Color(0xFFFFEBDD), Color(0xFFFFF8F2)];
}
