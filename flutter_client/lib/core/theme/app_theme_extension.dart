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
  Color get onPrimaryContainer => Theme.of(context).colorScheme.onPrimaryContainer;

  Color get surface => Theme.of(context).colorScheme.surface;
  Color get background => Theme.of(context).scaffoldBackgroundColor;

  Color get textPrimary => Theme.of(context).colorScheme.onSurface;
  Color get textSecondary => isDarkMode 
      ? const Color(0xFF9D98B8) // darkSubtext from AppTheme
      : AppColors.textSecondary;
  Color get textMuted => isDarkMode 
      ? const Color(0xFF5E5A7A) // darkMuted from AppTheme
      : AppColors.textMuted;

  Color get border => isDarkMode 
      ? const Color(0xFF2E2B45) // darkBorder from AppTheme
      : AppColors.border;
  Color get cardBorder => border;
  Color get inputBorder => border;

  Color get shadow => isDarkMode 
      ? Colors.black.withValues(alpha: 0.3) 
      : AppColors.shadow;

  Color get success => AppColors.success;
  Color get error => AppColors.error;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;

  Color get scaffoldBackground => background;

  Color get glassWhite => isDarkMode 
      ? const Color(0x33000000) 
      : AppColors.glassWhite;
  Color get glassBorder => isDarkMode 
      ? const Color(0x33FFFFFF) 
      : AppColors.glassBorder;
}

