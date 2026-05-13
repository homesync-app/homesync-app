import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, danger }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.isDarkMode;

    // Determine colors based on variant
    final backgroundColor = _getBackgroundColor(theme, isDark);
    final foregroundColor = _getForegroundColor(theme, isDark);
    final borderColor = _getBorderColor(theme, isDark);

    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, color: foregroundColor, size: _getIconSize()),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: textStyle.copyWith(color: foregroundColor),
        ),
      ],
    );

    if (isFullWidth) {
      content = SizedBox(width: double.infinity, child: content);
    }

    return AnimatedPress(
      onTap: (isDisabled || isLoading)
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap?.call();
            },
      child: Opacity(
        opacity: (isDisabled || isLoading) ? 0.6 : 1.0,
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
            boxShadow:
                variant == AppButtonVariant.primary && !isDisabled && !isDark
                    ? [
                        BoxShadow(
                          color: theme.primary.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }

  Color _getBackgroundColor(AppThemeColors theme, bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return theme.primary;
      case AppButtonVariant.secondary:
        return isDark
            ? theme.surfaceVariant
            : theme.primary.withValues(alpha: 0.1);
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return theme.error.withValues(alpha: isDark ? 0.2 : 0.1);
    }
  }

  Color _getForegroundColor(AppThemeColors theme, bool isDark) {
    switch (variant) {
      case AppButtonVariant.primary:
        return Colors.white;
      case AppButtonVariant.secondary:
        return isDark ? Colors.white : theme.primary;
      case AppButtonVariant.outline:
        return theme.primary;
      case AppButtonVariant.ghost:
        return theme.textSecondary;
      case AppButtonVariant.danger:
        return theme.error;
    }
  }

  Color? _getBorderColor(AppThemeColors theme, bool isDark) {
    if (variant == AppButtonVariant.outline) {
      return theme.primary.withValues(alpha: 0.4);
    }
    if (variant == AppButtonVariant.danger) {
      return theme.error.withValues(alpha: 0.2);
    }
    return null;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 60;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
      case AppButtonSize.medium:
        return const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3,);
      case AppButtonSize.large:
        return const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.4,);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 22;
      case AppButtonSize.large:
        return 24;
    }
  }
}
