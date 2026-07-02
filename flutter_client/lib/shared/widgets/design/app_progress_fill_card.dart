import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

class AppProgressFillCard extends StatelessWidget {
  final Widget child;
  final double progress;
  final Color accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const AppProgressFillCard({
    super.key,
    required this.child,
    required this.progress,
    required this.accentColor,
    this.padding,
    this.margin,
    this.borderRadius = AppRadii.xxl,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    final radius = BorderRadius.circular(borderRadius);

    Widget card = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: clampedProgress),
      duration: reduceMotion ? Duration.zero : AppMotion.slow,
      curve: AppMotion.standard,
      builder: (context, value, _) {
        return Container(
          margin: margin,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.surface,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? accentColor.withValues(alpha: 0.12),
              width: 1.3,
            ),
            boxShadow: boxShadow ?? theme.cardShadow,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRect(
                  clipper: _ProgressFillClipper(
                    progress: value,
                    textDirection: Directionality.of(context),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: theme.isDarkMode ? 0.18 : 0.11,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding ?? AppInsets.card,
                child: child,
              ),
            ],
          ),
        );
      },
    );

    if (onTap == null) return card;
    return AnimatedPress(
      onTap: onTap,
      haptic: AppPressHaptic.selection,
      child: card,
    );
  }
}

class _ProgressFillClipper extends CustomClipper<Rect> {
  final double progress;
  final TextDirection textDirection;

  const _ProgressFillClipper({
    required this.progress,
    required this.textDirection,
  });

  @override
  Rect getClip(Size size) {
    final width = size.width * progress;
    if (textDirection == TextDirection.rtl) {
      return Rect.fromLTWH(size.width - width, 0, width, size.height);
    }
    return Rect.fromLTWH(0, 0, width, size.height);
  }

  @override
  bool shouldReclip(_ProgressFillClipper oldClipper) =>
      oldClipper.progress != progress ||
      oldClipper.textDirection != textDirection;
}
