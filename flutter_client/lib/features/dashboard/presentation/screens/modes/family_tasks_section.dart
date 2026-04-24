import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_task_card.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

class FamilyTasksSection extends ConsumerStatefulWidget {
  final HouseholdCapabilities caps;
  final MemberModel? currentMember;
  final bool isChild;

  const FamilyTasksSection({
    super.key,
    required this.caps,
    required this.currentMember,
    required this.isChild,
  });

  @override
  ConsumerState<FamilyTasksSection> createState() => _FamilyTasksSectionState();
}

class _FamilyTasksSectionState extends ConsumerState<FamilyTasksSection> {
  final Set<String> _completedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tasksAsync = ref.watch(todayTasksProvider);
    final sectionTitle = widget.isChild ? 'Mis misiones' : 'Hoy en casa';
    final ctaLabel = widget.isChild ? 'Ver todas' : 'Ver semana';
    return _buildSectionStateSwitcher(
      child: tasksAsync.when(
        loading: () => KeyedSubtree(
          key: const ValueKey('tasks-loading'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeaderLoading(),
              const SizedBox(height: 12),
              _buildTasksLoadingState(theme),
            ],
          ),
        ),
        error: (_, __) => const SizedBox.shrink(key: ValueKey('tasks-error')),
        data: (tasks) {
          final reviewTasks = !widget.isChild
              ? tasks.where((task) => task.isPendingApproval).toList()
              : <TaskModel>[];
          final todayTasks = tasks
              .where((task) => task.isPending && !task.isPendingApproval)
              .where((task) => task.isDueToday)
              .toList()
            ..sort((a, b) {
              final aAssigned = a.assignedTo != null;
              final bAssigned = b.assignedTo != null;
              if (aAssigned != bAssigned) {
                return aAssigned ? -1 : 1;
              }
              return a.createdAt.compareTo(b.createdAt);
            });
          final overdueTasks = tasks
              .where((task) => task.isPending && !task.isPendingApproval)
              .where((task) => task.isOverdue)
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          final visibleOverdueTasks = overdueTasks.take(4).toList();
          final remainingOverdueCount =
              overdueTasks.length - visibleOverdueTasks.length;

          final visibleTasks = <TaskModel>[
            ...reviewTasks,
            ...visibleOverdueTasks,
            ...todayTasks,
          ];

          final header = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.7,
                ),
              ),
              TextButton(
                onPressed: () {
                  final index = indexForMainTab(
                    widget.caps,
                    MainTab.tasks,
                    currentMember: widget.currentMember,
                  );
                  if (index >= 0) {
                    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                  }
                },
                child: Text(ctaLabel),
              ),
            ],
          );

          if (visibleTasks.isEmpty) {
            return KeyedSubtree(
              key: const ValueKey('tasks-empty'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 12),
                  _buildEmptyState(
                    theme,
                    widget.isChild
                        ? 'Hoy podes descansar o mirar la tienda.'
                        : 'No hay tareas programadas para hoy.',
                  ),
                ],
              ),
            );
          }
          return KeyedSubtree(
            key: ValueKey(
              'tasks-data-${visibleTasks.length}-${overdueTasks.length}',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleTasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = visibleTasks[index];
                    return _buildTaskItem(task, theme);
                  },
                ),
                if (remainingOverdueCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.divider.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: theme.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            remainingOverdueCount == 1
                                ? 'Hay 1 tarea atrasada más pendiente.'
                                : 'Hay $remainingOverdueCount tareas atrasadas más pendientes.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionStateSwitcher({
    required Widget child,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTasksLoadingState(AppThemeColors theme) {
    return Column(
      children: [
        _buildTaskLoadingCard(theme),
        const SizedBox(height: 12),
        _buildTaskLoadingCard(theme),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.surfaceContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.divider.withValues(alpha: 0.08),
            ),
          ),
          child: const ShimmerLoading(height: 14, borderRadius: 10),
        ),
      ],
    );
  }

  Widget _buildTaskLoadingCard(AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.divider.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Row(
            children: [
              ShimmerLoading(height: 44, width: 44, borderRadius: 14),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(height: 15, width: 150, borderRadius: 10),
                    SizedBox(height: 8),
                    ShimmerLoading(height: 12, width: 110, borderRadius: 10),
                  ],
                ),
              ),
              SizedBox(width: 10),
              ShimmerLoading(height: 34, width: 34, borderRadius: 12),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ShimmerLoading(height: 32, borderRadius: 999),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ShimmerLoading(height: 32, borderRadius: 999),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, AppThemeColors theme) {
    final members = ref.watch(householdMembersNotifierProvider).valueOrNull ??
        const <MemberModel>[];
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChildView = currentMember?.isChild ?? false;
    final isAdultView = currentMember?.canApprove ?? true;
    final requiresApprovalSubmission =
        currentMember?.submissionRequiresApproval ?? false;
    final assignedMember =
        members.where((member) => member.userId == task.assignedTo).firstOrNull;
    final completedMember = members
        .where((member) => member.userId == task.completedBy)
        .firstOrNull;
    final isOpenTask = task.assignedTo == null;
    final isAssignedToCurrentUser = task.assignedTo == currentUserId;

    IconData actionIcon;
    VoidCallback? onTap;
    var isActionEnabled = true;

    if (task.isPendingApproval) {
      if (isAdultView) {
        actionIcon = Icons.history_rounded;
        isActionEnabled = false;
        onTap = null;
      } else if (isChildView) {
        actionIcon = Icons.check_circle_outline_rounded;
        isActionEnabled = false;
        onTap = null;
      } else {
        actionIcon = Icons.hourglass_top_rounded;
        isActionEnabled = false;
        onTap = null;
      }
    } else if (isOpenTask) {
      actionIcon = Icons.check_rounded;
      onTap = () {
        if (requiresApprovalSubmission) {
          _confirmOpenTaskCompletion(task, requiresApproval: true);
        } else {
          _completeTask(task);
        }
      };
    } else if (isAssignedToCurrentUser) {
      if (requiresApprovalSubmission) {
        actionIcon = Icons.send_rounded;
        onTap = () => _submitTaskForApproval(task);
      } else {
        actionIcon = Icons.check_rounded;
        onTap = () => _completeTask(task);
      }
    } else {
      if (isAdultView) {
        actionIcon = Icons.check_rounded;
        onTap = () => _confirmAdultTakeoverCompletion(task, assignedMember);
      } else {
        actionIcon = Icons.lock_outline_rounded;
        isActionEnabled = false;
        onTap = () => _showTaskLockedMessage(assignedMember);
      }
    }

    return FamilyTaskCard(
      task: task,
      isCompleting: _completedTaskIds.contains(task.id),
      isChildView: isChildView,
      assignedMember: assignedMember,
      completedMember: completedMember,
      currentUserId: currentUserId,
      actionIcon: actionIcon,
      isActionEnabled: isActionEnabled,
      onTap: onTap,
    );
  }

  Future<void> _confirmOpenTaskCompletion(
    TaskModel task, {
    required bool requiresApproval,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final members = ref.read(householdMembersNotifierProvider).valueOrNull ??
        const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final actorName = currentMember?.displayName ?? 'vos';

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Marcar tarea'),
            content: Text(
              requiresApproval
                  ? 'Se va a marcar "${task.title}" como realizada por $actorName y se enviará a revisión.'
                  : 'Se va a marcar "${task.title}" como realizada por $actorName.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    if (requiresApproval) {
      await _submitTaskForApproval(task);
    } else {
      await _completeTask(task);
    }
  }

  Future<void> _confirmAdultTakeoverCompletion(
    TaskModel task,
    MemberModel? assignedMember,
  ) async {
    final ownerName = assignedMember?.displayName ?? 'otro integrante';
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Completar tarea'),
            content: Text(
              'Esta tarea estaba asignada a $ownerName. Si seguís, se va a marcar como realizada por vos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Completar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final takeoverUserIds =
        assignedMember != null ? [assignedMember.userId] : null;
    await _completeTask(task, userIds: takeoverUserIds);
  }

  void _showTaskLockedMessage(MemberModel? assignedMember) {
    final ownerName = assignedMember?.displayName ?? 'otra persona';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Esta tarea le toca a $ownerName.'),
      ),
    );
  }

  Future<void> _submitTaskForApproval(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).submitTaskForApproval(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviada para revisión de un adulto.'),
        ),
      );
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos enviar la tarea: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _showApprovalActions(
    TaskModel task,
    List<MemberModel> members,
  ) async {
    final performer = members
        .where((member) => member.userId == task.completedBy)
        .firstOrNull;
    final performerName = performer?.displayName ?? 'este integrante';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = context.theme;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisar tarea',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$performerName marcó "${task.title}" como realizada.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _approvePendingTask(task);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aprobar tarea'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _rejectPendingTask(task);
                    },
                    icon: const Icon(Icons.reply_rounded),
                    label: const Text('Devolver para corregir'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _approvePendingTask(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      final result =
          await ref.read(tasksProvider.notifier).approvePendingTask(task);
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos aprobar la tarea.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea aprobada.')),
        );
        ref.invalidate(tasksProvider);
        ref.invalidate(todayTasksProvider);
        ref.invalidate(recentActivityProvider);
        ref.invalidate(statsControllerProvider);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos aprobar la tarea: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _rejectPendingTask(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).rejectPendingTask(task);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La tarea volvió a quedar pendiente.')),
      );
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos devolver la tarea: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _completeTask(
    TaskModel task, {
    List<String>? userIds,
  }) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      log.d('[family] completing task id=${task.id} title=${task.title}');
      final result = await ref
          .read(tasksProvider.notifier)
          .completeTask(task, userIds: userIds);

      if (!mounted) return;

      if (result == null) {
        log.w('[family] task completion returned null id=${task.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos completar la tarea. Intenta de nuevo.'),
          ),
        );
        return;
      }

      log.i(
        '[family] task completion success id=${task.id} queued=${result.queued} message=${result.message}',
      );
      ref.invalidate(statsControllerProvider);
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      log.e('[family] task completion threw id=${task.id}', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
      }
    }
  }

  Widget _buildEmptyState(AppThemeColors theme, String subtitle) {
    final isChild = widget.isChild;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, isChild ? 22 : 32, 22, 22),
      decoration: BoxDecoration(
        color: isChild
            ? const Color(0xFFFFF7ED)
            : theme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(isChild ? 28 : 24),
        border: Border.all(
          color: isChild
              ? const Color(0xFFFFD7B3)
              : theme.divider.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: isChild ? 58 : 48,
            height: isChild ? 58 : 48,
            decoration: BoxDecoration(
              color: isChild
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              isChild ? Icons.celebration_rounded : Icons.task_alt_rounded,
              size: isChild ? 30 : 48,
              color: isChild
                  ? const Color(0xFFF08B49)
                  : theme.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Todo al día',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isChild ? 13 : 14,
              height: 1.25,
              fontWeight: isChild ? FontWeight.w700 : FontWeight.w400,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderLoading extends StatelessWidget {
  const _SectionHeaderLoading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerLoading(height: 18, width: 136, borderRadius: 10),
        ShimmerLoading(height: 34, width: 72, borderRadius: 999),
      ],
    );
  }
}
