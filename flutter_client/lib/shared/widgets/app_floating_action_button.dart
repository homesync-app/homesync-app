import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:motor/motor.dart';

class AppFloatingActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Object? heroTag;
  final EdgeInsetsGeometry margin;
  final bool animateIn;

  const AppFloatingActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.heroTag,
    this.margin = const EdgeInsets.only(bottom: 18),
    this.animateIn = false,
  });

  @override
  State<AppFloatingActionButton> createState() =>
      _AppFloatingActionButtonState();
}

class _AppFloatingActionButtonState extends State<AppFloatingActionButton> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // Press-morph M3 Expressive: al presionar, el radio se contrae y el botón
    // hace un squash sutil, ambos sobre el mismo spring. El Listener solo
    // observa el puntero; el tap sigue siendo del FloatingActionButton.
    final button = Padding(
      padding: widget.margin,
      child: Listener(
        onPointerDown: (_) => _setDown(true),
        onPointerUp: (_) => _setDown(false),
        onPointerCancel: (_) => _setDown(false),
        child: SingleMotionBuilder(
          motion: const MaterialSpringMotion.standardSpatialFast(),
          value: _down && !reduceMotion ? 1.0 : 0.0,
          builder: (context, t, child) {
            final radius =
                AppRadii.lg + (AppRadii.sm - AppRadii.lg) * t.clamp(0.0, 1.2);
            return Transform.scale(
              scale: 1 - 0.03 * t,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  boxShadow: AppElevation.floating(
                    color: theme.shadowBase,
                    isDarkMode: theme.isDarkMode,
                  ),
                ),
                child: SizedBox(
                  height: 54,
                  child: FloatingActionButton.extended(
                    heroTag: widget.heroTag,
                    onPressed: widget.onPressed,
                    elevation: 0,
                    highlightElevation: 0,
                    backgroundColor:
                        theme.elevatedSurface.withValues(alpha: 0.96),
                    foregroundColor: theme.primary,
                    splashColor: theme.primary.withValues(alpha: 0.08),
                    extendedPadding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                      side: BorderSide(
                        color: theme.primary.withValues(alpha: 0.10),
                        width: 1,
                      ),
                    ),
                    icon: Icon(widget.icon, size: 19, color: theme.primary),
                    label: child!,
                  ),
                ),
              ),
            );
          },
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );

    return widget.animateIn
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.96, end: 1),
            duration: AppMotion.slow,
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: ((scale - 0.96) / 0.04).clamp(0, 1),
                  child: child,
                ),
              );
            },
            child: button,
          )
        : button;
  }
}
