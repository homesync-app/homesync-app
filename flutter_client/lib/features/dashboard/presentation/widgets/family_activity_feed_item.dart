import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_presentation.dart'
    show
        activityIsSettlement,
        formatActivityTimeAgo,
        formatTaskActivityTimeLabel;
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart'
    show dashboardCategoryAccent;
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_detail_cache.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_detail_sheet.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/pending_approvals_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

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
    final isSettlement = activityIsSettlement(data);
    // Task approval is a premium Parent Mode feature. Its UI (the
    // "awaiting review" card + approve/reject actions) must be gated by the
    // SAME single source of truth that enables the feature —
    // [taskApprovalEnabledProvider] (family + active premium + mode != off).
    // Otherwise stale `pending` approvals left over from a previous premium
    // period (or any pending_approval row) render as "espera revisión" even
    // though approval is off, which is incorrect. When the gate is closed we
    // fall through to the normal completed-task card.
    final approvalEnabled = ref.watch(taskApprovalEnabledProvider);
    final isPendingApproval = approvalEnabled &&
        (type == 'task_pending_approval' ||
            data['approval_status'] == 'pending_approval');
    final createdAt =
        DateTime.tryParse(activity['created_at'] as String? ?? '')?.toLocal() ??
            DateTime.now();
    final timeLabel =
        formatTaskActivityTimeLabel(AppLocalizations.of(context), activity);

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
    final canReview = isPendingApproval &&
        ref.watch(parentModeAvailableProvider) &&
        (currentMember?.isAdmin ?? false);

    if (isPendingApproval) {
      return _PendingApprovalActivityCard(
        theme: theme,
        userName: userName,
        avatarUrl: avatarUrl,
        detailTitle: detailTitle,
        timeLabel:
            formatActivityTimeAgo(AppLocalizations.of(context), createdAt),
        xpReward: xpReward,
        coinsReward: coinsReward,
        accent: accent,
        canReview: canReview,
        onTap: () => _openDetail(context, ref, type, data),
        onApprove: () => _approvePendingTask(context, ref, data),
        onReject: () => _rejectPendingTask(context, ref, data),
      );
    }

    // Compact full-width timeline row (same density recipe as the solo
    // timeline, plus avatar + "who" eyebrow because family is multi-person):
    // avatar, eyebrow + title + plain relative time, and the key figures on
    // the trailing edge instead of a row of bordered pills.
    final figures = <_TrailingFigure>[
      if (amount != null)
        _TrailingFigure(_formatCurrency(ref, amount), theme.textPrimary),
      if (xpReward != null && xpReward > 0)
        _TrailingFigure('+$xpReward XP', AppColors.xpGold),
      if (coinsReward != null && coinsReward > 0)
        _TrailingFigure(
          AppLocalizations.of(context).activityCoinsPlus(coinsReward),
          AppColors.coinGreen,
        ),
    ].take(2).toList();

    return Semantics(
      button: true,
      child: AnimatedPress(
        onTap: () => _openDetail(context, ref, type, data),
        scale: 0.985,
        haptic: AppPressHaptic.selection,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: theme.border.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              CustomUserAvatar(
                name: userName,
                avatarUrl: avatarUrl,
                radius: 18,
                forceCircular: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headlineFor(type, userName, isSettlement: isSettlement),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detailTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyStrong.copyWith(
                        fontSize: 14.5,
                        height: 1.2,
                        color: theme.textPrimary.withValues(alpha: 0.92),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      timeLabel,
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (figures.isNotEmpty) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < figures.length; i++) ...[
                      if (i > 0) const SizedBox(height: 3),
                      Text(
                        figures[i].label,
                        style: TextStyle(
                          color: figures[i].color,
                          fontSize: i == 0 ? 13.5 : 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ).tabular,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
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
      final completedAt = data['completed_at'] ??
          data['last_completed_at'] ??
          activity['created_at'];
      final taskData = <String, dynamic>{
        ...data,
        'title': data['task_title'] ?? data['title'],
        'category': data['category'] ?? 'limpieza',
        'xp_reward': data['xp_reward'] ?? data['xp_per_user'] ?? data['xp'],
        'coin_reward':
            data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
        'completed_at': completedAt,
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
      // Open instantly with the data the feed already shows — the sheet
      // enriches itself (splits, description) in place, so tapping an expense
      // feels as immediate as tapping a task instead of waiting on a network
      // round-trip with no feedback.
      final createdAt = DateTime.tryParse(
            activity['created_at'] as String? ?? '',
          )?.toLocal() ??
          DateTime.now();
      // Detalle precalentado (batch de MainScreen) = sheet completo al toque.
      final cached = ref.read(expenseDetailCacheProvider)[expenseId];
      ExpenseDetailSheet.show(
        context,
        cached ??
            ExpenseModel(
              id: expenseId,
              title: activityIsSettlement(data)
                  ? AppLocalizations.of(context).activitySettlementTitle
                  : data['title']?.toString() ?? '',
              titleKey: data['title_key']?.toString(),
              amount: _parseAmount(data['amount']) ?? 0,
              category: data['category'] as String?,
              householdId: activity['household_id']?.toString() ?? '',
              paidBy: activity['creator_id']?.toString() ?? '',
              paidAt: createdAt,
              createdAt: createdAt,
              payerFullName: data['user_name'] as String?,
              payerAvatarUrl:
                  (data['avatar_url'] ?? data['creator_avatar_url']) as String?,
            ),
      );
    }
  }

  String _headlineFor(
    String? type,
    String userName, {
    bool isSettlement = false,
  }) {
    if (isSettlement) return '$userName equilibró la cuenta';
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
    final t = AppLocalizations.of(context);
    if (activityIsSettlement(data)) return t.activitySettlementTitle;
    final fallback = data['task_title'] ??
        data['title'] ??
        data['description'] ??
        t.activityFallbackTitle;
    return localizedTaskCatalogText(
      AppLocalizations.of(context),
      data['title_key'] as String?,
      fallback.toString(),
    );
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

class _TrailingFigure {
  final String label;
  final Color color;

  const _TrailingFigure(this.label, this.color);
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
    final cardColor =
        theme.isDarkMode ? theme.surface : const Color(0xFFFFFBF2);
    final mutedCardColor = theme.isDarkMode
        ? theme.surfaceContainer
        : Colors.white.withValues(alpha: 0.52);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withValues(alpha: theme.isDarkMode ? 0.34 : 0.28),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowBase.withValues(
                alpha: theme.isDarkMode ? 0.22 : 0.08,
              ),
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
                  radius: 20,
                  forceCircular: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$userName espera revisión de',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.05,
                                color: accent.withValues(alpha: 0.94),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              detailTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 15.5,
                                height: 1.18,
                                color: theme.textPrimary,
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
                          color: accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          Icons.fact_check_rounded,
                          color: accent,
                          size: 16,
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
                      color: AppColors.xpGold,
                      icon: Icons.star_rounded,
                      label: '${xpReward!} XP',
                    ),
                  if (coinsReward != null && coinsReward! > 0)
                    _ReviewMetaPill(
                      color: AppColors.coinGreen,
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
                      surfaceColor: mutedCardColor,
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
                      surfaceColor: mutedCardColor,
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
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
              color: color,
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
  final Color surfaceColor;
  final bool filled;
  final VoidCallback onPressed;

  const _ReviewActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.surfaceColor,
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
          color: filled ? color : surfaceColor,
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: foreground,
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
