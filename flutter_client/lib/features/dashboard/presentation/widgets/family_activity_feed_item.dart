import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart'
    show dashboardCategoryAccent, dashboardCategoryIcon;
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_detail_sheet.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/pending_approvals_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class FamilyActivityFeedItem extends ConsumerWidget {
  final Map<String, dynamic> activity;

  const FamilyActivityFeedItem({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final type = activity['type'] as String?;
    final data = (activity['data'] as Map<String, dynamic>?) ?? {};
    final isPendingApproval = type == 'task_pending_approval' ||
        data['approval_status'] == 'pending_approval';
    final createdAt =
        DateTime.tryParse(activity['created_at'] as String? ?? '')?.toLocal() ??
            DateTime.now();

    final userName = _firstName((data['user_name'] as String?)?.trim());
    final avatarUrl =
        (data['avatar_url'] ?? data['creator_avatar_url']) as String?;
    final detailTitle = _normalizedText(
      _localizedActivityTitle(context, data),
    );
    final amount = _parseAmount(data['amount']);
    final xpReward =
        _readInt(data['xp_reward'] ?? data['xp_per_user'] ?? data['xp']);
    final coinsReward = _readInt(
      data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
    );
    final category = data['category'] as String?;
    final accent = _activityAccent(context, type, category);
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember = ref.watch(householdMembersProvider).whenOrNull(
          data: (members) => members
              .where((member) => member.userId == currentUserId)
              .firstOrNull,
        );
    final canReview = isPendingApproval && (currentMember?.isAdmin ?? false);

    if (isPendingApproval) {
      return _PendingApprovalActivityCard(
        theme: theme,
        userName: userName,
        avatarUrl: avatarUrl,
        detailTitle: detailTitle,
        timeLabel: _formatTime(createdAt),
        xpReward: xpReward,
        coinsReward: coinsReward,
        accent: accent,
        canReview: canReview,
        onTap: () => _openDetail(context, ref, type, data),
        onApprove: () => _approvePendingTask(context, ref, data),
        onReject: () => _rejectPendingTask(context, ref, data),
      );
    }

    return InkWell(
      onTap: () => _openDetail(context, ref, type, data),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPendingApproval ? const Color(0xFFFFF8ED) : theme.surface,
          borderRadius: BorderRadius.circular(isPendingApproval ? 24 : 22),
          border: Border.all(
            color: isPendingApproval
                ? const Color(0xFFE59A2F).withValues(alpha: 0.2)
                : theme.divider.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomUserAvatar(
              name: userName,
              avatarUrl: avatarUrl,
              radius: 20,
              forceCircular: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headlineFor(type, userName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isPendingApproval
                                    ? const Color(0xFFC47A18)
                                    : theme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.05,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              detailTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          _activityIcon(type, category),
                          size: 16,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _metaPill(
                        theme: theme,
                        color: theme.textMuted,
                        icon: Icons.access_time_rounded,
                        label: _formatTime(createdAt),
                      ),
                      if (amount != null)
                        _metaPill(
                          theme: theme,
                          color: accent,
                          icon: Icons.payments_rounded,
                          label: _formatCurrency(ref, amount),
                        ),
                      if (xpReward != null && xpReward > 0)
                        _metaPill(
                          theme: theme,
                          color: const Color(0xFFE8943A),
                          icon: Icons.star_rounded,
                          label: '+$xpReward XP',
                        ),
                      if (coinsReward != null && coinsReward > 0)
                        _metaPill(
                          theme: theme,
                          color: AppColors.sage,
                          icon: Icons.monetization_on_rounded,
                          label: '+$coinsReward coins',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaPill({
    required AppThemeColors theme,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(
    BuildContext context,
    WidgetRef ref,
    String? type,
    Map<String, dynamic> data,
  ) async {
    if (type == 'task' || type == 'task_pending_approval') {
      final taskData = <String, dynamic>{
        ...data,
        'title': data['task_title'] ?? data['title'],
        'category': data['category'] ?? 'limpieza',
        'xp_reward': data['xp_reward'] ?? data['xp_per_user'] ?? data['xp'],
        'coin_reward':
            data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
        'completed_at': activity['created_at'],
        'activity_id': activity['id'],
        'completed_user': {
          'full_name': data['user_name'],
          'avatar_url': data['avatar_url'] ?? data['creator_avatar_url'],
          'id': activity['creator_id'],
        },
      };
      await TaskDetailSheet.show(context, taskData);
      return;
    }

    if (type == 'expense') {
      final expenseId = data['expense_id']?.toString();
      if (expenseId == null || expenseId.isEmpty) return;
      final repo = ref.read(expenseRepositoryProvider);
      final result = await repo.getExpenseWithSplits(expenseId);
      result.fold(
        (_) {},
        (fullData) => ExpenseDetailSheet.show(
          context,
          ExpenseModel.fromJson(fullData),
        ),
      );
    }
  }

  String _headlineFor(String? type, String userName) {
    switch (type) {
      case 'task_pending_approval':
        return '$userName dejó lista';
      case 'task':
        return '$userName completó';
      case 'expense':
        return '$userName registró un gasto';
      default:
        return '$userName hizo una acción';
    }
  }

  Color _activityAccent(BuildContext context, String? type, String? category) {
    if (type == 'expense') return const Color(0xFFF08B49);
    if (type == 'task_pending_approval') return const Color(0xFFE59A2F);
    return dashboardCategoryAccent(context, category);
  }

  IconData _activityIcon(String? type, String? category) {
    switch (type) {
      case 'expense':
        return Icons.receipt_long_rounded;
      case 'task_pending_approval':
        return Icons.fact_check_rounded;
      case 'task':
        return dashboardCategoryIcon(category);
      default:
        return Icons.star_rounded;
    }
  }

  int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  double? _parseAmount(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  String _normalizedText(String raw) {
    return raw
        .replaceAll('Completó la tarea:', '')
        .replaceAll('Agregó un gasto:', '')
        .replaceAll('Canjeó un premio:', '')
        .replaceAll('  ', ' ')
        .trim();
  }

  String _firstName(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return 'Alguien';
    return value.split(' ').first;
  }

  String _formatCurrency(WidgetRef ref, double amount) {
    return ref.read(currencyProvider).format(amount);
  }

  String _localizedActivityTitle(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final fallback = data['task_title'] ??
        data['title'] ??
        data['description'] ??
        'Actividad';
    return localizedTaskCatalogText(
      AppLocalizations.of(context),
      data['title_key'] as String?,
      fallback.toString(),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return DateFormat('d MMM', 'es_AR').format(time);
  }

  Future<void> _approvePendingTask(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) async {
    final taskId = data['task_id']?.toString();
    if (taskId == null || taskId.isEmpty) {
      _showSnackBar(
        context,
        'No encontramos esa tarea para revisar.',
        AppSnackBarType.error,
      );
      return;
    }

    try {
      final ok = await ref.read(taskApprovalActionsProvider).approve(taskId);
      if (!context.mounted) return;
      if (!ok) {
        _showSnackBar(
          context,
          'No pudimos aprobar la tarea.',
          AppSnackBarType.error,
        );
        return;
      }
      _refreshAfterReview(ref);
      _showSnackBar(context, 'Tarea aprobada.', AppSnackBarType.success);
    } catch (error) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'No pudimos aprobar la tarea: $error',
        AppSnackBarType.error,
      );
    }
  }

  Future<void> _rejectPendingTask(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) async {
    final taskId = data['task_id']?.toString();
    if (taskId == null || taskId.isEmpty) {
      _showSnackBar(
        context,
        'No encontramos esa tarea para revisar.',
        AppSnackBarType.error,
      );
      return;
    }

    try {
      final ok = await ref.read(taskApprovalActionsProvider).reject(taskId);
      if (!context.mounted) return;
      if (!ok) {
        _showSnackBar(
          context,
          'No pudimos devolver la tarea.',
          AppSnackBarType.error,
        );
        return;
      }
      _refreshAfterReview(ref);
      _showSnackBar(
        context,
        'La tarea volvio para corregir.',
        AppSnackBarType.info,
      );
    } catch (error) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        'No pudimos devolver la tarea: $error',
        AppSnackBarType.error,
      );
    }
  }

  void _refreshAfterReview(WidgetRef ref) {
    ref.invalidate(tasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(pendingTaskApprovalsProvider);
    ref.invalidate(userBalanceProvider);
    ref.invalidate(statsControllerProvider);
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    AppSnackBarType type,
  ) {
    AppSnackBar.show(
      context,
      message: message,
      type: type,
    );
  }
}

class _PendingApprovalActivityCard extends StatelessWidget {
  final AppThemeColors theme;
  final String userName;
  final String? avatarUrl;
  final String detailTitle;
  final String timeLabel;
  final int? xpReward;
  final int? coinsReward;
  final Color accent;
  final bool canReview;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingApprovalActivityCard({
    required this.theme,
    required this.userName,
    required this.avatarUrl,
    required this.detailTitle,
    required this.timeLabel,
    required this.xpReward,
    required this.coinsReward,
    required this.accent,
    required this.canReview,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF2),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: accent.withValues(alpha: 0.28),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomUserAvatar(
                  name: userName,
                  avatarUrl: avatarUrl,
                  radius: 21,
                  forceCircular: true,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _ReviewStatusPill(accent: accent),
                          const Spacer(),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.fact_check_rounded,
                              color: accent,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '$userName dejó lista',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.94),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        detailTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                          letterSpacing: -0.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ReviewMetaPill(
                    color: theme.textMuted,
                    icon: Icons.access_time_rounded,
                    label: timeLabel,
                  ),
                  if (xpReward != null && xpReward! > 0)
                    _ReviewMetaPill(
                      color: const Color(0xFFE8943A),
                      icon: Icons.star_rounded,
                      label: '${xpReward!} XP',
                    ),
                  if (coinsReward != null && coinsReward! > 0)
                    _ReviewMetaPill(
                      color: AppColors.sage,
                      icon: Icons.monetization_on_rounded,
                      label:
                          '${coinsReward!} ${coinsReward == 1 ? "coin" : "coins"}',
                    ),
                ],
              ),
            ),
            if (canReview) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _ReviewActionButton(
                      label: 'Devolver',
                      icon: Icons.reply_rounded,
                      color: accent,
                      filled: false,
                      onPressed: onReject,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ReviewActionButton(
                      label: 'Aprobar',
                      icon: Icons.check_rounded,
                      color: accent,
                      filled: true,
                      onPressed: onApprove,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewStatusPill extends StatelessWidget {
  final Color accent;

  const _ReviewStatusPill({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, size: 13, color: accent),
          const SizedBox(width: 6),
          Text(
            'Revisión pendiente',
            style: TextStyle(
              color: accent,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewMetaPill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _ReviewMetaPill({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onPressed;

  const _ReviewActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : color;
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? color : Colors.white.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: color.withValues(alpha: filled ? 0 : 0.32),
            width: 1.2,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(17),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 17, color: foreground),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
