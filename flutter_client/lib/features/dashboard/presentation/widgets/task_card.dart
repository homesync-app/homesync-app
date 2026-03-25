import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

Color dashboardCategoryAccent(BuildContext context, String? category) {
  switch (category?.toLowerCase()) {
    case 'cocina':
      return const Color(0xFFF08B49);
    case 'limpieza':
      return const Color(0xFF6D8DF7);
    case 'compras':
      return const Color(0xFF3FA97A);
    case 'finanzas':
      return const Color(0xFF4B6EF5);
    case 'mascotas':
      return const Color(0xFFE08A62);
    case 'mantenimiento':
      return const Color(0xFF7C8799);
    default:
      return context.theme.primary;
  }
}

/// Maps a task/activity category string to a representative icon.
IconData dashboardCategoryIcon(String? category) {
  switch (category?.toLowerCase()) {
    case 'cocina':
      return Icons.restaurant_rounded;
    case 'limpieza':
      return Icons.cleaning_services_rounded;
    case 'compras':
      return Icons.shopping_cart_rounded;
    case 'finanzas':
      return Icons.payments_rounded;
    case 'mascotas':
      return Icons.pets_rounded;
    case 'mantenimiento':
      return Icons.build_rounded;
    default:
      return Icons.task_alt_rounded;
  }
}

/// A rich task card with category icon, title, category pill, XP display, and
/// an interactive checkmark. Used in all dashboard modes (Solo, Couple, Family, Friends).
class DashboardTaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isCompleting;
  final VoidCallback? onTap;

  const DashboardTaskCard({
    super.key,
    required this.task,
    required this.isCompleting,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = dashboardCategoryAccent(context, task.category);

    return AnimatedPress(
      onTap: isCompleting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accent.withValues(alpha: 0.12),
          ),
          boxShadow: [
            ...theme.cardShadow,
            BoxShadow(
              color: accent.withValues(alpha: 0.04),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.15),
                    accent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                dashboardCategoryIcon(task.category),
                color: accent.withValues(alpha: 0.72),
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      color: theme.textPrimary,
                      height: 1.18,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TaskMetricPill(
                        icon: Icons.bolt_rounded,
                        label: '${task.xpReward} XP',
                        color: const Color(0xFFF0A146),
                      ),
                      if (task.coinReward > 0)
                        _TaskMetricPill(
                          icon: Icons.monetization_on_rounded,
                          label: '${task.coinReward}',
                          color: const Color(0xFF7CB08B),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.09),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.12),
                ),
              ),
              child: isCompleting
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: accent,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskMetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TaskMetricPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
