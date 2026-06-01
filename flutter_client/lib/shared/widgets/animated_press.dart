import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motor/motor.dart';

/// A wrapper for widgets that should scale down slightly when pressed.
/// Standardized across the app for premium feel.
///
/// The press-down and release animations ride a spring simulation using
/// the [motor] package for native platform-specific spring physics.
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

class _AnimatedPressState extends State<AnimatedPress> {
  double _scale = 1.0;

  bool get _isActive =>
      widget.onTap != null ||
      widget.onPressed != null ||
      widget.onLongPress != null;

  void _pressDown() {
    if (!_isActive) return;
    setState(() {
      _scale = widget.scale;
    });
    HapticFeedback.selectionClick();
  }

  void _release() {
    if (!_isActive) return;
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isApple = !kIsWeb && (Platform.isIOS || Platform.isMacOS);
    final motion = isApple
        ? CupertinoMotion.smooth()
        : MaterialSpringMotion.standardSpatialFast();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _isActive ? (_) => _pressDown() : null,
      onTapUp: _isActive
          ? (_) {
              _release();
              (widget.onTap ?? widget.onPressed)?.call();
            }
          : null,
      onTapCancel: _isActive ? _release : null,
      onLongPress: _isActive && widget.onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            }
          : null,
      child: SingleMotionBuilder(
        motion: motion,
        value: _scale,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
