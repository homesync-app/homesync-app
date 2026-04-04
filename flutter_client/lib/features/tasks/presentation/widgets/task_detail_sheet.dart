import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/tasks/data/repositories/supabase_task_repository.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> taskData;
  final VoidCallback? onChanged;

  const TaskDetailSheet({super.key, required this.taskData, this.onChanged});

  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> taskData, {
    VoidCallback? onChanged,
  }) {
    return showModalBottomSheet(
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
  String get _title => _task.title;
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
  String get _completedByName =>
      (_completedUser?['full_name'] as String?) ?? 'Alguien';
  String? get _completedByAvatar => _completedUser?['avatar_url'] as String?;
  String? get _completedById => _completedUser?['id'] as String?;
  String get _currentUserId => ref.read(currentUserIdProvider) ?? '';
  bool get _isAuthor => _completedById == _currentUserId;
  bool get _hasCompletionRecord =>
      _activityId != null || widget.taskData['completed_at'] != null;

  int _readInt(dynamic primary,
      [dynamic fallback1, dynamic fallback2, dynamic fallback3]) {
    for (final candidate in [primary, fallback1, fallback2, fallback3]) {
      if (candidate is num && candidate.toInt() > 0) return candidate.toInt();
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0;
  }

  (String, Color, IconData) get _statusInfo {
    if (_activityId != null) {
      return ('Completada', AppColors.accentTeal, Icons.check_circle_rounded);
    }

    return switch (_status) {
      TaskStatus.pendingVerification || TaskStatus.verified => (
          'Completada',
          AppColors.accentTeal,
          Icons.check_circle_rounded
        ),
      TaskStatus.objected => (
          'En disputa',
          AppColors.accentRed,
          Icons.warning_amber_rounded
        ),
      _ => ('Pendiente', AppColors.textMuted, Icons.schedule_rounded),
    };
  }

  Future<void> _undoTask() async {
    if (_activityId == null) {
      _showSnack(
          'No se puede deshacer: actividad no encontrada', AppColors.error);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(taskRepositoryProvider);
      final result = await repo.undoTaskCompletion(_activityId!);
      result.fold(
        (failure) => _showSnack('No se pudo deshacer', AppColors.error),
        (_) {
          widget.onChanged?.call();
          if (mounted) Navigator.pop(context);
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
        _showSnack('No se pudo deshacer', AppColors.error);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusLabel, statusColor, statusIcon) = _statusInfo;
    final categoryColor = CategoryMapping.getCategoryColor(_category);
    final categoryIcon = CategoryMapping.getCategoryMaterialIcon(_category);
    final categoryLabel =
        CategoryMapping.categoryNames[_category.toLowerCase()] ?? _category;
    final completedAt = widget.taskData['completed_at'];
    final dateStr = completedAt != null
        ? DateFormat("d MMM '·' HH:mm", 'es')
            .format(DateTime.parse(completedAt as String).toLocal())
        : 'Sin registro';

    return Container(
      margin: const EdgeInsets.only(top: 56),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalle de tarea',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
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
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.divider.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(categoryIcon,
                                    size: 26, color: categoryColor),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildChip(
                                icon: categoryIcon,
                                label: categoryLabel,
                                color: categoryColor,
                              ),
                              _buildChip(
                                icon: _task.isRecurring
                                    ? Icons.event_repeat_rounded
                                    : Icons.edit_calendar_rounded,
                                label: _task.isRecurring
                                    ? _task.recurrenceLabel
                                    : 'Sin programar',
                                color: _task.isRecurring
                                    ? AppColors.accentGold
                                    : AppColors.accentRed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.divider.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatColumn(
                                  icon: Icons.star_rounded,
                                  iconColor: AppColors.accentGold,
                                  value: '+$_xpReward XP',
                                  label: 'Experiencia',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 58,
                                color: AppColors.divider,
                              ),
                              Expanded(
                                child: _buildStatColumn(
                                  icon: Icons.monetization_on_rounded,
                                  iconColor: AppColors.accentGreen,
                                  value: '+$_coinReward coins',
                                  label: 'Recompensa',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                CustomUserAvatar(
                                  name: _completedByName,
                                  avatarUrl: _completedByAvatar,
                                  radius: 16,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _hasCompletionRecord
                                            ? 'La completó'
                                            : 'Responsable',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _completedByName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (completedAt != null)
                                  Text(
                                    DateFormat('HH:mm').format(
                                        DateTime.parse(completedAt as String)
                                            .toLocal()),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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
                        padding: const EdgeInsets.all(16),
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
                            const Text(
                              'Comentario',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _comment!,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    IconData? icon,
    Color? iconColor,
    String? avatarName,
    String? avatarUrl,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        if (avatarName != null)
          CustomUserAvatar(
            name: avatarName,
            avatarUrl: avatarUrl,
            radius: 18,
          )
        else
          Icon(icon, size: 24, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_isAuthor && _activityId != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _undoTask,
          icon: const Icon(Icons.undo_rounded, size: 18),
          label: const Text(
            'Deshacer',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            side: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
