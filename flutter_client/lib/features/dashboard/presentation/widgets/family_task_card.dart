import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart'
    show CompletionSparkleBurst, dashboardCategoryAccent, dashboardCategoryIcon;
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_completion_feedback.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class FamilyTaskCard extends StatelessWidget {
  static const Duration exitAnimationDuration = Duration(milliseconds: 420);

  final TaskModel task;
  final bool isCompleting;
  // Cuando el card esta "saliendo" (post-completion), anima opacity+size hasta
  // colapsar. El padre debe esperar `exitAnimationDuration` antes de invalidar
  // el provider para que la animacion se vea entera. Ver
  // family_tasks_section._completeTask.
  final bool isExiting;
  final bool isChildView;
  final bool canApprovePending;
  final MemberModel? assignedMember;
  final MemberModel? completedMember;
  final String? currentUserId;
  final VoidCallback? onTap;
  final IconData actionIcon;
  final bool isActionEnabled;

  const FamilyTaskCard({
    super.key,
    required this.task,
    required this.isCompleting,
    required this.isChildView,
    required this.actionIcon,
    this.isExiting = false,
    this.canApprovePending = false,
    this.assignedMember,
    this.completedMember,
    this.currentUserId,
    this.onTap,
    this.isActionEnabled = true,
  });

  bool get _isAssignedToCurrentUser =>
      task.assignedTo == null || task.assignedTo == currentUserId;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: exitAnimationDuration,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: exitAnimationDuration,
        curve: Curves.easeInOutCubic,
        opacity: isExiting ? 0 : 1,
        child: isExiting
            ? const SizedBox(width: double.infinity)
            : _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = context.theme;
    final isPendingReview = task.isPendingApproval;
    final accent = isPendingReview
        ? const Color(0xFFE59A2F)
        : dashboardCategoryAccent(context, task.category);
    final contextLabel = _displayContextLabel();
    final urgency = _urgencyLabel();

    return AppCompletionFeedback(
      isCompleting: isCompleting,
      accentColor: accent,
      surfaceColor:
          isPendingReview ? accent.withValues(alpha: 0.08) : theme.surface,
      borderColor: accent.withValues(alpha: isPendingReview ? 0.22 : 0.12),
      boxShadow: theme.cardShadow,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      completionSurfaceAlpha: 0.080,
      completionBorderAlpha: 0.36,
      shadowBaseAlpha: isPendingReview ? 0.046 : 0.032,
      shadowPulseAlpha: 0.065,
      shadowPulseBlur: 11,
      // popScale handled by AppCompletionFeedback now
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
          child: Row(
            children: [
              _buildLeading(accent),
              const SizedBox(width: 18),
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
                    if (contextLabel != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        contextLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (urgency != null)
                          _FamilyTaskPill(
                            icon: task.isPendingApproval
                                ? Icons.fact_check_rounded
                                : task.isOverdue
                                    ? Icons.priority_high_rounded
                                    : Icons.today_rounded,
                            label: urgency,
                            color: task.isPendingApproval
                                ? accent
                                : task.isOverdue
                                    ? const Color(0xFFD96A5F)
                                    : accent,
                          ),
                        _FamilyTaskPill(
                          icon: Icons.star_rounded,
                          label: '${task.xpReward} XP',
                          color: AppColors.xpGold,
                        ),
                        if (task.coinReward > 0)
                          _FamilyTaskPill(
                            icon: Icons.monetization_on_rounded,
                            label: '${task.coinReward}',
                            color: AppColors.coinGreen,
                          ),
                        if (task.hasRotation)
                          _FamilyTaskPill(
                            icon: Icons.autorenew_rounded,
                            label: 'Rota entre ${task.rotationPool.length}',
                            color: const Color(0xFF5A94E1),
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
                    scale: 1 + (pulse * 0.15),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          isActionEnabled
                              ? accent.withValues(alpha: 0.055)
                              : theme.textMuted.withValues(alpha: 0.08),
                          completionColor.withValues(alpha: 0.90),
                          progress,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          // Strong outline at rest so the circle reads as the
                          // action button, not as an already-done state.
                          color: Color.lerp(
                            (isActionEnabled ? accent : theme.textMuted)
                                .withValues(
                              alpha: isActionEnabled ? 0.45 : 0.2,
                            ),
                            Colors.white.withValues(alpha: 0.62),
                            progress,
                          )!,
                          width: 1.8 - (progress * 0.8),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        ),
                        child: Icon(
                          isCompleting ? Icons.check_rounded : actionIcon,
                          key: ValueKey(isCompleting),
                          size: isCompleting ? 21 : 17,
                          color: isCompleting
                              ? Colors.white
                              : isActionEnabled
                                  ? accent.withValues(alpha: 0.88)
                                  : theme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeading(Color accent) {
    final leadingMember =
        task.isPendingApproval ? completedMember : assignedMember;
    if (leadingMember?.isChild == true) {
      return _buildChildAvatarLeading(leadingMember!, accent);
    }

    return _buildCategoryLeading(accent);
  }

  Widget _buildChildAvatarLeading(MemberModel member, Color accent) {
    final isPremiumCharacter =
        UserAvatar.isPremiumAvatarValue(member.avatarUrl);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.12),
            accent.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: AppRadii.inner(AppRadii.xl, 12),
        border: Border.all(color: accent.withValues(alpha: 0.08)),
      ),
      child: Center(
        child: Transform.translate(
          offset: isPremiumCharacter ? const Offset(0, -2) : Offset.zero,
          child: CustomUserAvatar(
            name: member.displayName,
            avatarUrl: member.avatarUrl,
            radius: isPremiumCharacter ? 25 : 20,
            showBorder: false,
            userId: member.userId,
            forceCircular: !isPremiumCharacter,
            allowMotion: false,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryLeading(Color accent) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.15),
            accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppRadii.inner(AppRadii.xl, 12),
      ),
      child: Icon(
        dashboardCategoryIcon(task.category),
        color: accent.withValues(alpha: 0.72),
        size: 21,
      ),
    );
  }

  String? _displayContextLabel() {
    if (task.isPendingApproval) {
      if (canApprovePending) {
        if (completedMember != null) {
          return '${completedMember!.displayName} la marcó como hecha';
        }
        return 'Lista para revisar';
      }
      if (isChildView) return 'Esperando aprobación';
      return 'Esperando que un adulto la revise';
    }

    if (task.assignedTo == null) {
      if (task.isOverdue) return 'Pendiente de coordinar';
      if (task.isDueToday) return 'A coordinar';
      return null;
    }

    if (_isAssignedToCurrentUser) {
      if (isChildView) {
        return task.isOverdue ? 'Tu misión pendiente' : 'Tu misión';
      }
      return task.isOverdue ? 'Te quedó pendiente' : 'Te toca hoy';
    }

    if (assignedMember == null) {
      return task.isOverdue ? 'Le quedó a otro' : 'Para otro integrante';
    }

    final name = _firstName(assignedMember!.displayName);
    if (name.isEmpty) {
      return task.isOverdue ? 'Le quedó a otro' : 'Para otro integrante';
    }
    return task.isOverdue ? 'Le quedó a $name' : 'Para $name';
  }

  String _firstName(String name) => name.trim().split(RegExp(r'\s+')).first;

  String? _urgencyLabel() {
    if (task.isPendingApproval) {
      return canApprovePending ? 'Revisar' : 'En revisión';
    }
    if (task.isOverdue) return 'Vencida';
    if (task.isDueToday) return 'Hoy';
    if (task.dueAt != null) return 'Próxima';
    return null;
  }
}

class _FamilyTaskPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FamilyTaskPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
