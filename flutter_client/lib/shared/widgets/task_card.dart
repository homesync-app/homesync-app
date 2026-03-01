import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onComplete;
  final String? currentUserId;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final category = task['category'] ?? 'general';
    final status = task['status'] ?? 'active';
    final assignedToId = task['assigned_to'];
    final isAssignedToMe =
        currentUserId != null && assignedToId == currentUserId;
    final isCompleted = status == 'verified';
    final isObjected = status == 'objected';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAssignedToMe
              ? AppColors.primary.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor,
          width: isAssignedToMe ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryIcon(category),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] ?? 'Sin título',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimary,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppColors.categoryNames[category] ?? 'General',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // Description / note
                      if ((task['description'] as String?)?.isNotEmpty ==
                          true) ...[
                        const SizedBox(height: 6),
                        Text(
                          task['description'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildRewardPill(context, task['xp_reward'], task['coin_reward']),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusBadge(context, status),
                if (isAssignedToMe && !isCompleted) ...[
                  const SizedBox(width: 8),
                  _buildAssignedBadge(),
                ],
                const Spacer(),
                if (!isCompleted) _buildCompleteButton(),
                if (isObjected) _buildObjectedBadge(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    final icon = AppColors.categoryIcons[category] ?? '📋';
    final color = AppColors.getCategoryColor(category);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 26)),
      ),
    );
  }

  Widget _buildRewardPill(BuildContext context, dynamic xp, dynamic coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: 4),
          Text('$xp',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          const Icon(Icons.monetization_on_rounded,
              size: 16, color: AppColors.success),
          const SizedBox(width: 4),
          Text('$coins',
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    String label;
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'active':
      case 'assigned':
        label = 'Pendiente';
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        break;
      case 'verified':
        label = 'Completada';
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        break;
      case 'objected':
        label = 'Objetada';
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        break;
      default:
        label = status;
        bgColor = Theme.of(context).scaffoldBackgroundColor;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAssignedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Para ti',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onComplete();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Completar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.warning),
          SizedBox(width: 6),
          Text(
            'Coins removidos',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
