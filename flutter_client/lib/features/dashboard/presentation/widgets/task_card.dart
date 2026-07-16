import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_completion_feedback.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

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
  final MemberModel? assignedMember;
  final VoidCallback? onTap;

  const DashboardTaskCard({
    super.key,
    required this.task,
    required this.isCompleting,
    this.assignedMember,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final currentUserId = ref.watch(currentUserIdProvider);
    final members =
        ref.watch(householdMembersProvider).value ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    // El server garantiza al menos 1 coin por completación para niños
    // (complete_task_v1); el pill refleja lo que este usuario va a ganar.
    final displayCoins = (currentMember?.isChild ?? false)
        ? (task.coinReward < 1 ? 1 : task.coinReward)
        : task.coinReward;
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

    return AppCompletionFeedback(
      isCompleting: isCompleting,
      accentColor: accent,
      surfaceColor: theme.surface,
      borderColor: accent.withValues(alpha: 0.12),
      boxShadow: theme.cardShadow,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      builder: (context, progress, pulse, completionColor) {
        return AnimatedPress(
          // Disable scaling during completion to avoid "Double Scale" jank
          scale: isCompleting ? 1.0 : 0.985,
          onTap: isCompleting
              ? null
              : () {
                  AppHaptics.tap();
                  onTap?.call();
                },
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
                  _buildLeading(accent, progress, completionColor),
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
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 15.5,
                            height: 1.18,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _TaskRewardPill(
                          xp: task.xpReward,
                          coins: displayCoins,
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
                        scale: 1 + (pulse * 0.16),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            // At rest this must still read as an action button,
                            // not as a blank status dot. During completion it
                            // fills and turns into the confirmed check state.
                            color: Color.lerp(
                              theme.surface.withValues(alpha: 0.94),
                              completionColor.withValues(alpha: 0.94),
                              progress,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color.lerp(
                                accent.withValues(alpha: 0.28),
                                Colors.white.withValues(alpha: 0.62),
                                progress,
                              )!,
                              width: 1.8 - (progress * 0.8),
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
                                  : accent.withValues(alpha: 0.62),
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
        );
      },
    );
  }

  Widget _buildLeading(Color accent, double progress, Color completionColor) {
    Widget child;

    if (isCompleting) {
      child = _TaskIconTile(
        key: const ValueKey('task-complete-icon'),
        color: completionColor,
        icon: Icons.check_rounded,
        iconSize: 24,
        progress: progress,
        completionColor: completionColor,
      );
    } else if (assignedMember != null) {
      child = CustomUserAvatar(
        key: ValueKey('assigned-${assignedMember!.userId}'),
        name: assignedMember!.displayName,
        avatarUrl: assignedMember!.avatarUrl,
        radius: 22,
        showBorder: true,
        userId: assignedMember!.userId,
        forceCircular: true,
      );
    } else {
      child = _TaskIconTile(
        key: ValueKey('category-${task.category ?? 'none'}'),
        color: accent,
        icon: dashboardCategoryIcon(task.category),
        iconSize: 21,
        progress: progress,
        completionColor: completionColor,
      );
    }

    return SizedBox(
      width: 54,
      height: 54,
      child: Center(
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TaskIconTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double iconSize;
  final double progress;
  final Color completionColor;

  const _TaskIconTile({
    super.key,
    required this.color,
    required this.icon,
    required this.iconSize,
    required this.progress,
    required this.completionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              color.withValues(alpha: 0.15),
              completionColor.withValues(alpha: 0.20),
              progress,
            )!,
            Color.lerp(
              color.withValues(alpha: 0.05),
              completionColor.withValues(alpha: 0.08),
              progress,
            )!,
          ],
        ),
        borderRadius: AppRadii.inner(AppRadii.xl, 12),
      ),
      child: Icon(
        icon,
        color: Color.lerp(
          color.withValues(alpha: 0.72),
          completionColor,
          progress,
        ),
        size: iconSize,
      ),
    );
  }
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

/// Pill único de recompensa (XP · coins) — mismo lenguaje visual que la card
/// de la pantalla Tareas para que la recompensa se lea igual en toda la app.
class _TaskRewardPill extends StatelessWidget {
  final int xp;
  final int coins;

  const _TaskRewardPill({
    required this.xp,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    if (xp <= 0 && coins <= 0) return const SizedBox.shrink();

    TextStyle style(Color color) => AppTypography.caption.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: color,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (xp > 0) ...[
            const Icon(Icons.star_rounded, size: 11, color: AppColors.xpGold),
            const SizedBox(width: 3),
            Text('$xp XP', style: style(AppColors.xpGold)),
          ],
          if (xp > 0 && coins > 0) ...[
            const SizedBox(width: 6),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (coins > 0) ...[
            const Icon(
              Icons.monetization_on_rounded,
              size: 11,
              color: AppColors.coinGreen,
            ),
            const SizedBox(width: 3),
            Text('$coins', style: style(AppColors.coinGreen)),
          ],
        ],
      ),
    );
  }
}
