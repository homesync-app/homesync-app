import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef AppCompletionFeedbackBuilder = Widget Function(
  BuildContext context,
  double progress,
  double pulse,
  Color completionColor,
);

class AppCompletionFeedback extends StatelessWidget {
  final bool isCompleting;
  final Color accentColor;
  final Color surfaceColor;
  final Color borderColor;
  final List<BoxShadow> boxShadow;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;
  final double popScale;
  final double completionSurfaceAlpha;
  final double completionBorderAlpha;
  final double shadowBaseAlpha;
  final double shadowPulseAlpha;
  final double shadowBaseBlur;
  final double shadowPulseBlur;
  final AppCompletionFeedbackBuilder builder;

  const AppCompletionFeedback({
    super.key,
    required this.isCompleting,
    required this.accentColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.boxShadow,
    required this.borderRadius,
    required this.builder,
    this.margin,
    this.padding,
    this.borderWidth = 1,
    this.popScale = 0.018,
    this.completionSurfaceAlpha = 0.085,
    this.completionBorderAlpha = 0.38,
    this.shadowBaseAlpha = 0.035,
    this.shadowPulseAlpha = 0.075,
    this.shadowBaseBlur = 18,
    this.shadowPulseBlur = 12,
  });

  static Duration duration(BuildContext context, bool isCompleting) {
    final media = MediaQuery.maybeOf(context);
    if (media?.accessibleNavigation ?? false) return Duration.zero;
    return Duration(milliseconds: isCompleting ? 520 : 220);
  }

  static Curve curve(bool isCompleting) {
    return isCompleting ? Curves.easeOutCubic : Curves.easeInOutCubic;
  }

  static Color completionColor(Color accentColor) {
    return Color.alphaBlend(
      const Color(0xFF22C55E).withValues(alpha: 0.62),
      accentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isCompleting ? 1 : 0),
      duration: duration(context, isCompleting),
      curve: curve(isCompleting),
      builder: (context, progress, child) {
        final pulse = math.sin(progress * math.pi);
        final color = completionColor(accentColor);

        return Transform.scale(
          scale: 1 + (pulse * popScale),
          child: Container(
            margin: margin,
            padding: padding,
            decoration: BoxDecoration(
              color: Color.lerp(
                surfaceColor,
                Color.alphaBlend(
                  color.withValues(alpha: completionSurfaceAlpha),
                  surfaceColor,
                ),
                progress,
              ),
              borderRadius: borderRadius,
              border: Border.all(
                color: Color.lerp(
                  borderColor,
                  color.withValues(alpha: completionBorderAlpha),
                  progress,
                )!,
                width: borderWidth,
              ),
              boxShadow: [
                ...boxShadow,
                if (progress > 0)
                  BoxShadow(
                    color: color.withValues(
                      alpha: shadowBaseAlpha + (pulse * shadowPulseAlpha),
                    ),
                    blurRadius: shadowBaseBlur + (pulse * shadowPulseBlur),
                    offset: Offset(0, 8 + (pulse * 3)),
                  ),
              ],
            ),
            child: builder(context, progress, pulse, color),
          ),
        );
      },
    );
  }
}
