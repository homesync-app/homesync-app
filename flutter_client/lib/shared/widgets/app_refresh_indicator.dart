import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';

/// HomeSync's pull-to-refresh. Drop-in replacement for [RefreshIndicator]:
/// theme-aware colors (works in dark mode without per-screen tuning), a
/// slightly finer stroke, and a haptic tick the moment the refresh arms.
///
/// Always use this instead of a raw [RefreshIndicator].
class AppRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  /// Optional overrides; default to the active theme.
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;
  final ScrollNotificationPredicate notificationPredicate;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.displacement = 36.0,
    this.edgeOffset = 0.0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return RefreshIndicator(
      onRefresh: () {
        AppHaptics.tap();
        return onRefresh();
      },
      color: color ?? theme.primary,
      backgroundColor: backgroundColor ?? theme.elevatedSurface,
      strokeWidth: 2.6,
      displacement: displacement,
      edgeOffset: edgeOffset,
      notificationPredicate: notificationPredicate,
      child: child,
    );
  }
}
