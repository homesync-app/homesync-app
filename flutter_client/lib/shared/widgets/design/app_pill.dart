import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

class AppPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final bool dense;
  final VoidCallback? onTap;

  const AppPill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.selected = false,
    this.dense = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = color ?? theme.primary;
    final foreground = selected ? accent : theme.textSecondary;
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 12,
        vertical: dense ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: selected ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: accent.withValues(alpha: selected ? 0.24 : 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 13 : 15, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: dense ? 11.5 : 12.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: onTap,
      child: child,
    );
  }
}
