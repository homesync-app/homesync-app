import 'package:flutter/material.dart';
import 'app_colors.dart';

extension AppThemeExtension on BuildContext {
  AppThemeColors get theme => AppThemeColors(this);
}

class AppThemeColors {
  final BuildContext context;
  AppThemeColors(this.context);

  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  Color get surface => isDarkMode ? const Color(0xFF1C1A2E) : AppColors.surface;
  Color get surfaceVariant =>
      isDarkMode ? const Color(0xFF252338) : AppColors.surfaceVariant;
  Color get background =>
      isDarkMode ? const Color(0xFF0F0E1A) : AppColors.background;

  Color get textPrimary =>
      isDarkMode ? const Color(0xFFF0EEFF) : AppColors.textPrimary;
  Color get textSecondary =>
      isDarkMode ? const Color(0xFF9D98B8) : AppColors.textSecondary;
  Color get textMuted =>
      isDarkMode ? const Color(0xFF5E5A7A) : AppColors.textMuted;

  Color get border => isDarkMode ? const Color(0xFF2E2B45) : AppColors.border;
  Color get cardBorder => border;
  Color get inputBorder => border;

  Color get shadow =>
      isDarkMode ? Colors.black.withOpacity(0.3) : AppColors.shadow;

  Color get glassWhite =>
      isDarkMode ? const Color(0x33000000) : AppColors.glassWhite;
  Color get glassBorder =>
      isDarkMode ? const Color(0x33FFFFFF) : AppColors.glassBorder;
}
