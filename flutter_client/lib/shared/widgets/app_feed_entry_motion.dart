import 'package:flutter/material.dart';

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

  const AppFeedEntryMotion({
    super.key,
    required this.child,
    this.direction = AppFeedEntryDirection.fromTop,
    this.duration = const Duration(milliseconds: 420),
    this.distance = 24,
    this.beginScale = 0.96,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media?.accessibleNavigation ?? false) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
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
