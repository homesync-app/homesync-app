import 'package:flutter/material.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';

/// Single entry point for modal bottom sheets in HomeSync.
///
/// Drop-in replacement for [showModalBottomSheet] that standardizes the
/// pieces every sheet was configuring by hand:
/// - a selection haptic the moment the sheet opens,
/// - a theme-aware barrier (slightly deeper in dark mode),
/// - a settle-style entrance curve instead of the Material default.
///
/// Sheets keep drawing their own rounded surface (background stays
/// transparent), so existing sheet content needs no changes.
class AppSheet {
  AppSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    Color? backgroundColor,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    bool useSafeArea = false,
    BoxConstraints? constraints,
    ShapeBorder? shape,
  }) {
    // Si había un campo enfocado, el teclado abierto pelea con la entrada
    // del sheet (se abre y se cierra a la vez). Se cierra antes de animar
    // (tip flutterpro "dismiss the keyboard before opening a modal").
    FocusManager.instance.primaryFocus?.unfocus();
    AppHaptics.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: isDark ? 0.62 : 0.42),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      constraints: constraints,
      shape: shape,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 380),
        reverseDuration: Duration(milliseconds: 240),
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }
}
