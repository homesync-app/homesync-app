import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/tasks/domain/models/task_approval_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/pending_approvals_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';

/// Sprint 1 Modo Padres: bandeja de aprobaciones para owner/admin del hogar.
///
/// Lista las submisiones en estado `pending` y permite aprobarlas o rechazarlas
/// con motivo. Las acciones invocan `verify_task_transaction` /
/// `reject_task_transaction` (RPCs que validan rol del lado servidor).
///
/// Si el usuario no esta en modo "Modo Padres" (no es admin de un hogar
/// familiar premium), la pantalla muestra el placeholder hacia el paywall.
class PendingApprovalsScreen extends ConsumerWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final available = ref.watch(parentModeAvailableProvider);
    final eligible = ref.watch(parentModeEligibleProvider);

    if (!eligible) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: const Text('Aprobaciones')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Esta seccion es para administradores de hogares familiares.',
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
        appBar: AppBar(title: const Text('Aprobaciones')),
        body: const _LockedHero(),
      );
    }

    final approvalsAsync = ref.watch(pendingTaskApprovalsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Aprobaciones pendientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(pendingTaskApprovalsProvider),
          ),
        ],
      ),
      body: approvalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No pudimos cargar las aprobaciones: $e',
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
            onRefresh: () async =>
                ref.invalidate(pendingTaskApprovalsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                color: AppColors.accentGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a.taskTitle,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Enviada por ${a.submittedByName}',
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              _RewardChip(
                icon: Icons.star_rounded,
                color: AppColors.accentGold,
                label: '${a.xpReward} XP',
              ),
              _RewardChip(
                icon: Icons.monetization_on_rounded,
                color: AppColors.accentYellow,
                label: '${a.coinReward} coins',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentRed,
                    side: const BorderSide(color: AppColors.accentRed),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _onApprove,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Aprobar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
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
    setState(() => _busy = true);
    try {
      // Construimos un TaskModel minimo para reusar approvePendingTask del
      // notifier — solo le importa el id para invocar la RPC.
      final stub = TaskModel.minimalForApproval(id: widget.approval.taskId);
      final res = await ref.read(tasksProvider.notifier).approvePendingTask(stub);
      if (!mounted) return;
      if (res != null) {
        _snack('Aprobada. Se acreditaron ${widget.approval.coinReward} coins.');
      } else {
        _snack('No pudimos aprobar la tarea. Reintenta.');
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
      await ref
          .read(tasksProvider.notifier)
          .rejectPendingTask(stub, reason: reason.isEmpty ? null : reason);
      if (!mounted) return;
      _snack('Tarea rechazada.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<String?> _askReason(BuildContext ctx) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Motivo del rechazo'),
          content: TextField(
            controller: controller,
            maxLength: 200,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Por que no esta aprobada (opcional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogCtx, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentRed,
              ),
              child: const Text('Rechazar'),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Nada pendiente por ahora',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando alguien complete una tarea aparecera aca para que la revises.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Aprobacion de tareas',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Activa Modo Padres para revisar y aprobar lo que cumple cada miembro del hogar antes de acreditar los coins.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
