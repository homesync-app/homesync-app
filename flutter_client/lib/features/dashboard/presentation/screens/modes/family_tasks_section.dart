import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
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
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
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
  // Tareas en proceso de salir visualmente (fade + collapse). Separado de
  // _completedTaskIds porque la pulse animation ocurre PRIMERO (al tap) y el
  // fade-out ocurre DESPUES de que el RPC confirma.
  final Set<String> _exitingTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final tasksAsync = ref.watch(todayTasksProvider);
    final isTeen = widget.currentMember?.isTeen ?? false;
    final sectionTitle = widget.isChild
        ? t.familyTasksTitleChild
        : isTeen
            ? t.familyTasksTitleTeen
            : t.homeCoupleTasksTitle;
    final ctaLabel =
        widget.isChild ? t.homeViewAllButton : t.homeViewWeekButton;
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
                        ? t.familyTasksEmptyChildSubtitle
                        : t.familyTasksEmptyOtherSubtitle,
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
    return AnimatedSize(
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 170),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.025),
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
      ),
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
    final members =
        ref.watch(householdMembersProvider).value ?? const <MemberModel>[];
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final isChildView = currentMember?.isChild ?? false;
    final isAdultView = currentMember?.canApprove ?? false;
    final approvalMode = ref.watch(householdProvider).value?.taskApprovalMode;
    final requiresApprovalSubmission =
        currentMember?.needsSubmissionApproval(approvalMode) ?? false;
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
        actionIcon = Icons.fact_check_rounded;
        onTap = () => _showApprovalActions(task, members);
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
      isExiting: _exitingTaskIds.contains(task.id),
      isChildView: isChildView,
      assignedMember: assignedMember,
      completedMember: completedMember,
      currentUserId: currentUserId,
      actionIcon: actionIcon,
      isActionEnabled: isActionEnabled,
      canApprovePending: currentMember?.canApprove ?? false,
      onTap: onTap,
    );
  }

  Future<void> _confirmOpenTaskCompletion(
    TaskModel task, {
    required bool requiresApproval,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final members =
        ref.read(householdMembersProvider).value ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final t = AppLocalizations.of(context);
    final actorName = currentMember?.displayName ?? t.familyTasksActorFallback;
    final localizedTitle = localizedTaskTitle(t, task);

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.familyTasksMarkTitle),
            content: Text(
              requiresApproval
                  ? t.familyTasksMarkBodyApproval(localizedTitle, actorName)
                  : t.familyTasksMarkBodyDirect(localizedTitle, actorName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.commonConfirm),
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
    final t = AppLocalizations.of(context);
    final ownerName =
        assignedMember?.displayName ?? t.familyTasksTakeoverOwnerFallback;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.familyTasksTakeoverTitle),
            content: Text(t.familyTasksTakeoverBody(ownerName)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.familyTasksTakeoverConfirm),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    // The adult is doing the takeover, so they are the performer.
    // Passing the child's userId would trigger the child's approval flow,
    // causing the task to land in pending_approval instead of completing.
    await _completeTask(task);
  }

  void _showTaskLockedMessage(MemberModel? assignedMember) {
    final t = AppLocalizations.of(context);
    final ownerName =
        assignedMember?.displayName ?? t.familyTasksLockedOwnerFallback;
    AppSnackBar.show(
      context,
      message: t.familyTasksLockedMessage(ownerName),
      type: AppSnackBarType.info,
    );
  }

  Future<void> _submitTaskForApproval(TaskModel task) async {
    if (_completedTaskIds.contains(task.id)) return;

    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).submitTaskForApproval(task);
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: t.familyTasksSubmittedSnack,
        type: AppSnackBarType.info,
      );
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: t.familyTasksSubmitError(e.toString()),
        type: AppSnackBarType.error,
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
    final t = AppLocalizations.of(context);
    final performer = members
        .where((member) => member.userId == task.completedBy)
        .firstOrNull;
    final performerName =
        performer?.displayName ?? t.familyTasksReviewPerformerFallback;
    final localizedTitle = localizedTaskTitle(t, task);

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
                  t.familyTasksReviewTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.familyTasksReviewBody(performerName, localizedTitle),
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
                    label: Text(t.familyTasksReviewApprove),
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
                    label: Text(t.familyTasksReviewReject),
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
      final t = AppLocalizations.of(context);
      if (result == null) {
        AppSnackBar.show(
          context,
          message: t.familyTasksApproveError,
          type: AppSnackBarType.error,
        );
      } else {
        AppSnackBar.show(
          context,
          message: t.familyTasksApproveSuccess,
          type: AppSnackBarType.success,
        );
        ref.invalidate(tasksProvider);
        ref.invalidate(todayTasksProvider);
        ref.invalidate(recentActivityProvider);
        ref.invalidate(statsControllerProvider);
      }
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: t.familyTasksApproveErrorWithDetails(e.toString()),
        type: AppSnackBarType.error,
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
      final t = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: t.familyTasksRejectSuccess,
        type: AppSnackBarType.info,
      );
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: t.familyTasksRejectError(e.toString()),
        type: AppSnackBarType.error,
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
    // Haptic inmediato al tap — feedback fisico tiene que coincidir con la
    // intencion del usuario, no con el resultado del RPC.
    HapticFeedback.mediumImpact();
    // Optimistic feed update INMEDIATO: la entrada del feed empieza a animar
    // ya, sin esperar al RPC. Cuando llega la data real, _mergeActivity
    // dedupea por task_id (ver dashboard_provider.dart) asi que el placeholder
    // se reemplaza transparentemente. En caso de fallo, invalidamos el
    // optimistic provider abajo para limpiar.
    ref.read(optimisticRecentActivityProvider.notifier).addTaskCompleted(task);
    try {
      log.d('[family] completing task id=${task.id} title=${task.title}');
      // Pausa breve para que la animacion de feedback del card (240ms internos)
      // tenga aire antes de que reordenemos la lista al invalidar.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final result = await ref
          .read(tasksProvider.notifier)
          .completeTask(task, userIds: userIds);

      if (!mounted) return;

      if (result == null) {
        log.w('[family] task completion returned null id=${task.id}');
        // Rollback de la entrada optimista del feed.
        ref.invalidate(optimisticRecentActivityProvider);
        final t = AppLocalizations.of(context);
        AppSnackBar.show(
          context,
          message: t.homeFriendsTaskCompleteError,
          type: AppSnackBarType.error,
        );
        return;
      }

      log.i(
        '[family] task completion success id=${task.id} queued=${result.queued} message=${result.message}',
      );

      // Iniciar el fade-out del card. AnimatedSize + AnimatedOpacity en
      // FamilyTaskCard se encargan; el padre solo necesita esperar
      // exitAnimationDuration antes de invalidar para que la animacion se
      // vea completa.
      if (mounted) {
        setState(() => _exitingTaskIds.add(task.id));
      }
      await Future<void>.delayed(FamilyTaskCard.exitAnimationDuration);
      if (!mounted) return;

      final t = AppLocalizations.of(context);
      AppSnackBar.show(
        context,
        message: t.tasksSnackCompleted,
        type: AppSnackBarType.success,
      );
      ref.invalidate(statsControllerProvider);
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      // No invalidamos recentActivityProvider: es un StreamProvider con
      // realtime de Supabase + merge con el optimistic. Invalidar destruye
      // la subscripcion y pasa por AsyncLoading -> la seccion del feed se
      // pone en blanco. El stream emite la actualizacion real solo.
    } catch (e) {
      log.e('[family] task completion threw id=${task.id}', error: e);
      // Rollback de la entrada optimista del feed.
      ref.invalidate(optimisticRecentActivityProvider);
      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.show(
          context,
          message: t.commonErrorWithDetails(e.toString()),
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _completedTaskIds.remove(task.id);
          _exitingTaskIds.remove(task.id);
        });
      }
    }
  }

  Widget _buildEmptyState(AppThemeColors theme, String subtitle) {
    final isChild = widget.isChild;
    final t = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isChild
            ? const Color(0xFFFFF7ED)
            : theme.surfaceContainer.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isChild
              ? const Color(0xFFFFD7B3)
              : theme.border.withValues(alpha: 0.26),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isChild
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppColors.sage.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isChild ? Icons.celebration_rounded : Icons.task_alt_rounded,
              size: 18,
              color: isChild
                  ? const Color(0xFFF08B49)
                  : AppColors.sage.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.familyTasksEmptyTitle,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                  ),
                ),
              ],
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
