import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// A wrapper for widgets that should scale down slightly when pressed.
/// Standardized across the app for premium feel.
///
/// The press-down is a quick, deliberate ease; the release rides a
/// [SpringSimulation] so the widget settles back like a real object instead of
/// snapping to a fixed curve (idea from flutterpro.design "Make button presses
/// feel right" / "spring physics"). No extra package needed — Flutter ships the
/// spring in `dart:ui` physics.
class AnimatedPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onPressed; // Added for compatibility
  final VoidCallback? onLongPress;
  final double scale;
  final Duration duration;

  const AnimatedPress({
    super.key,
    required this.child,
    this.onTap,
    this.onPressed,
    this.onLongPress,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 80),
  });

  @override
  State<AnimatedPress> createState() => _AnimatedPressState();
}

class _AnimatedPressState extends State<AnimatedPress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Slightly underdamped: the release overshoots a hair past rest, which reads
  // as "alive" without wobbling. Travel is tiny (~0.05) so absolute overshoot
  // stays sub-pixel on most widgets.
  static const SpringDescription _releaseSpring = SpringDescription(
    mass: 0.5,
    stiffness: 320,
    damping: 20,
  );

  @override
  void initState() {
    super.initState();
    // Unbounded so the spring's overshoot isn't clamped to [0, 1]. The value
    // *is* the scale, resting at 1.0.
    _controller = AnimationController.unbounded(
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pressDown() {
    _controller.animateTo(
      widget.scale,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.selectionClick();
  }

  void _release() {
    _controller.animateWith(
      SpringSimulation(_releaseSpring, _controller.value, 1.0, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressDown(),
      onTapUp: (_) {
        _release();
        (widget.onTap ?? widget.onPressed)?.call();
      },
      onTapCancel: _release,
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _controller.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
