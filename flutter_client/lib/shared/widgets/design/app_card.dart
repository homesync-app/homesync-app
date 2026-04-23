import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

enum AppCardVariant { standard, hero, subtle, flat }

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.padding,
    this.margin,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = switch (variant) {
      AppCardVariant.hero => AppRadii.hero,
      AppCardVariant.standard => AppRadii.card,
      AppCardVariant.subtle => AppRadii.card,
      AppCardVariant.flat => AppRadii.card,
    };
    final accent = accentColor ?? theme.primary;
    final background = switch (variant) {
      AppCardVariant.hero => theme.elevatedSurface,
      AppCardVariant.standard => theme.surface,
      AppCardVariant.subtle => theme.surfaceVariant.withValues(alpha: 0.45),
      AppCardVariant.flat => Colors.transparent,
    };

    final content = Container(
      margin: margin,
      padding: padding ?? AppInsets.card,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(
          color: variant == AppCardVariant.flat
              ? Colors.transparent
              : accent.withValues(
                  alpha: variant == AppCardVariant.hero ? 0.14 : 0.08,
                ),
        ),
        boxShadow: variant == AppCardVariant.flat
            ? const []
            : AppElevation.card(
                color: theme.shadowBase,
                isDarkMode: theme.isDarkMode,
              ),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return AnimatedPress(onTap: onTap, child: content);
  }
}
