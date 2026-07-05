import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// HomeSync's branded route transition: a quick fade with a hint of upward
/// drift and a scale settle, matching the entrance motion used by cards and
/// sheets across the app. The outgoing page recedes slightly so navigation
/// reads as depth instead of a hard cut.
///
/// Wired globally through [ThemeData.pageTransitionsTheme]; iOS keeps the
/// native Cupertino transition (and its edge swipe-back).
class HomeSyncPageTransitionsBuilder extends PageTransitionsBuilder {
  const HomeSyncPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: enter,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(enter),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(enter),
          // Recede the page being covered: slight upward drift + dim.
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0, -0.012),
            ).animate(exit),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.88).animate(exit),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared [PageTransitionsTheme] for light and dark themes.
const PageTransitionsTheme homeSyncPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: HomeSyncPageTransitionsBuilder(),
    TargetPlatform.fuchsia: HomeSyncPageTransitionsBuilder(),
    TargetPlatform.linux: HomeSyncPageTransitionsBuilder(),
    TargetPlatform.windows: HomeSyncPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  },
);
