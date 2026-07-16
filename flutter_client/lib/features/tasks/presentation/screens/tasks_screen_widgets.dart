part of 'tasks_screen.dart';

/// Widgets de presentación extraídos de `tasks_screen.dart` (god file) para
/// reducir su tamaño. Son `part of` la misma librería, así que comparten
/// imports y acceso a símbolos privados.

class _TodayDoneCelebration extends StatelessWidget {
  final String message;

  const _TodayDoneCelebration({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: AppColors.accentGreen.withValues(alpha: 0.26),
          ),
          boxShadow: [
            ...theme.cardShadow,
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyStrong.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Section Header

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color? color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              icon,
              size: 16,
              color: themeColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              // w800: la disciplina de pesos reserva w900 para heroAmount.
              fontWeight: FontWeight.w800,
              color: theme.textPrimary.withValues(alpha: 0.82),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// TaskModel Card (now typed with TaskModel model)

class _TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback onSchedule;
  final VoidCallback onEdit;
  final VoidCallback onCompletedFeedback;

  const _TaskCard({
    super.key,
    required this.task,
    required this.onSchedule,
    required this.onEdit,
    required this.onCompletedFeedback,
  });

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  bool _isExpanded = false;
  bool _isSubmitting = false;

  String _recurrenceLabel(AppLocalizations t, String? recurrenceType) {
    switch (recurrenceType) {
      case 'daily':
        return t.createTaskRecurrenceDaily;
      case 'weekly':
        return t.createTaskRecurrenceWeekly;
      case 'monthly':
        return t.createTaskRecurrenceMonthly;
      case 'custom':
        return t.createTaskRecurrenceCustom;
      default:
        return t.createTaskRecurrenceNone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    final members =
        ref.watch(householdMembersProvider).value ?? const <MemberModel>[];
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final assignedMember =
        members.where((member) => member.userId == task.assignedTo).firstOrNull;
    final isFamilyMode = caps.type == HouseholdType.family;
    // Approval actions are a premium feature (Modo Padres).
    // We gate on parentModeAvailableProvider (family + premium + adult) so
    // non-premium users and children never see approve/reject buttons.
    // Default to false while members are still loading — never grant adult
    // permissions to an unknown viewer.
    final parentModeActive = ref.watch(parentModeAvailableProvider);
    final isAdultView = isFamilyMode &&
        parentModeActive &&
        (currentMember?.canApprove ?? false);
    // Teens and children must send completions through the adult review
    // queue, but only if the household has approvals enabled. Mirrors the SQL
    // logic in public.should_require_task_approval so the dialog matches what
    // the server will actually do.
    final approvalMode =
        ref.watch(currentHouseholdProvider).value?.taskApprovalMode;
    final approvalEnabled = ref.watch(taskApprovalEnabledProvider);
    final requiresApprovalSubmission = isFamilyMode &&
        approvalEnabled &&
        (currentMember?.needsSubmissionApproval(approvalMode) ?? false);
    final isOpenTask = task.assignedTo == null;
    final isAssignedToCurrentUser = task.assignedTo == currentUserId;
    final localizedTitle = localizedTaskTitle(
      AppLocalizations.of(context),
      task,
    );

    // Resolve dynamic category data
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        for (final category in list) {
          if (category.id == task.category) {
            return category;
          }
        }
        return null;
      },
      orElse: () => null,
    );

    final categoryColor = categoryData != null
        ? AppColors.fromHex(categoryData.color)
        : CategoryMapping.getCategoryColor(task.category);
    final categoryLabel = categoryData != null
        ? localizedTaskCategoryName(AppLocalizations.of(context), categoryData)
        : null;
    // El server garantiza al menos 1 coin por completación para niños
    // (complete_task_v1); el badge refleja lo que este usuario va a ganar.
    final displayCoins = (currentMember?.isChild ?? false)
        ? (task.coinReward < 1 ? 1 : task.coinReward)
        : task.coinReward;
    final restingBorderColor = _isExpanded
        ? categoryColor.withValues(alpha: 0.3)
        : (task.isOverdue
            ? AppColors.accentRed.withValues(alpha: 0.3)
            : theme.border.withValues(alpha: 0.9));

    return AppCompletionFeedback(
      isCompleting: _isSubmitting,
      accentColor: categoryColor,
      surfaceColor: theme.surface,
      borderColor: restingBorderColor,
      boxShadow: _isExpanded ? theme.modalShadow : theme.cardShadow,
      borderRadius: BorderRadius.circular(22),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      borderWidth: _isExpanded ? 1.5 : 1.2,
      popScale: 0.014,
      shadowBaseAlpha: 0.04,
      shadowPulseAlpha: 0.06,
      shadowPulseBlur: 10,
      builder: (context, progress, pulse, completionColor) => Semantics(
        button: true,
        expanded: _isExpanded,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _isSubmitting
              ? null
              : () {
                  AppHaptics.tap();
                  setState(() => _isExpanded = !_isExpanded);
                },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            localizedTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            // Rol cardTitle (16/700/-0.2): w800 hacía gritar
                            // a todas las cards a la vez.
                            style: AppTypography.cardTitle.copyWith(
                              height: 1.12,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                        if (!_isExpanded && _isSubmitting) ...[
                          const SizedBox(width: 10),
                          _completionBadge(categoryColor),
                        ] else if (!_isExpanded &&
                            (task.xpReward > 0 || displayCoins > 0)) ...[
                          const SizedBox(width: 10),
                          _rewardBadge(task.xpReward, displayCoins),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (categoryLabel != null)
                                _pill(
                                  icon: CategoryMapping.getCategoryMaterialIcon(
                                    task.category ?? '',
                                  ),
                                  label: categoryLabel,
                                  color: categoryColor,
                                  background:
                                      categoryColor.withValues(alpha: 0.10),
                                  borderAlpha: 0.16,
                                  textWeight: FontWeight.w700,
                                ),
                              if (task.isRecurring)
                                _pill(
                                  icon: Icons.event_repeat_rounded,
                                  label: _recurrenceLabel(
                                    AppLocalizations.of(context),
                                    task.recurrenceType,
                                  ),
                                  color: AppColors.accentGold,
                                  background: AppColors.accentGold.withValues(
                                    alpha: 0.16,
                                  ),
                                ),
                              // Sin pill "Vencida": en esta lista toda tarea
                              // vencida ya vive bajo el header VENCIDAS y
                              // lleva el borde rojizo — la pill era una
                              // tercera codificación del mismo dato.
                              if (isFamilyMode && task.isPendingApproval)
                                _pill(
                                  icon: Icons.hourglass_top_rounded,
                                  label: AppLocalizations.of(context)
                                      .tasksPillInReview,
                                  color: AppColors.primary,
                                  background:
                                      AppColors.primary.withValues(alpha: 0.12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ClipRect(
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    heightFactor: _isExpanded ? 1.0 : 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Column(
                        children: [
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  theme.divider.withValues(alpha: 0.34),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Minors (teens + children) cannot edit, schedule,
                              // or reshape tasks. Only adults manage them.
                              if (!requiresApprovalSubmission) ...[
                                Expanded(
                                  child: _buildActionTilePremium(
                                    icon: Icons.edit_rounded,
                                    label:
                                        AppLocalizations.of(context).commonEdit,
                                    color: AppColors.accentGold,
                                    onTap: widget.onEdit,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildActionTilePremium(
                                    icon: Icons.schedule_rounded,
                                    label: AppLocalizations.of(context)
                                        .tasksActionSchedule,
                                    color: AppColors.primary,
                                    onTap: widget.onSchedule,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: isFamilyMode
                                    ? _buildFamilyTaskAction(
                                        isAdultView: isAdultView,
                                        requiresApprovalSubmission:
                                            requiresApprovalSubmission,
                                        isOpenTask: isOpenTask,
                                        isAssignedToCurrentUser:
                                            isAssignedToCurrentUser,
                                        assignedMember: assignedMember,
                                      )
                                    : _buildActionTilePremium(
                                        icon: Icons.check_rounded,
                                        label: _isSubmitting
                                            ? AppLocalizations.of(context)
                                                .tasksActionCompleting
                                            : AppLocalizations.of(context)
                                                .tasksActionComplete,
                                        color: AppColors.accentGreen,
                                        onTap: _isSubmitting
                                            ? null
                                            : _completeTask,
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyTaskAction({
    required bool isAdultView,
    required bool requiresApprovalSubmission,
    required bool isOpenTask,
    required bool isAssignedToCurrentUser,
    required MemberModel? assignedMember,
  }) {
    final t = AppLocalizations.of(context);
    final completingLabel =
        _isSubmitting ? t.tasksActionCompleting : t.tasksActionComplete;
    if (widget.task.isPendingApproval) {
      if (!isAdultView) {
        return _buildInfoBanner(
          icon: Icons.hourglass_top_rounded,
          text: t.tasksStatusWaitingForAdult,
          color: AppColors.primary,
        );
      }

      return _buildInfoBanner(
        icon: Icons.hourglass_top_rounded,
        text: t.tasksStatusWaitingReview,
        color: AppColors.primary,
      );
    }

    if (isOpenTask) {
      return _buildActionTilePremium(
        icon: Icons.check_rounded,
        label: completingLabel,
        color: AppColors.primary,
        onTap: _isSubmitting
            ? null
            : () {
                if (requiresApprovalSubmission) {
                  _confirmOpenTaskCompletion(requiresApproval: true);
                } else {
                  _completeTask();
                }
              },
      );
    }

    if (isAssignedToCurrentUser) {
      if (requiresApprovalSubmission) {
        return _buildActionTilePremium(
          icon: Icons.send_rounded,
          label:
              _isSubmitting ? t.tasksActionSending : t.tasksActionSendForReview,
          color: AppColors.primary,
          onTap: _isSubmitting ? null : _submitTaskForApproval,
        );
      }

      return _buildActionTilePremium(
        icon: Icons.check_rounded,
        label: completingLabel,
        color: AppColors.accentGreen,
        onTap: _isSubmitting ? null : _completeTask,
      );
    }

    final ownerName =
        assignedMember?.displayName ?? t.familyTasksLockedOwnerFallback;
    if (isAdultView) {
      return _buildActionTilePremium(
        icon: Icons.check_rounded,
        label: completingLabel,
        color: AppColors.primary,
        onTap: _isSubmitting
            ? null
            : () => _confirmAdultTakeoverCompletion(ownerName),
      );
    }

    return _buildInfoBanner(
      icon: Icons.lock_outline_rounded,
      text: t.tasksStatusBelongsTo(ownerName),
      color: AppColors.textMuted,
    );
  }

  Widget _completionBadge(Color categoryColor) {
    final color = AppCompletionFeedback.completionColor(categoryColor);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTilePremium({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              setState(() => _isExpanded = false);
              onTap();
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.textMuted.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: onTap == null
                ? AppColors.textMuted.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: onTap == null ? AppColors.textMuted : color,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: onTap == null ? AppColors.textMuted : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOpenTaskCompletion({
    required bool requiresApproval,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final members =
        ref.read(householdMembersProvider).value ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final t = AppLocalizations.of(context);
    final actorName = currentMember?.displayName ?? t.familyTasksActorFallback;
    final localizedTitle = localizedTaskTitle(t, widget.task);

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
      await _submitTaskForApproval();
    } else {
      await _completeTask();
    }
  }

  Future<void> _confirmAdultTakeoverCompletion(String ownerName) async {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final confirmed = await AppSheet.show<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.modal),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.divider.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handshake_rounded,
                      size: 36,
                      color: AppColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.tasksTakeoverHeading(ownerName),
                    style: AppTypography.sectionTitle.copyWith(
                      fontSize: 22,
                      color: theme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.tasksTakeoverPrompt,
                    style: AppTypography.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: theme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                            side: BorderSide(color: theme.border),
                          ),
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            t.commonClose,
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 15,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            t.tasksTakeoverConfirm,
                            style: AppTypography.bodyStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (!confirmed) return;
    await _completeTask();
  }

  Future<void> _submitTaskForApproval() async {
    setState(() => _isSubmitting = true);
    // El notifier ya hace silentRefresh + invalida los providers de
    // aprobaciones/actividad: invalidar acá duplicaba los fetch.
    try {
      await ref.read(tasksProvider.notifier).submitTaskForApproval(widget.task);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppLocalizations.of(context).familyTasksSubmittedSnack,
        type: AppSnackBarType.info,
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e) {
      // El notifier relanza el fallo: sin este catch el spinner se reseteaba
      // sin ningún aviso y el error moría como excepción async sin manejar.
      if (mounted) {
        AppSnackBar.show(
          context,
          message:
              AppLocalizations.of(context).commonErrorWithDetails(e.toString()),
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _completeTask() async {
    AppHaptics.tap();
    // Snapshot ANTES del update optimista: al completar, el rebuild recalcula
    // isFinalTodayTask con la tarea ya "cerrada" (todayTasksLeft pasa a 0) y
    // widget.onCompletedFeedback apuntaría al widget nuevo con el flag en
    // false — la celebración de "todo listo por hoy" nunca disparaba para
    // tareas recurrentes.
    final onCompletedFeedback = widget.onCompletedFeedback;
    setState(() => _isSubmitting = true);
    try {
      final result =
          await ref.read(tasksProvider.notifier).completeTask(widget.task);
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      if (result == null) {
        AppSnackBar.show(
          context,
          message: t.tasksSnackCompleteError,
          type: AppSnackBarType.error,
        );
      } else {
        onCompletedFeedback();
        AppSnackBar.show(
          context,
          message: t.tasksSnackCompleted,
          type: AppSnackBarType.success,
          duration: const Duration(milliseconds: 1500),
        );
        // Sin invalidates acá: el notifier ya hace silentRefresh (y
        // todayTasksProvider deriva de tasksProvider); invalidar
        // recentActivityProvider tiraba abajo su stream realtime y causaba
        // el doble refresh visible de los movimientos del hogar.
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
    double borderAlpha = 0.22,
    FontWeight textWeight = FontWeight.w800,
    double gap = 5,
  }) {
    // Blend al 28%: al 18% los acentos claros (gold sobre tinte gold)
    // quedaban en ~2.3:1 de contraste.
    final readableColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.28),
      color,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: borderAlpha)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: readableColor),
          SizedBox(width: gap),
          Text(
            label,
            style: TextStyle(
              fontWeight: textWeight,
              fontSize: 11,
              color: readableColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge único de recompensa: XP y coins comparten pill para bajar el ruido
  /// visual de la card (antes eran dos badges apilados). Colores semánticos
  /// de AppColors: XP en dorado, coins en verde — igual que en el Home.
  Widget _rewardBadge(int xp, int coins) {
    TextStyle style(Color color) => AppTypography.caption.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: color,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (xp > 0) ...[
            const Icon(
              Icons.star_rounded,
              size: 12,
              color: AppColors.xpGold,
            ),
            const SizedBox(width: 3),
            Text('$xp', style: style(AppColors.xpGold)),
          ],
          if (xp > 0 && coins > 0) ...[
            const SizedBox(width: 6),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: AppColors.textMuted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (coins > 0) ...[
            const Icon(
              Icons.monetization_on_rounded,
              size: 12,
              color: AppColors.coinGreen,
            ),
            const SizedBox(width: 3),
            Text('$coins', style: style(AppColors.coinGreen)),
          ],
        ],
      ),
    );
  }
}
