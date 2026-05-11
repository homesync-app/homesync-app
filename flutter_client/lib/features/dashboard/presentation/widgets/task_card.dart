import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

Color dashboardCategoryAccent(BuildContext context, String? category) {
  final normalizedCategory = CategoryMapping.normaliseCategory(category);
  return CategoryMapping.getCategoryColor(normalizedCategory);
}

/// Maps a task/activity category string to a representative icon.
IconData dashboardCategoryIcon(String? category) {
  final normalizedCategory = CategoryMapping.normaliseCategory(category);
  return CategoryMapping.getCategoryMaterialIcon(normalizedCategory);
}

/// A rich task card with category icon, title, category pill, XP display, and
/// an interactive checkmark. Used in all dashboard modes (Solo, Couple, Family, Friends).
class DashboardTaskCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final normalizedCategory = CategoryMapping.normaliseCategory(task.category);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        for (final category in list) {
          if (CategoryMapping.normaliseCategory(category.id) ==
              normalizedCategory) {
            return category;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final accent = categoryData != null
        ? AppColors.fromHex(categoryData.color)
        : dashboardCategoryAccent(context, task.category);

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
                    localizedTaskTitle(AppLocalizations.of(context), task),
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
                        icon: Icons.star_rounded,
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
