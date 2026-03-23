import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/repository_error_handler.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/core/offline/offline_action.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';

part 'supabase_task_repository.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final client = ref.read(supabaseClientProvider);
  final rpc = ref.read(taskRpcServiceProvider);
  return SupabaseTaskRepository(client: client, rpc: rpc, ref: ref);
}

/// Concrete Supabase implementation of TaskRepository.
/// Only this class can talk to Supabase about tasks.
class SupabaseTaskRepository
    with RepositoryErrorHandler
    implements TaskRepository {
  final SupabaseClient _client;
  final TaskRpcService _rpc;
  final Ref _ref;
  final OfflineQueueService _offlineQueue = OfflineQueueService();

  SupabaseTaskRepository({
    required SupabaseClient client,
    required TaskRpcService rpc,
    required Ref ref,
  })  : _client = client,
        _rpc = rpc,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  Future<void> _queueAction(OfflineAction action) async {
    await _offlineQueue.enqueueAction(
      actionType: action.type,
      payload: action.toMap(),
    );
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(String householdId,
      {int limit = 100, int offset = 0}) async {
    return executeWithHandling(() async {
      final raw = await _rpc.getTasks(limit: limit, offset: offset);
      return (raw as List)
          .map((t) => TaskModel.fromMap(t as Map<String, dynamic>))
          .toList();
    }, context: 'SupabaseTaskRepository.getTasks', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return executeWithHandling(
        () async {
          final householdId = await _rpc.requireHouseholdId();
          final result = await _rpc.completeTaskTransaction(
            taskId: task.id,
            taskTitle: task.title,
            xpReward: task.xpReward,
            coinReward: task.coinReward,
            householdId: householdId,
            userIds: userIds,
            completedAt: completedAt,
          );
          return result;
        },
        context: 'SupabaseTaskRepository.completeTask',
        isOnline: _isOnline,
        onOffline: () async {
          final userId = await _rpc.requireCurrentUserId();
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.rpc,
              target: 'complete_task_transaction',
              params: {
                'p_request_id': 'offline_' + DateTime.now().millisecondsSinceEpoch.toString(),
                'p_user_ids': userIds ?? [userId],
                'p_task_id': task.id,
                'p_household_id': await _rpc.requireHouseholdId(),
                'p_xp_reward': task.xpReward,
                'p_coin_reward': task.coinReward,
                'p_task_title': task.title,
                if (completedAt != null) 'p_completed_at': completedAt.toIso8601String(),
              },
            ),
          );
          return TaskCompletionResult(success: true, message: 'Encolado offline', queued: true);
        });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeTasksBatch(
    List<TaskModel> tasks, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return executeWithHandling(
        () async {
          final householdId = await _rpc.requireHouseholdId();
          final taskIds = tasks.map((t) => t.id).toList();
          final result = await _rpc.completeTasksBatch(
            taskIds: taskIds,
            householdId: householdId,
            userIds: userIds,
            completedAt: completedAt,
          );
          return result;
        },
        context: 'SupabaseTaskRepository.completeTasksBatch',
        isOnline: _isOnline,
        onOffline: () async {
          final userId = await _rpc.requireCurrentUserId();
          final taskIds = tasks.map((t) => t.id).toList();
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.rpc,
              target: 'complete_tasks_batch',
              params: {
                'p_request_id': 'offline_' + DateTime.now().millisecondsSinceEpoch.toString(),
                'p_user_ids': userIds ?? [userId],
                'p_task_ids': taskIds,
                'p_household_id': await _rpc.requireHouseholdId(),
                if (completedAt != null) 'p_completed_at': completedAt.toIso8601String(),
              },
            ),
          );
          return {'success': true, 'message': 'Lote encolado offline', 'queued': true};
        });
  }

  @override
  Future<Either<Failure, void>> verifyTask(
      String taskId, String verifiedByUserId) async {
    return executeWithHandling(
        () async {
          final updates = {
            'status': TaskStatus.verified.name,
            'last_verified_by': verifiedByUserId,
            'updated_at': DateTime.now().toIso8601String(),
          };
          await _client
              .from(AppConstants.tableTasks)
              .update(updates)
              .eq('id', taskId);
        },
        context: 'SupabaseTaskRepository.verifyTask',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: AppConstants.tableTasks,
              values: {
                'status': TaskStatus.verified.name,
                'last_verified_by': verifiedByUserId,
                'updated_at': DateTime.now().toIso8601String(),
              },
              filters: [OfflineFilter(column: 'id', value: taskId)],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> objectTask(
      String taskId, String objectedByUserId) async {
    return executeWithHandling(
        () async {
          final updates = {
            'status': TaskStatus.objected.name,
            'objected_by': objectedByUserId,
            'objected_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          await _client
              .from(AppConstants.tableTasks)
              .update(updates)
              .eq('id', taskId);
        },
        context: 'SupabaseTaskRepository.objectTask',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: AppConstants.tableTasks,
              values: {
                'status': TaskStatus.objected.name,
                'objected_by': objectedByUserId,
                'objected_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              },
              filters: [OfflineFilter(column: 'id', value: taskId)],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    return executeWithHandling(
        () async {
          await _client.from(AppConstants.tableTasks).delete().eq('id', taskId);
        },
        context: 'SupabaseTaskRepository.deleteTask',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableDelete,
              target: AppConstants.tableTasks,
              filters: [OfflineFilter(column: 'id', value: taskId)],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> updateSchedule(
    String taskId,
    String? recurrenceType, {
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
  }) async {
    return executeWithHandling(
        () async {
          final now = DateTime.now().toIso8601String();
          final Map<String, dynamic> updates = {
            'recurrence_type': recurrenceType,
            'recurrence_interval': recurrenceInterval ?? 1,
            'recurrence_weekdays': recurrenceWeekdays ?? [],
            'recurrence_month_days': recurrenceMonthDays ?? [],
            'updated_at': now,
          };

          // Al establecer recurrencia, reseteamos a activo y ponemos fecha de hoy
          if (recurrenceType != null) {
            updates['due_at'] = now;
            updates['status'] = TaskStatus.active.name;
            updates['completed_at'] = null;
            updates['completed_by'] = null;
            updates['last_completed_at'] = null;
            updates['last_verified_by'] = null;
            updates['objected_at'] = null;
            updates['objected_by'] = null;
          }

          await _client
              .from(AppConstants.tableTasks)
              .update(updates)
              .eq('id', taskId);
        },
        context: 'SupabaseTaskRepository.updateSchedule',
        isOnline: _isOnline,
        onOffline: () async {
          final now = DateTime.now().toIso8601String();
          final Map<String, dynamic> queuedUpdates = {
            'recurrence_type': recurrenceType,
            'recurrence_interval': recurrenceInterval ?? 1,
            'recurrence_weekdays': recurrenceWeekdays ?? [],
            'recurrence_month_days': recurrenceMonthDays ?? [],
            'updated_at': now,
          };

          if (recurrenceType != null) {
            queuedUpdates['due_at'] = now;
            queuedUpdates['status'] = TaskStatus.active.name;
            queuedUpdates['completed_at'] = null;
            queuedUpdates['completed_by'] = null;
            queuedUpdates['last_completed_at'] = null;
            queuedUpdates['last_verified_by'] = null;
            queuedUpdates['objected_at'] = null;
            queuedUpdates['objected_by'] = null;
          }

          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: AppConstants.tableTasks,
              values: queuedUpdates,
              filters: [OfflineFilter(column: 'id', value: taskId)],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> createTask({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? status,
  }) async {
    return executeWithHandling(
        () async {
          final taskId = await _rpc.createTask(
            title: title,
            description: description,
            category: category,
            difficulty: difficulty,
            xpReward: xpReward,
            coinReward: coinReward,
            assignedTo: assignedTo,
            recurrenceType: recurrenceType,
            recurrenceInterval: recurrenceInterval ?? 1,
            recurrenceWeekdays: recurrenceWeekdays ?? [],
            recurrenceMonthDays: recurrenceMonthDays ?? [],
          );

          final Map<String, dynamic> updates = {};
          if (status != null) updates['status'] = status;

          // If the RPC doesn't set created_by_id, we set it here
          final userId = await AppIdentityService.instance.refresh();
          if (userId != null) updates['created_by_id'] = userId;

          if (updates.isNotEmpty) {
            await _client
                .from(AppConstants.tableTasks)
                .update(updates)
                .eq('id', taskId);
          }
        },
        context: 'SupabaseTaskRepository.createTask',
        isOnline: _isOnline,
        onOffline: () async {
          final userId = await AppIdentityService.instance.refresh();
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.taskCreate,
              target: 'create_task',
              params: {
                'title': title,
                'description': description,
                'category': category,
                'assignedTo': assignedTo,
                'type': 'one_time',
                'difficulty': difficulty,
                'xpReward': xpReward,
                'coinReward': coinReward,
                'priority': 'medium',
                'recurrenceType': recurrenceType,
                'recurrenceInterval': recurrenceInterval ?? 1,
                'recurrenceWeekdays': recurrenceWeekdays ?? [],
                'recurrenceMonthDays': recurrenceMonthDays ?? [],
              },
              meta: {
                if (userId != null) 'created_by_id': userId,
                if (status != null) 'status': status,
              },
            ),
          );
        });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoTaskCompletion(
      String activityId) async {
    return executeWithHandling(
        () async {
          return _rpc.undoTaskCompletion(activityId: activityId);
        },
        context: 'SupabaseTaskRepository.undoTaskCompletion',
        isOnline: _isOnline,
        onOffline: () async {
          final requestId = generateOfflineRequestId();
          final currentUserId =
              await AppIdentityService.instance.refresh() ?? '';
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.rpc,
              target: 'undo_task_completion',
              params: {
                'p_activity_id': activityId,
                'p_user_id': currentUserId,
              },
              meta: {'queued': true},
            ),
          );
          return {
            'success': true,
            'queued': true,
            'message': 'Queued while offline',
            'request_id': requestId,
          };
        });
  }

  @override
  Future<Either<Failure, void>> editTask(
      String taskId, Map<String, dynamic> updates) async {
    return executeWithHandling(
        () async {
          updates['updated_at'] = DateTime.now().toIso8601String();
          await _client
              .from(AppConstants.tableTasks)
              .update(updates)
              .eq('id', taskId);
        },
        context: 'SupabaseTaskRepository.editTask',
        isOnline: _isOnline,
        onOffline: () async {
          final queuedUpdates = Map<String, dynamic>.from(updates)
            ..['updated_at'] = DateTime.now().toIso8601String();
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: AppConstants.tableTasks,
              values: queuedUpdates,
              filters: [OfflineFilter(column: 'id', value: taskId)],
            ),
          );
        });
  }
}
