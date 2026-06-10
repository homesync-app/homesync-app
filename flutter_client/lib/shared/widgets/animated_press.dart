import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:motor/motor.dart';

enum AppPressHaptic { none, selection, light, medium, heavy }

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
  final AppPressHaptic haptic;
  final AppPressHaptic longPressHaptic;

  const AnimatedPress({
    super.key,
    required this.child,
    this.onTap,
    this.onPressed,
    this.onLongPress,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 80),
    this.haptic = AppPressHaptic.none,
    this.longPressHaptic = AppPressHaptic.medium,
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
    _triggerHaptic(widget.haptic);
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
        ? const CupertinoMotion.smooth()
        : const MaterialSpringMotion.standardSpatialFast();

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
              _triggerHaptic(widget.longPressHaptic);
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

  void _triggerHaptic(AppPressHaptic haptic) {
    switch (haptic) {
      case AppPressHaptic.none:
        return;
      case AppPressHaptic.selection:
        AppHaptics.selection();
        return;
      case AppPressHaptic.light:
        AppHaptics.tap();
        return;
      case AppPressHaptic.medium:
        AppHaptics.success();
        return;
      case AppPressHaptic.heavy:
        AppHaptics.warning();
        return;
    }
  }
}
