import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';
import 'package:homesync_client/features/tasks/domain/models/task_approval_model.dart';

/// Sprint 1 Modo Padres: aprobaciones pendientes del hogar actual.
///
/// Lee `get_pending_approvals(p_household_id)`. La RPC ya filtra por
/// `is_current_household_member` asi que no necesitamos chequeo extra del lado
/// cliente. Si el hogar no esta cargado todavia o el usuario no es admin, el
/// listado queda vacio.
final pendingTaskApprovalsProvider =
    FutureProvider<List<TaskApprovalModel>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return const [];

  final client = ref.watch(supabaseClientProvider);
  try {
    final result = await client.rpc(
      'get_pending_approvals',
      params: {'p_household_id': householdId},
    );
    if (result is! List) return const [];
    return result
        .whereType<Map>()
        .map(
          (row) => TaskApprovalModel.fromMap(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList();
  } catch (e, stack) {
    log.e(
      'get_pending_approvals failed',
      error: e,
      stackTrace: stack,
    );
    return const [];
  }
});

/// Wrapper de acciones de aprobacion. Encapsula las RPCs versionadas de
/// aprobacion/rechazo en `TaskRpcService` y refresca
/// el listado de pendientes despues de cada decision.
class TaskApprovalActions {
  final Ref _ref;
  TaskApprovalActions(this._ref);

  TaskRpcService get _rpc => TaskRpcService(
        clientOverride: _ref.read(supabaseClientProvider),
      );

  Future<bool> approve(String taskId) async {
    final result = await _rpc.verifyTaskTransaction(taskId: taskId);
    if (result['success'] == true) {
      _ref.invalidate(pendingTaskApprovalsProvider);
      return true;
    }
    log.w('verifyTaskTransaction failed: ${result['message']}');
    return false;
  }

  Future<bool> reject(String taskId, {String? reason}) async {
    final result = await _rpc.rejectTaskTransaction(
      taskId: taskId,
      reason: reason,
    );
    if (result['success'] == true) {
      _ref.invalidate(pendingTaskApprovalsProvider);
      return true;
    }
    log.w('rejectTaskTransaction failed: ${result['message']}');
    return false;
  }
}

final taskApprovalActionsProvider = Provider<TaskApprovalActions>((ref) {
  return TaskApprovalActions(ref);
});
