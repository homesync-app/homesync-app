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
///
/// [pressBuilder] additionally exposes the normalized press progress
/// (0 = reposo, 1 = presionado, con overshoot del spring) para que el hijo
/// pueda morfear su forma al presionar (M3 Expressive: pill → redondeado).
class AnimatedPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onPressed; // Added for compatibility
  final VoidCallback? onLongPress;
  final double scale;
  final Duration duration;
  final AppPressHaptic haptic;
  final AppPressHaptic longPressHaptic;
  final Widget Function(BuildContext context, double t, Widget? child)?
      pressBuilder;

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
    this.pressBuilder,
  });

  @override
  State<AnimatedPress> createState() => _AnimatedPressState();
}

class _AnimatedPressState extends State<AnimatedPress> {
  bool _down = false;

  bool get _isActive =>
      widget.onTap != null ||
      widget.onPressed != null ||
      widget.onLongPress != null;

  void _pressDown() {
    if (!_isActive) return;
    setState(() => _down = true);
    _triggerHaptic(widget.haptic);
  }

  void _release() {
    if (!_isActive) return;
    setState(() => _down = false);
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
        value: _down ? 1.0 : 0.0,
        builder: (context, t, child) {
          final scale = 1 + (widget.scale - 1) * t;
          final content = widget.pressBuilder == null
              ? child
              : widget.pressBuilder!(context, t, child);
          return Transform.scale(scale: scale, child: content);
        },
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
