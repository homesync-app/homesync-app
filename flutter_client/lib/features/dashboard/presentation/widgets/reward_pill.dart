import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

/// A small pill badge used to display XP or coin rewards in activity cards.
/// Extracted from the duplicated `_buildSmallPill` method across dashboard views.
class RewardPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const RewardPill({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  /// Convenience constructor for XP rewards.
  const RewardPill.xp({super.key, required int xp})
      : label = '$xp XP',
        color = const Color(0xFFF97316),
        icon = Icons.star_rounded;

  /// Convenience constructor for coin rewards.
  const RewardPill.coins({super.key, required int coins})
      : label = '$coins coins',
        color = const Color(0xFF64748B),
        icon = Icons.monetization_on_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800, color: color,),
          ),
        ],
      ),
    );
  }
}
