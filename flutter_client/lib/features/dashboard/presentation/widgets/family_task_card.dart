import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart'
    show dashboardCategoryAccent, dashboardCategoryIcon;
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class FamilyTaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isCompleting;
  final bool isChildView;
  final MemberModel? assignedMember;
  final MemberModel? completedMember;
  final VoidCallback? onTap;
  final IconData actionIcon;
  final bool isActionEnabled;

  const FamilyTaskCard({
    super.key,
    required this.task,
    required this.isCompleting,
    required this.isChildView,
    required this.actionIcon,
    this.assignedMember,
    this.completedMember,
    this.onTap,
    this.isActionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isPendingReview = task.isPendingApproval;
    final accent = isPendingReview
        ? const Color(0xFFE59A2F)
        : dashboardCategoryAccent(context, task.category);
    final contextLabel = _contextLabel();
    final urgency = _urgencyLabel();

    return AnimatedPress(
      onTap: isCompleting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              isPendingReview ? accent.withValues(alpha: 0.08) : theme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPendingReview
                ? accent.withValues(alpha: 0.22)
                : accent.withValues(alpha: 0.12),
          ),
          boxShadow: [
            ...theme.cardShadow,
            BoxShadow(
              color: accent.withValues(alpha: isPendingReview ? 0.08 : 0.04),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildLeading(accent),
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
                  if (contextLabel != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      contextLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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
                        color: const Color(0xFFF0A146),
                      ),
                      if (task.coinReward > 0)
                        _FamilyTaskPill(
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
                color: isActionEnabled
                    ? accent.withValues(alpha: 0.09)
                    : theme.textMuted.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActionEnabled
                      ? accent.withValues(alpha: 0.12)
                      : theme.textMuted.withValues(alpha: 0.12),
                ),
              ),
              child: isCompleting
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      actionIcon,
                      size: 18,
                      color: isActionEnabled ? accent : theme.textMuted,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(Color accent) {
    final memberForAvatar =
        task.isPendingApproval ? completedMember : assignedMember;

    if (memberForAvatar != null) {
      return CustomUserAvatar(
        name: memberForAvatar.displayName,
        avatarUrl: memberForAvatar.avatarUrl,
        radius: 22,
        showBorder: true,
        userId: memberForAvatar.userId,
      );
    }

    return Container(
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
    );
  }

  String? _contextLabel() {
    if (task.isPendingApproval) {
      if (isChildView) return 'Esperando revisión';
      if (completedMember != null) {
        return '${completedMember!.displayName} la marcó como hecha';
      }
      return 'Pendiente de aprobación';
    }
    if (task.isOverdue) return 'Te quedó pendiente';
    if (task.isDueToday) return 'Te toca hoy';
    return null;
  }

  String? _urgencyLabel() {
    if (task.isPendingApproval) return 'Revisar';
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
