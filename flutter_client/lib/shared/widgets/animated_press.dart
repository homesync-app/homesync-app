import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper for widgets that should scale down slightly when pressed.
/// Standardized across the app for premium feel.
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, 
        duration: widget.duration
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _controller.reverse();
        (widget.onTap ?? widget.onPressed)?.call();
      },
      onTapCancel: () => _controller.reverse(),
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
