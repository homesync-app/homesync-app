import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/offline/offline_action.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/core/offline/offline_storage_service.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/repository_error_handler.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_task_repository.g.dart';

@riverpod
TaskRepository taskRepository(Ref ref) {
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
  bool get _isAdminTestingActive {
    final admin = _ref.read(adminProvider);
    return AppEnvironment.enableAdminTesting &&
        admin.isAdminUser &&
        !admin.useRealQaSession &&
        admin.selectedHouseholdId != null;
  }

  String? get _selectedAdminHouseholdId {
    final admin = _ref.read(adminProvider);
    if (_isAdminTestingActive) {
      return admin.selectedHouseholdId;
    }
    return null;
  }

  Future<void> _queueAction(OfflineAction action) async {
    await _offlineQueue.enqueueAction(
      actionType: action.type,
      payload: action.toMap(),
    );
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(
    String householdId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final isAdminTestingActive = _isAdminTestingActive;
    final selectedAdminHouseholdId = _selectedAdminHouseholdId;
    final effectiveHouseholdId = selectedAdminHouseholdId ?? householdId;
    return executeWithHandling(
      () async {
        final raw = isAdminTestingActive
            ? await _client.rpc(
                'qa_admin_get_tasks',
                params: {'p_household_id': selectedAdminHouseholdId},
              )
            : await _rpc.getTasks(limit: limit, offset: offset);
        final tasks = (raw as List)
            .map((t) => TaskModel.fromMap(t as Map<String, dynamic>))
            .toList();
        log.i(
          'TaskRepository.getTasks household=$effectiveHouseholdId count=${tasks.length} adminQa=$isAdminTestingActive',
        );
        try {
          await OfflineStorageService().set(
            'tasks_cache_$effectiveHouseholdId',
            {'tasks': raw},
          );
        } catch (error, stackTrace) {
          log.w(
            'TaskRepository.getTasks: cache persistence skipped: $error',
            error: error,
            stackTrace: stackTrace,
          );
        }
        return tasks;
      },
      context: 'SupabaseTaskRepository.getTasks',
      isOnline: _isOnline,
      onOffline: () async {
        final cached = await OfflineStorageService()
            .get('tasks_cache_$effectiveHouseholdId');
        if (cached != null && cached['tasks'] != null) {
          log.i(
            'TaskRepository.getTasks: Recovered from persistent offline cache',
          );
          return (cached['tasks'] as List)
              .map((t) => TaskModel.fromMap(t as Map<String, dynamic>))
              .toList();
        }
        throw const NetworkFailure(
          'No hay conexión y no existen datos locales en caché',
        );
      },
    );
  }

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return executeWithHandling(
      () async {
        final householdId =
            _selectedAdminHouseholdId ?? await _rpc.requireHouseholdId();
        final performers = userIds ??
            [
              _isAdminTestingActive
                  ? (_ref.read(currentUserIdProvider) ??
                      await _rpc.requireCurrentUserId())
                  : await _rpc.requireCurrentUserId(),
            ];
        final result = _isAdminTestingActive
            ? TaskCompletionResult.fromRpcResponse(
                await _client.rpc(
                  'qa_admin_complete_task',
                  params: {
                    'p_household_id': householdId,
                    'p_user_ids': performers,
                    'p_task_id': task.id,
                    'p_xp_reward': task.xpReward,
                    'p_coin_reward': task.coinReward,
                    'p_task_title': task.title,
                    if (completedAt != null)
                      'p_completed_at': completedAt.toIso8601String(),
                  },
                ),
              )
            : await _rpc.completeTaskTransaction(
                taskId: task.id,
                taskTitle: task.title,
                xpReward: task.xpReward,
                coinReward: task.coinReward,
                householdId: householdId,
                userIds: performers,
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
            target: 'complete_task_v1',
            params: {
              'p_request_id':
                  'offline_${DateTime.now().millisecondsSinceEpoch}',
              'p_user_ids': userIds ?? [userId],
              'p_task_id': task.id,
              'p_household_id':
                  _selectedAdminHouseholdId ?? await _rpc.requireHouseholdId(),
              'p_xp_reward': task.xpReward,
              'p_coin_reward': task.coinReward,
              'p_task_title': task.title,
              if (completedAt != null)
                'p_completed_at': completedAt.toIso8601String(),
            },
          ),
        );
        return const TaskCompletionResult(
          success: true,
          message: 'Encolado offline',
          queued: true,
        );
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeTasksBatch(
    List<TaskModel> tasks, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return executeWithHandling(
      () async {
        final householdId =
            _selectedAdminHouseholdId ?? await _rpc.requireHouseholdId();
        final performers = userIds ??
            [
              _isAdminTestingActive
                  ? (_ref.read(currentUserIdProvider) ??
                      await _rpc.requireCurrentUserId())
                  : await _rpc.requireCurrentUserId(),
            ];
        if (_isAdminTestingActive) {
          final raw = await _client.rpc(
            'qa_admin_complete_tasks_batch',
            params: {
              'p_household_id': householdId,
              'p_user_ids': performers,
              'p_tasks': tasks
                  .map(
                    (task) => {
                      'task_id': task.id,
                      'xp_reward': task.xpReward,
                      'coin_reward': task.coinReward,
                      'task_title': task.title,
                    },
                  )
                  .toList(),
              if (completedAt != null)
                'p_completed_at': completedAt.toIso8601String(),
            },
          );
          return Map<String, dynamic>.from(raw as Map);
        }

        final taskIds = tasks.map((t) => t.id).toList();
        final result = await _rpc.completeTasksBatch(
          taskIds: taskIds,
          householdId: householdId,
          userIds: performers,
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
              'p_request_id':
                  'offline_${DateTime.now().millisecondsSinceEpoch}',
              'p_user_ids': userIds ?? [userId],
              'p_task_ids': taskIds,
              'p_household_id':
                  _selectedAdminHouseholdId ?? await _rpc.requireHouseholdId(),
              if (completedAt != null)
                'p_completed_at': completedAt.toIso8601String(),
            },
          ),
        );
        return const {
          'success': true,
          'message': 'Lote encolado offline',
          'queued': true,
        };
      },
    );
  }

  @override
  Future<Either<Failure, void>> verifyTask(
    String taskId,
    String verifiedByUserId,
  ) async {
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
      },
    );
  }

  @override
  Future<Either<Failure, void>> objectTask(
    String taskId,
    String objectedByUserId,
  ) async {
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
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    return executeWithHandling(
      () async {
        if (_isAdminTestingActive) {
          await _client.from(AppConstants.tableTasks).delete().eq('id', taskId);
          return;
        }
        await _rpc.deleteTask(taskId: taskId);
      },
      context: 'SupabaseTaskRepository.deleteTask',
      isOnline: _isOnline,
      onOffline: () async {
        await _queueAction(
          OfflineAction(
            type: OfflineActionType.rpc,
            target: 'delete_task_v1',
            params: {'p_task_id': taskId},
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, void>> updateSchedule(
    String taskId,
    String? recurrenceType, {
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? assignedTo,
  }) async {
    return executeWithHandling(
      () async {
        final now = DateTime.now().toIso8601String();
        final hasSchedulingIntent =
            recurrenceType != null || assignedTo != null;
        final Map<String, dynamic> updates = {
          'recurrence_type': recurrenceType,
          'recurrence_interval': recurrenceInterval ?? 1,
          'recurrence_weekdays': recurrenceWeekdays ?? [],
          'recurrence_month_days': recurrenceMonthDays ?? [],
          'assigned_to': assignedTo,
          'updated_at': now,
        };

        // "Programar tarea" en la UI actual no elige una fecha puntual.
        // Si la persona asigna un responsable o una recurrencia, lo
        // interpretamos como una programación para hoy.
        if (hasSchedulingIntent) {
          updates['due_at'] = now;
          updates['status'] = TaskStatus.active.name;
          updates['completed_at'] = null;
          updates['completed_by'] = null;
          updates['last_completed_at'] = null;
          updates['last_verified_by'] = null;
          updates['objected_at'] = null;
          updates['objected_by'] = null;
        } else {
          updates['due_at'] = null;
        }

        if (_isAdminTestingActive) {
          await _client.rpc(
            'qa_admin_update_task_v1',
            params: {
              'p_household_id': _selectedAdminHouseholdId,
              'p_task_id': taskId,
              'p_assigned_to': assignedTo,
              'p_due_at': updates['due_at'],
              'p_recurrence_type': recurrenceType,
              'p_recurrence_interval': recurrenceInterval ?? 1,
              'p_recurrence_weekdays': recurrenceWeekdays ?? [],
              'p_recurrence_month_days': recurrenceMonthDays ?? [],
              'p_status': updates['status'],
            },
          );
        } else {
          await _client
              .from(AppConstants.tableTasks)
              .update(updates)
              .eq('id', taskId);
        }
      },
      context: 'SupabaseTaskRepository.updateSchedule',
      isOnline: _isOnline,
      onOffline: () async {
        final now = DateTime.now().toIso8601String();
        final hasSchedulingIntent =
            recurrenceType != null || assignedTo != null;
        final Map<String, dynamic> queuedUpdates = {
          'recurrence_type': recurrenceType,
          'recurrence_interval': recurrenceInterval ?? 1,
          'recurrence_weekdays': recurrenceWeekdays ?? [],
          'recurrence_month_days': recurrenceMonthDays ?? [],
          'assigned_to': assignedTo,
          'updated_at': now,
        };

        if (hasSchedulingIntent) {
          queuedUpdates['due_at'] = now;
          queuedUpdates['status'] = TaskStatus.active.name;
          queuedUpdates['completed_at'] = null;
          queuedUpdates['completed_by'] = null;
          queuedUpdates['last_completed_at'] = null;
          queuedUpdates['last_verified_by'] = null;
          queuedUpdates['objected_at'] = null;
          queuedUpdates['objected_by'] = null;
        } else {
          queuedUpdates['due_at'] = null;
        }

        await _queueAction(
          OfflineAction(
            type: OfflineActionType.tableUpdate,
            target: AppConstants.tableTasks,
            values: queuedUpdates,
            filters: [OfflineFilter(column: 'id', value: taskId)],
          ),
        );
      },
    );
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
    List<String>? rotationPool,
    String? sourceTemplateId,
    String? titleKey,
  }) async {
    return executeWithHandling(
      () async {
        if (_isAdminTestingActive) {
          final userId = _ref.read(currentUserIdProvider) ??
              await AppIdentityService.instance.refresh();
          if (userId == null || _selectedAdminHouseholdId == null) {
            throw Exception('QA admin sin viewer u hogar seleccionado');
          }

          await _client.rpc(
            'qa_admin_create_task',
            params: {
              'p_household_id': _selectedAdminHouseholdId,
              'p_created_by': userId,
              'p_title': title,
              'p_description': description,
              'p_category': category,
              'p_assigned_to': assignedTo,
              'p_type': 'one_time',
              'p_difficulty': difficulty,
              'p_xp_reward': xpReward,
              'p_coin_reward': coinReward,
              'p_priority': 'medium',
              'p_recurrence_type': recurrenceType,
              'p_recurrence_interval': recurrenceInterval ?? 1,
              'p_recurrence_weekdays': recurrenceWeekdays ?? [],
              'p_recurrence_month_days': recurrenceMonthDays ?? [],
            },
          );
          log.i(
            'TaskRepository.createTask QA created household=$_selectedAdminHouseholdId title=$title assignedTo=$assignedTo',
          );
          await _ref.read(analyticsServiceProvider).trackTaskCreated(
                category: category,
                difficulty: difficulty,
              );
          return;
        }

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
        if (sourceTemplateId != null) {
          updates['source_template_id'] = sourceTemplateId;
        }
        if (titleKey != null) updates['title_key'] = titleKey;

        final userId = await AppIdentityService.instance.refresh();
        if (userId != null) updates['created_by_id'] = userId;

        // Sprint 3 Modo Padres: setear pool de rotacion si fue pedido.
        if (rotationPool != null && rotationPool.isNotEmpty) {
          updates['rotation_pool'] = rotationPool;
          updates['rotation_strategy'] = 'round_robin';
          updates['rotation_index'] = 0;
        }

        if (updates.isNotEmpty) {
          await _client
              .from(AppConstants.tableTasks)
              .update(updates)
              .eq('id', taskId);
        }

        await _ref.read(analyticsServiceProvider).trackTaskCreated(
              category: category,
              difficulty: difficulty,
            );
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
              if (sourceTemplateId != null)
                'source_template_id': sourceTemplateId,
              if (titleKey != null) 'title_key': titleKey,
            },
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoTaskCompletion(
    String activityId,
  ) async {
    return executeWithHandling(
      () async {
        return _rpc.undoTaskCompletion(activityId: activityId);
      },
      context: 'SupabaseTaskRepository.undoTaskCompletion',
      isOnline: _isOnline,
      onOffline: () async {
        final requestId = generateOfflineRequestId();
        final currentUserId = await AppIdentityService.instance.refresh() ?? '';
        await _queueAction(
          OfflineAction(
            type: OfflineActionType.rpc,
            target: 'undo_task_completion_v1',
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
      },
    );
  }

  @override
  Future<Either<Failure, void>> editTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    return executeWithHandling(
      () async {
        updates['updated_at'] = DateTime.now().toIso8601String();
        if (_isAdminTestingActive) {
          await _client.rpc(
            'qa_admin_update_task_v1',
            params: {
              'p_household_id': _selectedAdminHouseholdId,
              'p_task_id': taskId,
              'p_title': updates['title'],
              'p_description': updates['description'],
              'p_category': updates['category'],
              'p_assigned_to': updates['assigned_to'],
              'p_due_at': updates['due_at'],
              'p_recurrence_type': updates['recurrence_type'],
              'p_recurrence_interval': updates['recurrence_interval'],
              'p_recurrence_weekdays': updates['recurrence_weekdays'],
              'p_recurrence_month_days': updates['recurrence_month_days'],
              'p_status': updates['status'],
              if (updates.containsKey('completed_by'))
                'p_completed_by': updates['completed_by'],
              if (updates.containsKey('completed_at'))
                'p_completed_at': updates['completed_at'],
              if (updates.containsKey('last_completed_at'))
                'p_last_completed_at': updates['last_completed_at'],
              if (updates.containsKey('completed_by') ||
                  updates.containsKey('completed_at') ||
                  updates.containsKey('last_completed_at'))
                'p_touch_completion': true,
            },
          );
        } else {
          await _client
              .from(AppConstants.tableTasks)
              .update(updates)
              .eq('id', taskId);
        }
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
      },
    );
  }
}
