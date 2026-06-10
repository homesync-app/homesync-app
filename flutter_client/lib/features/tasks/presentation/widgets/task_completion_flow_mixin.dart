import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';

/// Shared "tap → complete task" flow for the home dashboards.
///
/// Before this mixin each home view (couple / solo / friends) reimplemented the
/// same orchestration — and the duplicated copies are exactly why a single bug
/// (the double activity-feed entry) had to be fixed in four places. Centralising
/// it means future fixes happen once.
///
/// The flow: guard against duplicate taps, a brief feedback delay so the card
/// animation reads as intentional, the RPC call, success/error snackbars, and
/// cleanup. View-specific work (e.g. provider invalidations) is supplied via
/// [onCompleted]; a custom failure message via [completionErrorMessage].
///
/// Note: the family dashboard keeps its own flow on purpose — it interleaves a
/// card exit animation and optimistic rollback that don't fit this template.
mixin TaskCompletionFlowMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Task ids currently animating through completion. Drives the card's
  /// "completing" state and guards against duplicate taps.
  final Set<String> completingTaskIds = <String>{};

  Future<void> runTaskCompletion(
    TaskModel task, {
    List<String>? userIds,
    String? completionErrorMessage,
    void Function(TaskCompletionResult result)? onCompleted,
  }) async {
    if (completingTaskIds.contains(task.id)) return;

    setState(() => completingTaskIds.add(task.id));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 360));
      final result = await ref
          .read(tasksProvider.notifier)
          .completeTask(task, userIds: userIds);
      if (!mounted) return;

      final t = AppLocalizations.of(context);
      if (result == null) {
        AppSnackBar.show(
          context,
          message: completionErrorMessage ??
              t.commonErrorWithDetails('completion failed'),
          type: AppSnackBarType.error,
        );
        return;
      }

      AppHaptics.success();
      AppSnackBar.show(
        context,
        message: t.tasksSnackCompleted,
        type: AppSnackBarType.success,
      );
      onCompleted?.call(result);
    } catch (e) {
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
        setState(() => completingTaskIds.remove(task.id));
      }
    }
  }
}
