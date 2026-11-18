import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/household_art.dart';
import 'package:homesync_client/shared/widgets/premium_avatar_art.dart';

/// Task identity, owner and completion share the same warm home vocabulary.
class CoupleTaskTile extends StatelessWidget {
  final TaskModel task;
  final MemberModel? assigned;
  final String? currentUserId;
  final String categoryLabel;
  final bool busy;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onSchedule;
  final bool showCompletion;
  final double horizontalPadding;

  const CoupleTaskTile({
    super.key,
    required this.task,
    required this.assigned,
    required this.currentUserId,
    required this.categoryLabel,
    required this.busy,
    required this.expanded,
    required this.onToggle,
    required this.onComplete,
    required this.onEdit,
    required this.onSchedule,
    this.showCompletion = true,
    this.horizontalPadding = AppInsets.screenHorizontal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final title = localizedTaskTitle(t, task);
    final owner = assigned == null
        ? t.familyTaskCardUnassignedToday
        : assigned!.userId == currentUserId
            ? t.coupleWeekYou
            : assigned!.displayName.split(' ').first;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpacing.xs,
      ),
      child: CoupleSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderColor: task.isOverdue
            ? AppColors.accentRed.withValues(alpha: 0.45)
            : expanded
                ? theme.primary.withValues(alpha: 0.3)
                : theme.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedPress(
                    onTap: busy ? null : onToggle,
                    child: Row(
                      children: [
                        HouseholdArt(
                          kind: HouseholdArt.forCategory(task.category),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTypography.cardTitle
                                    .copyWith(color: theme.textPrimary),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  if (assigned != null) ...[
                                    ExcludeSemantics(
                                      child: MemberPortrait(
                                        name: assigned!.displayName,
                                        avatarUrl: assigned!.avatarUrl,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xxs),
                                  ],
                                  Expanded(
                                    child: Text(
                                      owner,
                                      style: AppTypography.caption
                                          .copyWith(color: theme.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              if (task.isRecurring)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.xxs,
                                  ),
                                  child: Text(
                                    task.recurrenceLabel(t),
                                    style: AppTypography.caption
                                        .copyWith(color: theme.textSecondary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showCompletion) const SizedBox(width: AppSpacing.xs),
                if (showCompletion)
                  AnimatedPress(
                    onTap: busy ? null : onComplete,
                    semanticLabel: t.coupleHomeCompleteTask(title),
                    excludeChildSemantics: true,
                    child: SizedBox.square(
                      dimension: 48,
                      child: Center(
                        child: SizedBox.square(
                          dimension: 32,
                          child: busy
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.primary,
                                )
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.textMuted
                                          .withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryLabel,
                            style: AppTypography.caption
                                .copyWith(color: theme.textSecondary),
                          ),
                          if (task.description?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              task.description!,
                              style: AppTypography.body
                                  .copyWith(color: theme.textSecondary),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              TextButton(
                                onPressed: busy ? null : onEdit,
                                child: Text(t.commonEdit),
                              ),
                              TextButton(
                                onPressed: busy ? null : onSchedule,
                                child: Text(t.tasksActionSchedule),
                              ),
                              if (showCompletion)
                                FilledButton(
                                  onPressed: busy ? null : onComplete,
                                  child: Text(
                                    busy
                                        ? t.tasksActionCompleting
                                        : t.tasksActionComplete,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
