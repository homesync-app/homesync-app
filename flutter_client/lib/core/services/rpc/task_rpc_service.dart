import 'package:homesync_client/core/models/task_completion_result.dart';

import 'base_rpc_service.dart';

class TaskRpcService extends BaseRpcService {
  TaskRpcService({required super.clientOverride});

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
    List<int> recurrenceWeekdays = const [],
    List<int> recurrenceMonthDays = const [],
  }) async {
    return executeWithRetry(() async {
      final userId = await requireCurrentUserId();

      final response = await client.rpc(
        'create_task',
        params: {
          'p_user_id': userId,
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
          'p_recurrence_weekdays': recurrenceWeekdays,
          'p_recurrence_month_days': recurrenceMonthDays,
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
    DateTime? completedAt,
  }) async {
    return executeWithRetry(() async {
      final userId = await requireCurrentUserId();
      final requestId = generateRequestId();

      final response = await client.rpc(
        'complete_task_v1',
        params: {
          'p_request_id': requestId,
          'p_user_ids': userIds ?? [userId],
          'p_task_id': taskId,
          'p_household_id': householdId,
          'p_xp_reward': xpReward,
          'p_coin_reward': coinReward,
          'p_task_title': taskTitle,
          if (completedAt != null)
            'p_completed_at': completedAt.toIso8601String(),
        },
      );

      final result = TaskCompletionResult.fromRpcResponse(response);
      if (!result.success) {
        throw Exception(
          result.message.isNotEmpty
              ? result.message
              : 'No se pudo completar la tarea',
        );
      }

      return result;
    });
  }

  Future<Map<String, dynamic>> completeTasksBatch({
    required List<String> taskIds,
    required String householdId,
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return executeWithRetry(() async {
      final userId = await requireCurrentUserId();
      final requestId = generateRequestId();

      final response = await client.rpc(
        'complete_tasks_batch',
        params: {
          'p_request_id': requestId,
          'p_user_ids': userIds ?? [userId],
          'p_task_ids': taskIds,
          'p_household_id': householdId,
          if (completedAt != null)
            'p_completed_at': completedAt.toIso8601String(),
        },
      );

      final Map<String, dynamic> r = response as Map<String, dynamic>;
      if (r['success'] != true) {
        throw Exception(
          r['message'] ?? 'Error al completar las tareas',
        );
      }
      return r;
    });
  }

  Future<Map<String, dynamic>> verifyTaskTransaction({
    required String taskId,
    String? nextDueAt,
  }) async {
    final userId = await requireCurrentUserId();
    final requestId = generateRequestId();

    final rawResponse = await client.rpc(
      'approve_task_v1',
      params: {
        'p_request_id': requestId,
        'p_user_id': userId,
        'p_task_id': taskId,
        'p_verified_by': userId,
        'p_next_due_at': nextDueAt,
      },
    );

    final response = Map<String, dynamic>.from(rawResponse as Map);
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
    final userId = await requireCurrentUserId();
    final requestId = generateRequestId();

    final rawResponse = await client.rpc(
      'reject_task_v1',
      params: {
        'p_request_id': requestId,
        'p_user_id': userId,
        'p_task_id': taskId,
        'p_rejected_by': userId,
        'p_reason': reason,
      },
    );

    final response = Map<String, dynamic>.from(rawResponse as Map);
    return {
      'success': response['success'] ?? false,
      'message': response['message'] ?? '',
      'data': response,
    };
  }

  Future<Map<String, dynamic>> deleteTask({
    required String taskId,
  }) async {
    final rawResponse = await client.rpc(
      'delete_task_v1',
      params: {'p_task_id': taskId},
    );

    final response = Map<String, dynamic>.from(rawResponse as Map);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'No se pudo borrar la tarea');
    }
    return response;
  }

  Future<List<Map<String, dynamic>>> getTasks({
    int limit = 100,
    int offset = 0,
  }) async {
    return executeWithRetry(() async {
      final userId = await requireCurrentUserId();

      final householdMembers = await client
          .from('household_members')
          .select('household_id')
          .eq('user_id', userId)
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
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'object_task_v2',
      params: {
        'p_task_id': taskId,
        'p_user_id': userId,
        'p_reason': reason,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> undoTaskCompletion({
    required String activityId,
  }) async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'undo_task_completion_v1',
      params: {
        'p_activity_id': activityId,
        'p_user_id': userId,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> restoreTaskCoins({
    required String taskId,
  }) async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'restore_task_coins',
      params: {
        'p_task_id': taskId,
        'p_user_id': userId,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTaskHistory({int limit = 50}) async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'get_task_history',
      params: {
        'p_user_id': userId,
        'p_limit': limit,
      },
    );

    return List<Map<String, dynamic>>.from(response);
  }
}
