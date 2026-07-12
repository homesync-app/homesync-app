import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';

enum AppFeedEntryDirection {
  fromTop,
  fromLeft,
  fromRight,
}

class AppFeedEntryMotion extends StatelessWidget {
  final Widget child;
  final AppFeedEntryDirection direction;
  final Duration duration;
  final double distance;
  final double beginScale;

  /// Espera antes de arrancar (para entradas escalonadas por índice). El
  /// widget queda invisible durante la espera.
  final Duration delay;

  const AppFeedEntryMotion({
    super.key,
    required this.child,
    this.direction = AppFeedEntryDirection.fromTop,
    this.duration = AppMotion.slow,
    this.distance = 24,
    this.beginScale = 0.96,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduce(context)) return child;

    final totalMs = delay.inMilliseconds + duration.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: delay == Duration.zero
          ? AppMotion.standard
          : Interval(
              delay.inMilliseconds / totalMs,
              1,
              curve: AppMotion.standard,
            ),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: _offset(value),
            child: Transform.scale(
              scale: beginScale + ((1 - beginScale) * value),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  Offset _offset(double value) {
    final remaining = distance * (1 - value);
    switch (direction) {
      case AppFeedEntryDirection.fromTop:
        return Offset(0, -remaining);
      case AppFeedEntryDirection.fromLeft:
        return Offset(-remaining, 0);
      case AppFeedEntryDirection.fromRight:
        return Offset(remaining, 0);
    }
  }
}
