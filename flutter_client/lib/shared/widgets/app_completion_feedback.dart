import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

typedef AppCompletionFeedbackBuilder = Widget Function(
  BuildContext context,
  double progress,
  double pulse,
  Color completionColor,
);

/// A physics-based feedback wrapper for task completions.
/// Uses a SpringSimulation to provide a tactile, premium feel (2026 standard).
class AppCompletionFeedback extends StatefulWidget {
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
    this.popScale = 0.022, // Slightly increased for physics impact
    this.completionSurfaceAlpha = 0.085,
    this.completionBorderAlpha = 0.38,
    this.shadowBaseAlpha = 0.035,
    this.shadowPulseAlpha = 0.075,
    this.shadowBaseBlur = 18,
    this.shadowPulseBlur = 12,
  });

  static Color completionColor(Color accentColor) {
    return Color.alphaBlend(
      const Color(0xFF22C55E).withValues(alpha: 0.62),
      accentColor,
    );
  }

  @override
  State<AppCompletionFeedback> createState() => _AppCompletionFeedbackState();
}

class _AppCompletionFeedbackState extends State<AppCompletionFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    if (widget.isCompleting) {
      _runSpring(true);
    }
  }

  @override
  void didUpdateWidget(AppCompletionFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleting != oldWidget.isCompleting) {
      _runSpring(widget.isCompleting);
    }
  }

  void _runSpring(bool forward) {
    // Spring physics: 2026 standard for high-end micro-interactions
    const spring = SpringDescription(
      mass: 0.8,
      stiffness: 160,
      damping: 14,
    );

    final simulation = SpringSimulation(
      spring,
      _controller.value,
      forward ? 1.0 : 0.0,
      0,
    );

    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppCompletionFeedback.completionColor(widget.accentColor);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        // Pulse is derived from the spring's overshoot potential
        // We use a sine of progress to create a subtle expansion-contraction
        final pulse = math.sin(progress * math.pi);

        return Transform.scale(
          scale: 1 + (pulse * widget.popScale),
          child: Container(
            margin: widget.margin,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Color.lerp(
                widget.surfaceColor,
                Color.alphaBlend(
                  color.withValues(alpha: widget.completionSurfaceAlpha),
                  widget.surfaceColor,
                ),
                progress,
              ),
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: Color.lerp(
                  widget.borderColor,
                  color.withValues(alpha: widget.completionBorderAlpha),
                  progress,
                )!,
                width: widget.borderWidth,
              ),
              boxShadow: [
                ...widget.boxShadow,
                if (progress > 0.01)
                  BoxShadow(
                    color: color.withValues(
                      alpha: widget.shadowBaseAlpha +
                          (pulse * widget.shadowPulseAlpha),
                    ),
                    blurRadius:
                        widget.shadowBaseBlur + (pulse * widget.shadowPulseBlur),
                    offset: Offset(0, 4 + (pulse * 4)),
                  ),
              ],
            ),
            child: widget.builder(context, progress, pulse, color),
          ),
        );
      },
    );
  }
}
