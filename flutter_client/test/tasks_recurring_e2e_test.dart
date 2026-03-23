import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';

class InMemoryRecurringTaskRepository implements TaskRepository {
  TaskModel? _task;
  DateTime _now;
  String? _lastActivityId;

  InMemoryRecurringTaskRepository({DateTime? initialNow})
      : _now = initialNow ?? DateTime(2026, 3, 18, 9, 0);

  DateTime get now => _now;

  void advanceDays(int days) {
    _now = _now.add(Duration(days: days));
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
    _task = TaskModel(
      id: 'task-recurring-1',
      title: title,
      description: description,
      category: category,
      difficulty: TaskDifficulty.fromString(difficulty),
      status: TaskStatus.fromString(status ?? 'active'),
      xpReward: xpReward,
      coinReward: coinReward,
      householdId: 'household-1',
      recurrenceType: recurrenceType,
      dueAt: _now,
      createdAt: _now,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(
    String householdId, {
    int limit = 100,
    int offset = 0,
  }) async {
    if (_task == null) return const Right([]);
    return Right([_task!]);
  }

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    if (_task == null) {
      return const Left(ServerFailure('Task not found'));
    }

    final sameDayAlreadyCompleted = _task!.completedAt != null &&
        _task!.completedAt!.year == _now.year &&
        _task!.completedAt!.month == _now.month &&
        _task!.completedAt!.day == _now.day;

    final canCompleteFromVerifiedRecurring = _task!.status == TaskStatus.verified &&
        _task!.recurrenceType != null &&
        (_task!.dueAt == null || !_task!.dueAt!.isAfter(_now));

    final canCompleteFromActiveState = _task!.status == TaskStatus.active ||
        _task!.status == TaskStatus.assigned ||
        _task!.status == TaskStatus.objected;

    if (sameDayAlreadyCompleted) {
      return const Left(ServerFailure('Task already completed today'));
    }

    if (!canCompleteFromActiveState && !canCompleteFromVerifiedRecurring) {
      return const Left(ServerFailure('Task not in completable state'));
    }

    _task = _task!.copyWith(
      status: TaskStatus.pendingVerification,
      completedAt: _now,
      lastCompletedAt: _now.toIso8601String(),
      completedBy: userIds?.isNotEmpty == true ? userIds!.first : 'user-1',
    );
    _lastActivityId = 'activity-${_now.millisecondsSinceEpoch}';

    return const Right(TaskCompletionResult(
      success: true,
      message: 'Task completed',
      queued: false,
      status: 'ok',
    ));
  }

  @override
  Future<Either<Failure, void>> verifyTask(
    String taskId,
    String verifiedByUserId,
  ) async {
    if (_task == null || _task!.id != taskId) {
      return const Left(ServerFailure('Task not found'));
    }
    if (_task!.status != TaskStatus.pendingVerification) {
      return const Left(ServerFailure('Task is not pending verification'));
    }

    final nextDue = _task!.recurrenceType == null ? _task!.dueAt : _now.add(const Duration(days: 1));
    _task = _task!.copyWith(
      status: TaskStatus.verified,
      lastVerifiedBy: verifiedByUserId,
      dueAt: nextDue,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoTaskCompletion(
      String activityId) async {
    if (_task == null || _lastActivityId != activityId) {
      return const Left(ServerFailure('Activity not found'));
    }
    _task = _task!.copyWith(
      status: TaskStatus.active,
      completedAt: null,
      completedBy: null,
    );
    return const Right({'success': true});
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> editTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> objectTask(
    String taskId,
    String objectedByUserId,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateSchedule(
    String taskId,
    String? recurrenceType, {
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeTasksBatch(
      List<TaskModel> tasks, {
      List<String>? userIds,
      DateTime? completedAt,
  }) async =>
      const Right({'success': true});
}

void main() {
  group('Recurring task e2e flow', () {
    test(
      'create -> complete -> verify -> fail same day -> re-complete next day',
      () async {
        final repo = InMemoryRecurringTaskRepository(
          initialNow: DateTime(2026, 3, 18, 9, 0),
        );

        await repo.createTask(
          title: 'Sacar la basura',
          category: 'cleaning',
          difficulty: 'easy',
          xpReward: 10,
          coinReward: 5,
          recurrenceType: 'daily',
        );

        final createdTasks = await repo.getTasks('household-1');
        final task = createdTasks.getOrElse((_) => []).first;
        expect(task.status, TaskStatus.active);

        final completion1 = await repo.completeTask(task, userIds: ['user-1']);
        expect(completion1.isRight(), isTrue);

        final afterComplete = (await repo.getTasks('household-1'))
            .getOrElse((_) => [])
            .first;
        expect(afterComplete.status, TaskStatus.pendingVerification);

        final verification = await repo.verifyTask(afterComplete.id, 'user-2');
        expect(verification.isRight(), isTrue);

        final afterVerify = (await repo.getTasks('household-1'))
            .getOrElse((_) => [])
            .first;
        expect(afterVerify.status, TaskStatus.verified);

        final sameDayAttempt = await repo.completeTask(afterVerify, userIds: ['user-1']);
        expect(sameDayAttempt.isLeft(), isTrue);

        repo.advanceDays(1);
        final taskNextDay = (await repo.getTasks('household-1'))
            .getOrElse((_) => [])
            .first;
        final completionNextDay = await repo.completeTask(
          taskNextDay,
          userIds: ['user-1'],
        );
        expect(completionNextDay.isRight(), isTrue);

        final afterRecomplete = (await repo.getTasks('household-1'))
            .getOrElse((_) => [])
            .first;
        expect(afterRecomplete.status, TaskStatus.pendingVerification);
      },
    );
  });
}
