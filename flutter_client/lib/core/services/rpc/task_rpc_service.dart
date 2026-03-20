import 'base_rpc_service.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';

class TaskRpcService extends BaseRpcService {
  TaskRpcService({super.clientOverride});

  Future<String> createTask({
    required String title,
    String? description,
    String? category,
    String? assignedTo,
    String type = 'one_time',
    String difficulty = 'medium',
    int xpReward = 0,
    int coinReward = 0,
    String priority = 'medium',
    DateTime? dueAt,
    String? recurrenceType,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndAt,
  }) async {
    return executeWithRetry(() async {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await client.rpc(
        'create_task',
        params: {
          'p_user_id': user.id,
          'p_title': title,
          'p_category': category,
          'p_assigned_to': assignedTo,
          'p_type': type,
          'p_difficulty': difficulty,
          'p_xp_reward': xpReward,
          'p_coin_reward': coinReward,
          'p_priority': priority,
          'p_due_at': dueAt?.toIso8601String(),
          'p_recurrence_type': recurrenceType,
          'p_recurrence_interval': recurrenceInterval,
          'p_recurrence_end_at': recurrenceEndAt?.toIso8601String(),
        },
      );

      final taskId = response as String;

      if (description != null && description.isNotEmpty) {
        await client
            .from('tasks')
            .update({'description': description}).eq('id', taskId);
      }

      return taskId;
    });
  }

  Future<TaskCompletionResult> completeTaskTransaction({
    required String taskId,
    required String taskTitle,
    required int xpReward,
    required int coinReward,
    required String householdId,
    List<String>? userIds,
  }) async {
    return executeWithRetry(() async {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final requestId = generateRequestId();

      final response = await client.rpc(
        'complete_task_transaction',
        params: {
          'p_request_id': requestId,
          'p_user_ids': userIds ?? [user.id],
          'p_task_id': taskId,
          'p_household_id': householdId,
          'p_xp_reward': xpReward,
          'p_coin_reward': coinReward,
          'p_task_title': taskTitle,
        },
      );

      final result = TaskCompletionResult.fromRpcResponse(response);
      if (!result.success) {
        throw Exception(result.message.isNotEmpty
            ? result.message
            : 'No se pudo completar la tarea');
      }

      return result;
    });
  }

  Future<Map<String, dynamic>> verifyTaskTransaction({
    required String taskId,
    String? nextDueAt,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final requestId = generateRequestId();

    final response = await client.rpc(
      'verify_task_transaction',
      params: {
        'p_request_id': requestId,
        'p_user_id': user.id,
        'p_task_id': taskId,
        'p_verified_by': user.id,
        'p_next_due_at': nextDueAt,
      },
    );

    return {
      'success': response['success'] ?? false,
      'message': response['message'] ?? '',
      'data': response,
    };
  }

  Future<Map<String, dynamic>> rejectTaskTransaction({
    required String taskId,
    String? reason,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final requestId = generateRequestId();

    final response = await client.rpc(
      'reject_task_transaction',
      params: {
        'p_request_id': requestId,
        'p_user_id': user.id,
        'p_task_id': taskId,
        'p_rejected_by': user.id,
        'p_reason': reason,
      },
    );

    return {
      'success': response['success'] ?? false,
      'message': response['message'] ?? '',
      'data': response,
    };
  }

  Future<List<Map<String, dynamic>>> getTasks(
      {int limit = 100, int offset = 0}) async {
    return executeWithRetry(() async {
      final user = client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final householdMembers = await client
          .from('household_members')
          .select('household_id')
          .eq('user_id', user.id)
          .limit(1);

      if (householdMembers.isEmpty) {
        return [];
      }

      final householdId = householdMembers.first['household_id'];

      final response = await client
          .from('tasks')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response;
    });
  }

  Future<Map<String, dynamic>> objectTask({
    required String taskId,
    String? reason,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'object_task_v2',
      params: {
        'p_task_id': taskId,
        'p_user_id': user.id,
        'p_reason': reason,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> undoTaskCompletion({
    required String activityId,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'undo_task_completion',
      params: {
        'p_activity_id': activityId,
        'p_user_id': user.id,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> restoreTaskCoins(
      {required String taskId}) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'restore_task_coins',
      params: {
        'p_task_id': taskId,
        'p_user_id': user.id,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTaskHistory({int limit = 50}) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'get_task_history',
      params: {
        'p_user_id': user.id,
        'p_limit': limit,
      },
    );

    return List<Map<String, dynamic>>.from(response);
  }
}
