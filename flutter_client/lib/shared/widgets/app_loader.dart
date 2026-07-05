import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Branded loading indicator: a soft shape in the theme's primary color that
/// morphs between a circle and a squircle while rotating, with a subtle
/// breathing scale. Replaces the raw Material [CircularProgressIndicator] in
/// full-screen and section loading states (small in-button spinners keep the
/// stock indicator).
class AppLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const AppLoader({super.key, this.size = 30, this.color});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final size = widget.size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // One half-turn per cycle with an ease so the spin "settles" each
        // beat; the shape squares up mid-spin and relaxes back to a circle.
        final angle = Curves.easeInOutCubic.transform(t) * math.pi;
        final morph = math.sin(t * math.pi); // 0 → 1 → 0 per cycle
        final radius = lerpDouble(size / 2, size * 0.24, morph)!;
        final scale = 1 - 0.10 * morph;
        return Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30 * morph),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
