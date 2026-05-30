import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/performance_monitor.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_task_repository.dart';
import '../../domain/models/task_model.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/utils/task_completion_utils.dart';
import 'family_member_dashboard_provider.dart';
import 'pending_approvals_provider.dart';

part 'task_provider.g.dart';

class TaskRealtimeNotice {
  final TaskModel task;
  final PostgresChangeEvent eventType;
  final int nonce;

  const TaskRealtimeNotice({
    required this.task,
    required this.eventType,
    required this.nonce,
  });
}

final taskRealtimeNoticeProvider = StateProvider<TaskRealtimeNotice?>(
  (ref) => null,
);

// ── Use Case Providers ────────────────────────────────────────────────────────

@riverpod
GetTasksUseCase getTasksUseCase(Ref ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
}

@riverpod
CompleteTaskUseCase completeTaskUseCase(Ref ref) {
  return CompleteTaskUseCase(ref.watch(taskRepositoryProvider));
}

@riverpod
CreateTaskUseCase createTaskUseCase(Ref ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
}

// ── UI State Providers ────────────────────────────────────────────────────────

@riverpod
class TaskCategoryFilter extends _$TaskCategoryFilter {
  @override
  Set<String> build() => {};

  void toggle(String category) {
    final next = Set<String>.from(state);
    if (next.contains(category)) {
      next.remove(category);
    } else {
      next.add(category);
    }
    state = next;
  }

  void clear() => state = {};
}

@riverpod
class TaskSearchQuery extends _$TaskSearchQuery {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

@riverpod
class TaskViewMode extends _$TaskViewMode {
  @override
  bool build() => false;
  void setList() => state = false;
  void setCalendar() => state = true;
  void toggle() => state = !state;
}

// ── Main Tasks Notifier ───────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class Tasks extends _$Tasks {
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  static const int _pageSize = 50;
  RealtimeChannel? _channel;
  String? _channelHouseholdId;
  Timer? _realtimeRefreshDebounce;
  final Set<String> _completingTaskIds = <String>{};

  @override
  Future<List<TaskModel>> build() async {
    return _loadTasks();
  }

  Future<List<TaskModel>> _loadTasks() async {
    _hasMore = true;
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    await _setupRealtime(householdId);

    final useCase = ref.watch(getTasksUseCaseProvider);
    final result = await PerformanceMonitor.measureFuture(
      'provider.tasks.initial_page',
      () => useCase(householdId, limit: _pageSize, offset: 0),
      context: {'householdId': householdId, 'limit': _pageSize},
      warnAfterMs: 900,
    );
    return result.fold(
      (failure) => throw failure,
      (tasks) {
        if (tasks.length < _pageSize) {
          _hasMore = false;
        }
        return tasks;
      },
    );
  }

  Future<void> _setupRealtime(String householdId) async {
    if (_channel != null && _channelHouseholdId == householdId) {
      return;
    }

    _channel?.unsubscribe();
    _realtimeRefreshDebounce?.cancel();
    final client = ref.read(supabaseClientProvider);
    await client.realtime.setAuth(null);
    _channelHouseholdId = householdId;

    _channel = client
        .channel('tasks_realtime_$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableTasks,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (payload) {
            log.i(
              'Realtime task change detected: ${payload.eventType.name}',
            );
            _applyRealtimeTaskPayload(payload);
            _invalidateRealtimeTaskDependents();
            _scheduleRealtimeRefresh();
          },
        )
        .subscribe((status, error) {
      if (error != null) {
        log.w(
          'Tasks realtime subscription error status=$status household=$householdId',
          error: error,
        );
      } else {
        log.i('Tasks realtime subscription status=$status');
      }
    });

    ref.onDispose(() {
      _realtimeRefreshDebounce?.cancel();
      _channel?.unsubscribe();
      _channelHouseholdId = null;
    });
  }

  void _scheduleRealtimeRefresh() {
    _realtimeRefreshDebounce?.cancel();
    _realtimeRefreshDebounce = Timer(const Duration(milliseconds: 260), () {
      if (ref.mounted) {
        silentRefresh();
      }
    });
  }

  void _invalidateRealtimeTaskDependents() {
    if (!ref.mounted) return;
    // NOTE: do NOT invalidate recentActivityRemoteProvider/recentActivityProvider
    // here. The activity feed is its own realtime stream (watchRecentActivity)
    // that already listens to the `tasks` and `household_activities` tables, so
    // it refreshes itself on a completion. Invalidating it from this task
    // realtime callback tore down and recreated that stream, firing a SECOND
    // redundant recent_activity query ~1s after the optimistic update — the
    // visible "double refresh" of the household movements cards.
    ref.invalidate(pendingTaskApprovalsProvider);
    ref.invalidate(familyMemberDashboardProvider);
  }

  void _applyRealtimeTaskPayload(PostgresChangePayload payload) {
    final currentTasks = state.value;
    if (currentTasks == null) return;

    final record = payload.eventType == PostgresChangeEvent.delete
        ? payload.oldRecord
        : payload.newRecord;
    final taskId = record['id']?.toString();
    if (taskId == null || taskId.isEmpty) return;

    if (payload.eventType == PostgresChangeEvent.delete) {
      state = AsyncValue.data(
        currentTasks.where((task) => task.id != taskId).toList(),
      );
      return;
    }

    try {
      final incomingTask = TaskModel.fromMap(record);
      final existingIndex = currentTasks.indexWhere(
        (task) => task.id == incomingTask.id,
      );
      final nextTasks = [...currentTasks];
      if (existingIndex >= 0) {
        nextTasks[existingIndex] = incomingTask;
      } else {
        nextTasks.insert(0, incomingTask);
      }
      nextTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = AsyncValue.data(nextTasks);
      _publishRealtimeNoticeIfRelevant(incomingTask, payload.eventType);
    } catch (error, stackTrace) {
      log.w(
        'Failed to apply realtime task payload locally',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _publishRealtimeNoticeIfRelevant(
    TaskModel task,
    PostgresChangeEvent eventType,
  ) {
    if (eventType == PostgresChangeEvent.delete) return;
    if (!task.isActive || task.isPendingApproval) return;
    if (!task.isScheduledForToday) return;
    if (isTaskCompletedOnLocalDate(task, DateTime.now())) return;

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;
    if (task.createdById == currentUserId) return;
    if (!_isTaskRelevantForCurrentViewer(task, currentUserId)) return;

    ref.read(taskRealtimeNoticeProvider.notifier).state = TaskRealtimeNotice(
      task: task,
      eventType: eventType,
      nonce: DateTime.now().microsecondsSinceEpoch,
    );
  }

  bool _isTaskRelevantForCurrentViewer(TaskModel task, String currentUserId) {
    final caps = ref.read(householdCapabilitiesProvider);
    final members = ref.read(householdMembersProvider).value ?? const [];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;

    final isFamilyMode = caps.type == HouseholdType.family;
    final isFamilyChild = isFamilyMode && (currentMember?.isChild ?? false);
    final shouldFilterByAssignment = isFamilyMode ? isFamilyChild : true;

    return !shouldFilterByAssignment ||
        task.assignedTo == null ||
        task.assignedTo == currentUserId;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<TaskModel>>();
    state = await AsyncValue.guard(_loadTasks);
  }

  Future<void> silentRefresh() async {
    if (!ref.mounted) return;
    final nextState = await AsyncValue.guard(_loadTasks);
    if (!ref.mounted) return;
    state = nextState;
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    final currentTasks = state.value ?? [];
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    final useCase = ref.read(getTasksUseCaseProvider);
    try {
      final result = await useCase(
        householdId,
        limit: _pageSize,
        offset: currentTasks.length,
      );

      result.fold(
        (failure) => log.w('Error loading more tasks: ${failure.message}'),
        (nextTasks) {
          if (nextTasks.isEmpty || nextTasks.length < _pageSize) {
            _hasMore = false;
          }
          state = AsyncValue.data([...currentTasks, ...nextTasks]);
        },
      );
    } catch (e, stack) {
      log.w('Error loading more tasks: $e', error: e, stackTrace: stack);
    }
  }

  Future<TaskCompletionResult?> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    if (!_completingTaskIds.add(task.id)) return null;

    final currentUserId = ref.read(currentUserIdProvider);
    final performers =
        userIds ?? (currentUserId != null ? [currentUserId] : null);
    final primaryUserId = performers?.first ?? currentUserId;
    final effectiveCompletedAt = completedAt ?? DateTime.now();

    final oldState = state.value;
    _logTaskCompletionTrace(
      'before_complete',
      task.copyWith(
        completedAt: effectiveCompletedAt,
        completedBy: primaryUserId,
      ),
    );

    // Optimistic update
    if (oldState != null) {
      final optimisticTasks = oldState
          .map(
            (t) => t.id == task.id
                ? t.copyWith(
                    status: TaskStatus.active,
                    completedBy: primaryUserId,
                    completedAt: effectiveCompletedAt,
                  )
                : t,
          )
          .toList();
      state = AsyncValue.data(optimisticTasks);
      _logTaskVisibilitySnapshot(
        'after_optimistic_complete',
        optimisticTasks,
        focusTaskId: task.id,
      );
    }

    try {
      final useCase = ref.read(completeTaskUseCaseProvider);
      final result = await useCase(
        task,
        userIds: performers,
        completedAt: effectiveCompletedAt,
      );

      if (result.isRight()) {
        if (!ref.mounted) {
          return result.fold((_) => null, (data) => data);
        }
        final isOnline = ref.read(isOnlineProvider);
        final queued = result.fold(
          (_) => false,
          (data) => data.queued,
        );
        if (isOnline && !queued) {
          final completion = result.fold((_) => null, (data) => data);
          final activityId = completion?.rawData['activity_id']?.toString();
          ref.read(optimisticRecentActivityProvider.notifier).addTaskCompleted(
                task,
                activityId: activityId,
                completedAt: effectiveCompletedAt,
              );
          _applyRewardBalanceOverride(
            xpReward: task.xpReward,
            coinReward: task.coinReward,
            performers: performers,
          );
          final completedTask = task.copyWith(
            completedAt: effectiveCompletedAt,
            completedBy: primaryUserId,
          );
          log.i(
            '[task-complete] success id=${task.id} queued=$queued '
            'effectiveCompletedAt=${effectiveCompletedAt.toIso8601String()} '
            'isDueToday=${completedTask.isDueToday} '
            'isOverdue=${completedTask.isOverdue}',
          );
          silentRefresh();
          ref.invalidate(userBalanceProvider);
        } else if (queued) {
          // Offline: the task is queued, not yet persisted, so there is no
          // server activity_id. Still surface an optimistic feed entry — this
          // used to be done by each home view, which caused a DOUBLE entry
          // online (view added one without activity_id while this notifier
          // added one with it). The optimistic feed is now owned solely here.
          ref.read(optimisticRecentActivityProvider.notifier).addTaskCompleted(
                task,
                completedAt: effectiveCompletedAt,
              );
          _applyRewardBalanceOverride(
            xpReward: task.xpReward,
            coinReward: task.coinReward,
            performers: performers,
          );
        }
      }

      return result.fold(
        (failure) {
          state = AsyncValue.data(oldState!);
          return null;
        },
        (data) => data,
      );
    } catch (e, stack) {
      log.w('Complete task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
      return null;
    } finally {
      _completingTaskIds.remove(task.id);
    }
  }

  void _logTaskCompletionTrace(String stage, TaskModel task) {
    log.i(
      '[task-complete][$stage] id=${task.id} title="${task.title}" '
      'status=${task.status.dbValue} recurrence=${task.recurrenceType} '
      'dueAt=${task.dueAt?.toIso8601String()} '
      'completedAt=${task.completedAt?.toIso8601String()} '
      'lastCompletedAt=${task.lastCompletedAt} '
      'allowMultipleDaily=${task.allowMultipleDailyCompletions} '
      'isDueToday=${task.isDueToday} isOverdue=${task.isOverdue}',
    );
  }

  void _logTaskVisibilitySnapshot(
    String stage,
    List<TaskModel> tasks, {
    required String? focusTaskId,
  }) {
    final interesting = tasks
        .where(
          (task) =>
              task.id == focusTaskId ||
              task.isDueToday ||
              task.isOverdue ||
              task.completedAt != null ||
              task.lastCompletedAt != null,
        )
        .take(12)
        .map(
          (task) => '{id=${task.id}, title="${task.title}", '
              'status=${task.status.dbValue}, recurrence=${task.recurrenceType}, '
              'dueAt=${task.dueAt?.toIso8601String()}, '
              'completedAt=${task.completedAt?.toIso8601String()}, '
              'lastCompletedAt=${task.lastCompletedAt}, '
              'allowMultipleDaily=${task.allowMultipleDailyCompletions}, '
              'isDueToday=${task.isDueToday}, isOverdue=${task.isOverdue}}',
        )
        .join(' | ');

    log.i(
      '[tasks-visibility][$stage] count=${tasks.length} '
      'focus=$focusTaskId interesting=[$interesting]',
    );
  }

  Future<Map<String, dynamic>?> completeTasksBatch(
    List<TaskModel> tasks, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final performers =
        userIds ?? (currentUserId != null ? [currentUserId] : null);
    final primaryUserId = performers?.first ?? currentUserId;
    final effectiveCompletedAt = completedAt ?? DateTime.now();
    final taskIds = tasks.map((t) => t.id).toSet();

    final oldState = state.value;

    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map(
              (t) => taskIds.contains(t.id)
                  ? t.copyWith(
                      status: TaskStatus.active,
                      completedBy: primaryUserId,
                      completedAt: effectiveCompletedAt,
                    )
                  : t,
            )
            .toList(),
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      final result = await repo.completeTasksBatch(
        tasks,
        userIds: performers,
        completedAt: effectiveCompletedAt,
      );
      if (!ref.mounted) {
        return result.fold((_) => null, (data) => data);
      }

      if (result.isRight()) {
        final isOnline = ref.read(isOnlineProvider);
        if (isOnline) {
          _applyRewardBalanceOverride(
            xpReward: tasks.fold(0, (sum, task) => sum + task.xpReward),
            coinReward: tasks.fold(0, (sum, task) => sum + task.coinReward),
            performers: performers,
          );
          silentRefresh();
          ref.invalidate(userBalanceProvider);
          // The activity feed (recentActivityRemoteProvider) is a realtime
          // stream that already reacts to the `tasks` table change, and the
          // optimistic entry covers the instant update. Invalidating it here
          // tore down the stream and caused a redundant double refetch.
        }
      }

      return result.fold(
        (failure) {
          if (oldState != null) state = AsyncValue.data(oldState);
          return null;
        },
        (data) => data,
      );
    } catch (e, stack) {
      log.w('Complete tasks batch failure: $e', error: e, stackTrace: stack);
      if (ref.mounted && oldState != null) state = AsyncValue.data(oldState);
      return null;
    }
  }

  void _applyRewardBalanceOverride({
    required int xpReward,
    required int coinReward,
    required List<String>? performers,
  }) {
    final currentUserId = ref.read(currentUserIdProvider);
    final householdId = ref.read(householdIdProvider).value;
    if (currentUserId == null ||
        householdId == null ||
        performers == null ||
        !performers.contains(currentUserId)) {
      return;
    }

    final currentBalance = ref.read(userBalanceProvider).value;
    if (currentBalance == null) return;

    final currentXp = (currentBalance['xp'] as num?)?.toInt() ?? 0;
    final currentCoins = (currentBalance['coins'] as num?)?.toInt() ?? 0;
    ref.read(userBalanceOverrideProvider.notifier).state = {
      ...currentBalance,
      '_household_id': householdId,
      'xp': currentXp + xpReward,
      'coins': currentCoins + coinReward,
    };
  }

  Future<void> verifyTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map(
              (t) => t.id == task.id
                  ? t.copyWith(
                      status: TaskStatus.verified,
                      verifiedBy: userId,
                      verifiedAt: DateTime.now(),
                    )
                  : t,
            )
            .toList(),
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.verifyTask(task.id, userId);
    } catch (e, stack) {
      log.w('Verify task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> objectTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map(
              (t) => t.id == task.id
                  ? t.copyWith(
                      status: TaskStatus.active,
                      completedBy: null,
                      completedAt: null,
                    )
                  : t,
            )
            .toList(),
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.objectTask(task.id, userId);
    } catch (e, stack) {
      log.w('Object task failure: $e', error: e, stackTrace: stack);
      if (oldState != null) state = AsyncValue.data(oldState); // Rollback
    }
  }

  Future<void> approveTask(TaskModel task) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map(
              (t) =>
                  t.id == task.id ? t.copyWith(status: TaskStatus.active) : t,
            )
            .toList(),
      );
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      // We use editTask to change status to active
      await repo.editTask(task.id, {'status': 'active'});
      if (!ref.mounted) return;
      silentRefresh();
    } catch (e, stack) {
      log.w('Approve task failure: $e', error: e, stackTrace: stack);
      if (ref.mounted && oldState != null) {
        state = AsyncValue.data(oldState); // Rollback
      }
    }
  }

  Future<void> rejectTask(TaskModel task) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(task.id);
      if (!ref.mounted) return;
      silentRefresh();
    } catch (e, stack) {
      log.w('Reject task failure: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> submitTaskForApproval(TaskModel task) async {
    if (!ref.read(taskApprovalEnabledProvider)) {
      await completeTask(task);
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final submittedAt = DateTime.now();
    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map(
              (t) => t.id == task.id
                  ? t.copyWith(
                      status: TaskStatus.pendingApproval,
                      completedBy: userId,
                      completedAt: submittedAt,
                    )
                  : t,
            )
            .toList(),
      );
    }

    try {
      final useCase = ref.read(completeTaskUseCaseProvider);
      final result = await useCase(
        task,
        userIds: [userId],
        completedAt: submittedAt,
      );
      if (!ref.mounted) return;
      result.fold(
        (failure) {
          if (oldState != null) state = AsyncValue.data(oldState);
          throw failure;
        },
        (_) {},
      );
      if (result.isRight() && ref.read(isOnlineProvider)) {
        silentRefresh();
        ref.invalidate(recentActivityProvider);
        ref.invalidate(pendingTaskApprovalsProvider);
      }
    } catch (e, stack) {
      log.w(
        'Submit task for approval failure: $e',
        error: e,
        stackTrace: stack,
      );
      if (ref.mounted && oldState != null) state = AsyncValue.data(oldState);
      rethrow;
    }
  }

  /// Sprint 1 Modo Padres: aprueba la submision pendiente via
  /// `verify_task_transaction`. La RPC valida que el verificador sea
  /// owner/admin, recupera el snapshot y recien ahi acredita XP/coins y
  /// reprograma la recurrencia. Devuelve un TaskCompletionResult sintetico
  /// (success/false) para mantener la firma usada por la UI.
  Future<TaskCompletionResult?> approvePendingTask(TaskModel task) async {
    try {
      final ok = await ref.read(taskApprovalActionsProvider).approve(task.id);
      if (ok) {
        if (!ref.mounted) return null;
        silentRefresh();
        ref.invalidate(userBalanceProvider);
        ref.invalidate(recentActivityProvider);
        ref.invalidate(pendingTaskApprovalsProvider);
        return const TaskCompletionResult(
          success: true,
          message: 'Tarea aprobada',
          queued: false,
          status: 'approved',
        );
      }
      return null;
    } catch (e, stack) {
      log.w('approvePendingTask failure: $e', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Sprint 1 Modo Padres: rechaza con motivo. La RPC vuelve la tarea a
  /// `assigned`, persiste el motivo, notifica al hijo y deja registro en
  /// `task_approvals.rejected`.
  Future<void> rejectPendingTask(TaskModel task, {String? reason}) async {
    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(
        oldState
            .map(
              (t) => t.id == task.id
                  ? t.copyWith(
                      status: TaskStatus.assigned,
                      completedBy: null,
                      completedAt: null,
                    )
                  : t,
            )
            .toList(),
      );
    }

    try {
      final ok = await ref
          .read(taskApprovalActionsProvider)
          .reject(task.id, reason: reason);
      if (!ref.mounted) return;
      if (!ok) {
        if (oldState != null) state = AsyncValue.data(oldState);
        return;
      }
      if (ref.read(isOnlineProvider)) {
        silentRefresh();
        ref.invalidate(recentActivityProvider);
        ref.invalidate(pendingTaskApprovalsProvider);
      }
    } catch (e, stack) {
      log.w('Reject pending task failure: $e', error: e, stackTrace: stack);
      if (ref.mounted && oldState != null) state = AsyncValue.data(oldState);
      rethrow;
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final oldState = state.value;
    if (oldState != null) {
      state = AsyncValue.data(oldState.where((t) => t.id != task.id).toList());
    }

    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.deleteTask(task.id);
      if (!ref.mounted) return;
      if (ref.read(isOnlineProvider)) {
        ref.invalidate(recentActivityProvider);
        ref.invalidate(pendingTaskApprovalsProvider);
        ref.invalidate(familyMemberDashboardProvider);
        silentRefresh();
      }
    } catch (e, stack) {
      log.w('Delete task failure: $e', error: e, stackTrace: stack);
      if (ref.mounted && oldState != null) {
        state = AsyncValue.data(oldState); // Rollback
      }
      rethrow;
    }
  }

  Future<void> updateSchedule(
    TaskModel task,
    String? recurrenceType, {
    int recurrenceInterval = 1,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? assignedTo,
  }) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.updateSchedule(
        task.id,
        recurrenceType,
        recurrenceInterval: recurrenceInterval,
        recurrenceWeekdays: recurrenceWeekdays,
        recurrenceMonthDays: recurrenceMonthDays,
        assignedTo: assignedTo,
      );
      if (!ref.mounted) return;
      if (ref.read(isOnlineProvider)) {
        refresh();
      }
    } catch (e, stack) {
      log.w('Update schedule failure: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    try {
      final xp = taskData['xpReward'] as int;
      final coins = taskData['coinReward'] as int;

      final useCase = ref.read(createTaskUseCaseProvider);
      final result = await useCase(
        title: taskData['title'] as String,
        description: taskData['description'] as String?,
        category: taskData['category'] as String,
        difficulty: taskData['difficulty'] as String,
        xpReward: xp,
        coinReward: coins,
        assignedTo: taskData['assignedTo'] as String?,
        recurrenceType: taskData['recurrenceType'] as String?,
        recurrenceInterval: taskData['recurrenceInterval'] as int?,
        recurrenceWeekdays: taskData['recurrenceWeekdays'] as List<int>?,
        recurrenceMonthDays: taskData['recurrenceMonthDays'] as List<int>?,
        status: null,
        rotationPool: (taskData['rotationPool'] as List?)?.cast<String>(),
        sourceTemplateId: taskData['sourceTemplateId'] as String?,
        titleKey: taskData['titleKey'] as String?,
      );

      result.fold(
        (failure) => throw failure,
        (_) {
          if (!ref.mounted) return;
          final isOnline = ref.read(isOnlineProvider);
          if (isOnline) {
            silentRefresh();
            ref.invalidate(recentActivityProvider);
          }
        },
      );
    } catch (e, stack) {
      log.w('Create task failure: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> editTask(String taskId, Map<String, dynamic> updates) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      await repo.editTask(taskId, updates);
      if (!ref.mounted) return;
      if (ref.read(isOnlineProvider)) {
        refresh();
      }
    } catch (e, stack) {
      log.w('Edit task failure: $e', error: e, stackTrace: stack);
    }
  }
}

// ── Derived / Filtered Providers ──────────────────────────────────────────────

@riverpod
AsyncValue<List<TaskModel>> filteredTasks(Ref ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final selectedCategories = ref.watch(taskCategoryFilterProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider);

  return tasksAsync.whenData((tasks) {
    var result = tasks;
    if (selectedCategories.isNotEmpty) {
      result = result
          .where(
            (t) => selectedCategories
                .contains(CategoryMapping.normaliseCategory(t.category)),
          )
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    return result;
  });
}

@riverpod
AsyncValue<List<String>> activeCategories(Ref ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.whenData((tasks) {
    final activeSet = <String>{};
    for (var t in tasks) {
      if (t.isActive) {
        activeSet.add(CategoryMapping.normaliseCategory(t.category));
      }
    }
    return activeSet.toList();
  });
}

@riverpod
AsyncValue<List<TaskModel>> todayTasks(Ref ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  final caps = ref.watch(householdCapabilitiesProvider);
  final members = ref.watch(householdMembersProvider).value ?? const [];
  final currentMember =
      members.where((member) => member.userId == currentUserId).firstOrNull;
  final isFamilyMode = caps.type == HouseholdType.family;
  final isFamilyChild = isFamilyMode && (currentMember?.isChild ?? false);
  final shouldUseFamilyHouseholdScope = isFamilyMode && !isFamilyChild;
  final now = DateTime.now();
  final recentActivityAsync = ref.watch(recentActivityProvider);
  // During startup the merged recentActivityProvider serves an incomplete
  // bootstrap snapshot for up to a few seconds before handing off to realtime.
  // Union the raw realtime feed (resolves in ~250ms) so today's completions
  // hide as soon as it lands instead of at the 4s handoff — this is what
  // removes the "task flashes then disappears" flicker. Union only ever adds
  // hides, so it is safe even if one source is still empty.
  final remoteActivityAsync = ref.watch(recentActivityRemoteProvider);
  final completedActivityTaskIds = <String>{
    ..._completedActivityTaskIdsForLocalDate(
      recentActivityAsync.value ?? const <Map<String, dynamic>>[],
      now,
    ),
    ..._completedActivityTaskIdsForLocalDate(
      remoteActivityAsync.value ?? const <Map<String, dynamic>>[],
      now,
    ),
  };

  // A task assigned to someone else is not "mine". Only filtered when the
  // viewer is an individual (couple/solo/friends) or a family child; family
  // adults keep the household-wide coordination view.
  bool isAssignedToSomeoneElse(TaskModel task) {
    final shouldFilterByAssignment = isFamilyMode ? isFamilyChild : true;
    return shouldFilterByAssignment &&
        task.assignedTo != null &&
        task.assignedTo != currentUserId;
  }

  // Once completed for the day a task leaves the home "today" section and lives
  // only in the activity feed — even repeatable ones (allowMultipleDaily); it
  // can still be completed again from the full task list. Completion is read
  // from the task fields OR today's activity feed, which is authoritative right
  // after an optimistic completion (before the silent refresh lands).
  bool isClosedForToday(TaskModel task) {
    return isTaskCompletedOnLocalDate(task, now) ||
        completedActivityTaskIds.contains(task.id);
  }

  return tasksAsync.whenData((tasks) {
    final visibleTasks = tasks.where((task) {
      if (isAssignedToSomeoneElse(task)) return false;
      // Only actionable tasks belong here. Pending-approval tasks are surfaced
      // separately for adult review via pendingTaskApprovalsProvider.
      if (!task.isActive || task.isPendingApproval) return false;
      if (isClosedForToday(task)) return false;
      return task.isScheduledForToday;
    }).toList();

    final result = (visibleTasks.isNotEmpty || !shouldUseFamilyHouseholdScope)
        ? visibleTasks
        : (tasks.where((task) {
            // Family QA and new households can have active tasks without a due
            // date or explicit "today" schedule yet. In that case, show the
            // next active tasks instead of leaving the home empty.
            if (!task.isActive || task.isPendingApproval) return false;
            if (task.completedAt != null && task.recurrenceType == null) {
              return false;
            }
            if (isClosedForToday(task)) return false;
            return true;
          }).toList()
              ..sort((a, b) {
                final aDue = a.dueAt;
                final bDue = b.dueAt;
                if (aDue == null && bDue == null) {
                  return a.createdAt.compareTo(b.createdAt);
                }
                if (aDue == null) return 1;
                if (bDue == null) return -1;
                return aDue.compareTo(bDue);
              }))
            .take(3)
            .toList();

    return result;
  });
}

Set<String> _completedActivityTaskIdsForLocalDate(
  List<Map<String, dynamic>> activities,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  return activities
      .where((activity) {
        if (activity['type'] != 'task') return false;
        final createdAt = DateTime.tryParse(
          activity['created_at']?.toString() ?? '',
        )?.toLocal();
        if (createdAt == null) return false;
        final createdDate = DateTime(
          createdAt.year,
          createdAt.month,
          createdAt.day,
        );
        return createdDate == today;
      })
      .map((activity) {
        final data = activity['data'] as Map<String, dynamic>? ?? {};
        return data['task_id']?.toString();
      })
      .whereType<String>()
      .toSet();
}

@riverpod
Map<String, int> taskStatusCount(Ref ref) {
  final tasksAsync = ref.watch(tasksProvider);
  return tasksAsync.maybeWhen(
    data: (tasks) {
      final counts = <String, int>{};
      for (final task in tasks) {
        final statusKey = task.status.dbValue;
        counts[statusKey] = (counts[statusKey] ?? 0) + 1;
      }
      return counts;
    },
    orElse: () => {},
  );
}
