import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

class AppFloatingActionButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = context.theme;
    final button = Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppElevation.floating(
            color: theme.shadowBase,
            isDarkMode: theme.isDarkMode,
          ),
        ),
        child: SizedBox(
          height: 54,
          child: FloatingActionButton.extended(
            heroTag: heroTag,
            onPressed: onPressed,
            elevation: 0,
            highlightElevation: 0,
            backgroundColor: theme.elevatedSurface.withValues(alpha: 0.96),
            foregroundColor: theme.primary,
            splashColor: theme.primary.withValues(alpha: 0.08),
            extendedPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              side: BorderSide(
                color: theme.primary.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            icon: Icon(icon, size: 19, color: theme.primary),
            label: Text(
              label,
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
      ),
    );

    return animateIn
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
