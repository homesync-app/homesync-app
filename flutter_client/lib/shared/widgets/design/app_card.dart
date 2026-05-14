import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

enum AppCardVariant { standard, hero, subtle, flat, glass }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;
  final VoidCallback? onTap;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.padding,
    this.margin,
    this.accentColor,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.isDarkMode;

    final radius = borderRadius != null
        ? BorderRadius.circular(borderRadius!)
        : switch (variant) {
            AppCardVariant.hero => AppRadii.hero,
            AppCardVariant.standard => AppRadii.card,
            AppCardVariant.subtle => AppRadii.card,
            AppCardVariant.flat => AppRadii.card,
            AppCardVariant.glass => AppRadii.hero,
          };

    final accent = accentColor ?? theme.primary;

    final background = switch (variant) {
      AppCardVariant.hero => theme.elevatedSurface,
      AppCardVariant.standard => theme.surface,
      AppCardVariant.subtle => theme.surfaceVariant.withValues(alpha: 0.45),
      AppCardVariant.flat => Colors.transparent,
      AppCardVariant.glass => isDark
          ? Colors.black.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.4),
    };

    Widget content = Container(
      margin: margin,
      padding: padding ?? AppInsets.card,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(
          color: _getBorderColor(theme, accent, variant),
          width: variant == AppCardVariant.glass ? 1.5 : 1.0,
        ),
        boxShadow:
            (variant == AppCardVariant.flat || variant == AppCardVariant.glass)
                ? const []
                : AppElevation.card(
                    color: theme.shadowBase,
                    isDarkMode: theme.isDarkMode,
                  ),
      ),
      child: child,
    );

    // Apply Blur if variant is Glass
    if (variant == AppCardVariant.glass) {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
        ),
      );
    }

    if (onTap == null) return content;
    return AnimatedPress(onTap: onTap, child: content);
  }

  Color _getBorderColor(
      AppThemeColors theme, Color accent, AppCardVariant variant,) {
    if (variant == AppCardVariant.flat) return Colors.transparent;
    if (variant == AppCardVariant.glass) return theme.glassBorder;

    return accent.withValues(
      alpha: variant == AppCardVariant.hero ? 0.12 : 0.06,
    );
  }
}
