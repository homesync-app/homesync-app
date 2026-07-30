import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/data/repositories/supabase_task_repository.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> taskData;
  final VoidCallback? onChanged;

  const TaskDetailSheet({super.key, required this.taskData, this.onChanged});

  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> taskData, {
    VoidCallback? onChanged,
  }) {
    return AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(taskData: taskData, onChanged: onChanged),
    );
  }

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  bool _isLoading = false;

  TaskModel get _task => TaskModel.fromMap(widget.taskData);
  TaskStatus get _status => _task.status;
  String get _category => _task.category ?? 'general';
  int get _xpReward => _readInt(
        _task.xpReward,
        widget.taskData['xp_reward'],
        widget.taskData['xp_per_user'],
        widget.taskData['xp'],
      );
  int get _coinReward => _readInt(
        _task.coinReward,
        widget.taskData['coin_reward'],
        widget.taskData['coins_per_user'],
        widget.taskData['coins'],
      );
  String? get _activityId => widget.taskData['activity_id'] as String?;
  String? get _comment => widget.taskData['objection_reason'] as String?;

  Map? get _completedUser => widget.taskData['completed_user'] as Map?;
  String _completedByName(AppLocalizations t) =>
      (_completedUser?['full_name'] as String?) ?? t.taskDetailFallbackUser;
  String? get _completedByAvatar => _completedUser?['avatar_url'] as String?;
  String? get _completedById => _completedUser?['id'] as String?;
  String get _currentUserId => ref.read(currentUserIdProvider) ?? '';
  bool get _isAuthor => _completedById == _currentUserId;
  DateTime? get _completedAt => _readDate(
        widget.taskData['completed_at'],
        widget.taskData['last_completed_at'],
        _task.lastCompletionAt,
      );
  dynamic get _rawCompletedAt =>
      widget.taskData['completed_at'] ??
      widget.taskData['last_completed_at'] ??
      _task.lastCompletionAt;
  bool get _completedDateOnlyFlag {
    final raw = widget.taskData['completed_date_only'];
    return raw == true || raw?.toString().toLowerCase() == 'true';
  }

  bool get _hasCompletionRecord => _activityId != null || _completedAt != null;

  int _readInt(
    dynamic primary, [
    dynamic fallback1,
    dynamic fallback2,
    dynamic fallback3,
  ]) {
    for (final candidate in [primary, fallback1, fallback2, fallback3]) {
      if (candidate is num && candidate.toInt() > 0) return candidate.toInt();
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0;
  }

  DateTime? _readDate(dynamic primary, [dynamic fallback1, dynamic fallback2]) {
    for (final candidate in [primary, fallback1, fallback2]) {
      if (candidate is DateTime) return candidate.toLocal();
      final parsed = DateTime.tryParse(candidate?.toString() ?? '');
      if (parsed != null) return parsed.toLocal();
    }
    return null;
  }

  DateTime? _dateOnlyDisplayDate() {
    final raw = _rawCompletedAt;
    if (raw is DateTime) return DateTime(raw.year, raw.month, raw.day);
    final parsed = DateTime.tryParse(raw?.toString() ?? '');
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  bool _isDateOnlyCompletion(DateTime? completedAt) {
    if (completedAt == null) return false;
    if (_completedDateOnlyFlag) return true;

    final raw = _rawCompletedAt?.toString();
    if (raw != null) {
      final normalized = raw.replaceFirst(' ', 'T');
      return normalized.contains('T00:00:00') ||
          normalized.contains('T12:00:00');
    }

    return completedAt.hour == 0 &&
        completedAt.minute == 0 &&
        completedAt.second == 0 &&
        completedAt.millisecond == 0;
  }

  (String, Color, IconData) _statusInfo(AppLocalizations t) {
    if (_activityId != null) {
      return (
        t.taskDetailStatusCompleted,
        AppColors.accentTeal,
        Icons.check_circle_rounded,
      );
    }

    return switch (_status) {
      TaskStatus.pendingVerification || TaskStatus.verified => (
          t.taskDetailStatusCompleted,
          AppColors.accentTeal,
          Icons.check_circle_rounded
        ),
      TaskStatus.objected => (
          t.taskDetailStatusDisputed,
          AppColors.accentRed,
          Icons.warning_amber_rounded
        ),
      _ => (
          t.taskDetailStatusPending,
          AppColors.textMuted,
          Icons.schedule_rounded
        ),
    };
  }

  Future<void> _undoTask() async {
    final t = AppLocalizations.of(context);
    if (_activityId == null) {
      _showSnack(t.taskDetailUndoErrorNotFound, AppColors.error);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    AppHaptics.success();
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(taskRepositoryProvider);
      final result = await repo.undoTaskCompletion(_activityId!);
      result.fold(
        (failure) => _showSnack(t.taskDetailUndoError, AppColors.error),
        (_) {
          _refreshAfterUndo();
          widget.onChanged?.call();
          if (!mounted) return;
          navigator.pop();
          AppSnackBar.show(
            messenger.context,
            message: t.taskDetailUndoSuccess,
            type: AppSnackBarType.success,
            duration: const Duration(milliseconds: 1500),
          );
        },
      );
    } catch (error, stackTrace) {
      log.w(
        'TaskDetailSheet failed to undo task',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(t.taskDetailUndoError, AppColors.error);
      }
    }
  }

  void _refreshAfterUndo() {
    ref.invalidate(tasksProvider);
    ref.invalidate(todayTasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(combinedFeedControllerProvider);
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(statsControllerProvider);
  }

  void _showSnack(String msg, Color color) {
    AppSnackBar.show(
      context,
      message: msg,
      type: color == AppColors.error
          ? AppSnackBarType.error
          : AppSnackBarType.neutral,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = context.theme;
    final t = AppLocalizations.of(context);
    final showGamification =
        ref.watch(householdCapabilitiesProvider).type != HouseholdType.couple;
    final (statusLabel, statusColor, statusIcon) = _statusInfo(t);
    final categoryColor = CategoryMapping.getCategoryColor(_category);
    final categoryIcon = CategoryMapping.getCategoryMaterialIcon(_category);
    final completedAt = _completedAt;
    final localeTag = Localizations.localeOf(context).toString();
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final isDateOnlyCompletion = _isDateOnlyCompletion(completedAt);
    final displayDate = isDateOnlyCompletion
        ? _dateOnlyDisplayDate() ?? completedAt
        : completedAt;
    final dateStr = completedAt != null
        ? DateFormat(
            isDateOnlyCompletion ? 'd MMM' : "d MMM '·' HH:mm",
            localeTag,
          ).format(displayDate!)
        : t.taskDetailNoRecord;

    return Container(
      margin: const EdgeInsets.only(top: 72),
      decoration: BoxDecoration(
        color: appTheme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: appTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.taskDetailHeaderTitle,
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: AppTypography.cardTitle.copyWith(
                        color: appTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 16, 24, 22 + bottomPadding),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        categoryColor.withValues(alpha: 0.018),
                        appTheme.surface,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: appTheme.border.withValues(alpha: 0.68),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.018),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color.alphaBlend(
                                  categoryColor.withValues(alpha: 0.10),
                                  appTheme.background,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                                border: Border.all(
                                  color: categoryColor.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  categoryIcon,
                                  size: 23,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizedTaskTitle(t, _task),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.cardTitle.copyWith(
                                      fontSize: 18,
                                      height: 1.12,
                                      color: appTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      if (showGamification) ...[
                                        _buildChip(
                                          icon: Icons.star_rounded,
                                          label: '+$_xpReward XP',
                                          color: AppColors.xpGold,
                                          textColor: appTheme.textPrimary,
                                          background: AppColors.accentGold
                                              .withValues(alpha: 0.10),
                                        ),
                                        _buildChip(
                                          icon: Icons.monetization_on_rounded,
                                          label: t.taskDetailCoinsAwarded(
                                            _coinReward,
                                          ),
                                          color: AppColors.coinGreen,
                                          textColor: appTheme.textPrimary,
                                          background: AppColors.coinGreen
                                              .withValues(alpha: 0.12),
                                        ),
                                      ],
                                      if (_task.isRecurring)
                                        _buildChip(
                                          icon: Icons.event_repeat_rounded,
                                          label: _task.recurrenceLabel(t),
                                          color: AppColors.accentGold,
                                          textColor: appTheme.textPrimary,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              AppColors.sage.withValues(alpha: 0.055),
                              appTheme.surface,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.sage.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Row(
                            children: [
                              CustomUserAvatar(
                                name: _completedByName(t),
                                avatarUrl: _completedByAvatar,
                                radius: 15,
                                forceCircular: true,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: RichText(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                      color: appTheme.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _hasCompletionRecord
                                            ? '${t.taskDetailCompletedBy} '
                                            : '${t.taskDetailAssignedTo} ',
                                      ),
                                      TextSpan(
                                        text: _completedByName(t),
                                        style: TextStyle(
                                          color: appTheme.textPrimary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (completedAt != null && !isDateOnlyCompletion)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appTheme.background
                                        .withValues(alpha: 0.78),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.pill),
                                  ),
                                  child: Text(
                                    DateFormat('HH:mm').format(completedAt),
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                      color: appTheme.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_comment != null && _comment!.trim().isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accentRed.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.taskDetailComment,
                            style: AppTypography.caption.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: appTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _comment!,
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    Color? background,
    Color? textColor,
    FontWeight textWeight = FontWeight.w800,
    double gap = 6,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: gap),
          Text(
            label,
            style: TextStyle(
              color: textColor ?? color,
              fontWeight: textWeight,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final appTheme = context.theme;
    if (_isLoading) {
      return const Center(
        child: AppLoader(),
      );
    }

    if (_isAuthor && _activityId != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _undoTask,
          icon: const Icon(Icons.undo_rounded, size: 18),
          label: Text(
            AppLocalizations.of(context).taskDetailUndoButton,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: appTheme.textPrimary,
            backgroundColor: appTheme.surface,
            side: BorderSide(
              color: appTheme.border.withValues(alpha: 0.85),
              width: 1.2,
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
