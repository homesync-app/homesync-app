import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';

/// Horizontal error shake with a decaying amplitude, plus the error haptic.
///
/// Increment [trigger] to play it once (e.g. on failed form validation):
///
/// ```dart
/// AppShake(trigger: _shakeTrigger, child: form)
/// // on invalid submit:
/// setState(() => _shakeTrigger++);
/// ```
class AppShake extends StatefulWidget {
  final int trigger;
  final Widget child;

  const AppShake({super.key, required this.trigger, required this.child});

  @override
  State<AppShake> createState() => _AppShakeState();
}

class _AppShakeState extends State<AppShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(covariant AppShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      AppHaptics.error();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Four oscillations fading out as the shake settles.
        final dx = math.sin(t * math.pi * 8) * 7 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
