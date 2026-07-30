import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/tasks/domain/models/task_approval_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/pending_approvals_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';

/// Sprint 1 Modo Padres: bandeja de aprobaciones para adultos owner/admin.
///
/// Lista las submisiones en estado `pending` y permite aprobarlas o rechazarlas
/// con motivo. Las acciones invocan `verify_task_transaction` /
/// `reject_task_v1` (RPCs que validan rol del lado servidor).
///
/// Si el usuario no esta en modo "Modo Padres" (no puede gestionar un hogar
/// familiar premium), la pantalla muestra el placeholder hacia el paywall.
class PendingApprovalsScreen extends ConsumerWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final available = ref.watch(parentModeAvailableProvider);
    final eligible = ref.watch(parentModeEligibleProvider);

    if (!eligible) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: Text(t.pendingApprovalsAppBarShortTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              t.pendingApprovalsLockedNotice,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
        ),
      );
    }

    if (!available) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: Text(t.pendingApprovalsAppBarShortTitle)),
        body: const _LockedHero(),
      );
    }

    final approvalsAsync = ref.watch(pendingTaskApprovalsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(t.pendingApprovalsAppBarShortTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(pendingTaskApprovalsProvider),
          ),
        ],
      ),
      body: approvalsAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: AppLoader()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              t.pendingApprovalsLoadError(e.toString()),
              style: TextStyle(color: theme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyState(theme: theme);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pendingTaskApprovalsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ApprovalCard(approval: items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ApprovalCard extends ConsumerStatefulWidget {
  const _ApprovalCard({required this.approval});
  final TaskApprovalModel approval;

  @override
  ConsumerState<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends ConsumerState<_ApprovalCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final a = widget.approval;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.divider.withValues(alpha: 0.74)),
        boxShadow: AppElevation.card(
          color: theme.shadow,
          isDarkMode: theme.isDarkMode,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.accentGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.taskTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.14,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).pendingApprovalsSubmittedBy(a.submittedByName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RewardChip(
                icon: Icons.star_rounded,
                color: AppColors.xpGold,
                label: '${a.xpReward} XP',
              ),
              const SizedBox(width: 8),
              _RewardChip(
                icon: Icons.monetization_on_rounded,
                color: AppColors.coinGreen,
                label: '${a.coinReward} coins',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 9,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _onReject,
                  icon: const Icon(Icons.close_rounded, size: 19),
                  label: Text(
                    AppLocalizations.of(context).pendingApprovalsRejectButton,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentRed,
                    minimumSize: const Size(0, 46),
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    side: BorderSide(
                      color: AppColors.accentRed.withValues(alpha: 0.76),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    textStyle: AppTypography.caption.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 11,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _onApprove,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: Text(
                    AppLocalizations.of(context).pendingApprovalsApproveButton,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    textStyle: AppTypography.cardTitle.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onApprove() async {
    // Haptico inmediato al tap, igual que completar una tarea en Hoy/Inicio:
    // el feedback fisico acompaña la intencion, no el resultado del RPC.
    AppHaptics.success();
    setState(() => _busy = true);
    try {
      // Construimos un TaskModel minimo para reusar approvePendingTask del
      // notifier — solo le importa el id para invocar la RPC.
      final stub = TaskModel.minimalForApproval(id: widget.approval.taskId);
      final res =
          await ref.read(tasksProvider.notifier).approvePendingTask(stub);
      if (!mounted) return;
      if (res != null) {
        _snack(
          AppLocalizations.of(context).pendingApprovalsApprovedSnack(
            widget.approval.coinReward,
          ),
        );
      } else {
        _snack(
          AppLocalizations.of(context).pendingApprovalsApproveErrorRetry,
          type: AppSnackBarType.error,
        );
      }
    } catch (error, stackTrace) {
      log.e(
        'Approve pending task failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _snack(
          AppLocalizations.of(context).pendingApprovalsApproveErrorRetry,
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onReject() async {
    final reason = await _askReason(context);
    if (reason == null) return;
    setState(() => _busy = true);
    try {
      final stub = TaskModel.minimalForApproval(id: widget.approval.taskId);
      final ok = await ref
          .read(tasksProvider.notifier)
          .rejectPendingTask(stub, reason: reason.isEmpty ? null : reason);
      if (!mounted) return;
      if (ok) {
        _snack(AppLocalizations.of(context).pendingApprovalsRejectedSnack);
      } else {
        _snack(
          AppLocalizations.of(context).pendingApprovalsRejectErrorRetry,
          type: AppSnackBarType.error,
        );
      }
    } catch (error, stackTrace) {
      log.e(
        'Reject pending task failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        _snack(
          AppLocalizations.of(context).pendingApprovalsRejectErrorRetry,
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg, {AppSnackBarType type = AppSnackBarType.success}) {
    AppSnackBar.show(
      context,
      message: msg,
      type: type,
      duration: const Duration(milliseconds: 1500),
    );
  }

  Future<String?> _askReason(BuildContext ctx) async {
    final t = AppLocalizations.of(ctx);
    final controller = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(t.pendingApprovalsRejectDialogTitle),
          content: TextField(
            controller: controller,
            maxLength: 200,
            autofocus: true,
            decoration: InputDecoration(
              hintText: t.pendingApprovalsRejectDialogHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(t.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentRed,
              ),
              child: Text(t.pendingApprovalsRejectButton),
            ),
          ],
        );
      },
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final AppThemeColors theme;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.task_alt_rounded,
              size: 56,
              color: AppColors.accentGreen,
            ),
            const SizedBox(height: 16),
            Text(
              t.pendingApprovalsEmptyTitle,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 18,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.pendingApprovalsEmptyBody,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedHero extends StatelessWidget {
  const _LockedHero();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              t.pendingApprovalsLockedTitle,
              style: AppTypography.sectionTitle.copyWith(
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.pendingApprovalsLockedBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
