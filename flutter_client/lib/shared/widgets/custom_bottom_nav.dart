import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

class CustomBottomNavItem {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Optional anchor key — used by the onboarding coachmark tour to spotlight
  /// a specific tab. Attached to the tile's outermost widget so its global
  /// rect can be measured.
  final GlobalKey? anchorKey;

  const CustomBottomNavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.anchorKey,
  });
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<CustomBottomNavItem> items;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: theme.navigationSurface.withValues(
            alpha: theme.isDarkMode ? 0.95 : 0.98,
          ),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color:
                theme.border.withValues(alpha: theme.isDarkMode ? 0.48 : 0.72),
          ),
          boxShadow: AppElevation.floating(
            color: theme.shadowBase,
            isDarkMode: theme.isDarkMode,
          ),
        ),
        child: Row(
          children: [
            for (final item in items)
              Expanded(
                child: _CustomBottomNavTile(
                  item: item,
                  isSelected: currentIndex == item.index,
                  onTap: () => onTap(item.index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomBottomNavTile extends StatelessWidget {
  final CustomBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomBottomNavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final foreground = isSelected ? theme.primary : theme.textMuted;

    return AnimatedPress(
      key: item.anchorKey,
      scale: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: theme.isDarkMode ? 0.18 : 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                key: ValueKey('${item.label}-$isSelected'),
                color: foreground,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
