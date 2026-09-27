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

  /// Label for presses without readable text, such as icon-only buttons.
  final String? semanticLabel;

  /// Selected state, for tabs and chips built on top of this press.
  final bool? selected;

  /// Reads only [semanticLabel] and skips the children: for a styled
  /// Material button used as decoration, or text that would be read twice.
  final bool excludeChildSemantics;

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
    this.semanticLabel,
    this.selected,
    this.excludeChildSemantics = false,
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

    final gesture = GestureDetector(
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

    // Every press is announced as a button, enabled only while it has a
    // callback. Before, a screen reader heard the child's text with no role,
    // and a disabled press still sounded tappable.
    final onActivate = widget.onTap ?? widget.onPressed;
    return Semantics(
      container: true,
      button: true,
      enabled: _isActive,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeChildSemantics,
      // Excluding the children also drops the GestureDetector's actions.
      onTap: widget.excludeChildSemantics ? onActivate : null,
      onLongPress: widget.excludeChildSemantics ? widget.onLongPress : null,
      child: gesture,
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
