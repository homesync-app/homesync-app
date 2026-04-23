import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

class AppSheetShell extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const AppSheetShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: AppRadii.sheet,
          boxShadow: theme.modalShadow,
        ),
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.border.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 22),
                Text(
                  title!,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
              if (title != null || subtitle != null) const SizedBox(height: 18),
              Flexible(child: child),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
