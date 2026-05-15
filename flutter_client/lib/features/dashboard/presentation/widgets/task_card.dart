import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
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

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isCompleting ? 1 : 0),
      duration: dashboardTaskCompletionDuration(context, isCompleting),
      curve: Curves.easeInOutCubic,
      builder: (context, progress, child) {
        final pulse = math.sin(progress * math.pi);
        final scale = 1 + (pulse * 0.002);
        final completionColor = dashboardTaskCompletionColor(accent);

        return Transform.scale(
          scale: scale,
          child: AnimatedPress(
            onTap: isCompleting ? null : onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Color.lerp(
                  theme.surface,
                  Color.alphaBlend(
                    completionColor.withValues(alpha: 0.035),
                    theme.surface,
                  ),
                  progress,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Color.lerp(
                    accent.withValues(alpha: 0.12),
                    completionColor.withValues(alpha: 0.26),
                    progress,
                  )!,
                ),
                boxShadow: [
                  ...theme.cardShadow,
                  BoxShadow(
                    color: completionColor.withValues(
                      alpha: 0.028 + (pulse * 0.04),
                    ),
                    blurRadius: 18 + (pulse * 8),
                    offset: Offset(0, 8 + (pulse * 2)),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: TaskCompletionSheen(
                        progress: progress,
                        color: completionColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(
                                accent.withValues(alpha: 0.15),
                                completionColor.withValues(alpha: 0.20),
                                progress,
                              )!,
                              Color.lerp(
                                accent.withValues(alpha: 0.05),
                                completionColor.withValues(alpha: 0.08),
                                progress,
                              )!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: AnimatedSwitcher(
                          duration: AppMotion.fast,
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          ),
                          child: Icon(
                            isCompleting
                                ? Icons.check_rounded
                                : dashboardCategoryIcon(task.category),
                            key: ValueKey(isCompleting),
                            color: Color.lerp(
                              accent.withValues(alpha: 0.72),
                              completionColor,
                              progress,
                            ),
                            size: isCompleting ? 24 : 21,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizedTaskTitle(
                                AppLocalizations.of(context),
                                task,
                              ),
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
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          CompletionSparkleBurst(
                            progress: progress,
                            color: completionColor,
                          ),
                          Transform.scale(
                            scale: 1 + (pulse * 0.045),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  accent.withValues(alpha: 0.09),
                                  completionColor.withValues(alpha: 0.90),
                                  progress,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color.lerp(
                                    accent.withValues(alpha: 0.12),
                                    Colors.white.withValues(alpha: 0.62),
                                    progress,
                                  )!,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: AppMotion.fast,
                                switchInCurve: Curves.easeOutBack,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  key: ValueKey(isCompleting),
                                  size: isCompleting ? 22 : 18,
                                  color: isCompleting
                                      ? Colors.white
                                      : completionColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Duration dashboardTaskCompletionDuration(
  BuildContext context,
  bool isCompleting,
) {
  final media = MediaQuery.maybeOf(context);
  if (media?.accessibleNavigation ?? false) {
    return Duration.zero;
  }
  return Duration(milliseconds: isCompleting ? 420 : 220);
}

Color dashboardTaskCompletionColor(Color accent) {
  return Color.alphaBlend(
    const Color(0xFF22C55E).withValues(alpha: 0.62),
    accent,
  );
}

class TaskCompletionSheen extends StatelessWidget {
  final double progress;
  final Color color;

  const TaskCompletionSheen({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();

    final eased = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    return Opacity(
      opacity: (1 - (eased * 0.55)).clamp(0.0, 1.0) * 0.22,
      child: FractionalTranslation(
        translation: Offset(-0.8 + (eased * 1.18), 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.46,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    color.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CompletionSparkleBurst extends StatelessWidget {
  final double progress;
  final Color color;

  const CompletionSparkleBurst({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();

    final eased = Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    final opacity = math.sin(progress * math.pi).clamp(0.0, 1.0);
    final distance = 10 + (eased * 7);

    return Opacity(
      opacity: opacity * 0.45,
      child: SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _SparkleDot(
              color: color,
              size: 4,
              offset: Offset(29 + distance * 0.52, 25 - distance),
            ),
            _SparkleDot(
              color: const Color(0xFFFFBD3D),
              size: 3,
              offset: Offset(27 - distance * 0.72, 31 - distance * 0.54),
            ),
            _SparkleDot(
              color: color,
              size: 2.5,
              offset: Offset(30 + distance * 0.68, 34 + distance * 0.34),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleDot extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;

  const _SparkleDot({
    required this.color,
    required this.size,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 6,
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
