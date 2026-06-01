import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/data/repositories/supabase_task_repository.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
import 'package:homesync_client/features/tasks/presentation/providers/pending_approvals_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  RealtimeChannel channel(
    String name, {
    RealtimeChannelConfig opts = const RealtimeChannelConfig(),
  }) =>
      _FakeRealtimeChannel();

  @override
  RealtimeClient get realtime => _FakeRealtimeClient();

  @override
  SupabaseQueryBuilder from(String table) => _FakeSupabaseQueryBuilder();
}

class _FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([
    String columns = '*',
  ]) =>
      _FakePostgrestFilterBuilder();
}

class _FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
    String column,
    Object value,
  ) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gte(
    String column,
    Object value,
  ) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> inFilter(
    String column,
    List values,
  ) =>
      this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(
    String column, {
    bool? ascending,
    bool? nullsFirst,
    String? referencedTable,
  }) =>
      _FakePostgrestListTransformBuilder();

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(
    int count, {
    String? referencedTable,
  }) =>
      _FakePostgrestListTransformBuilder();

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() =>
      _FakePostgrestSingleTransformBuilder();

  @override
  Future<U> then<U>(
    FutureOr<U> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) async =>
      await onValue(const []);
}

class _FakePostgrestListTransformBuilder extends Fake
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(
    int count, {
    String? referencedTable,
  }) =>
      this;

  @override
  Future<U> then<U>(
    FutureOr<U> Function(List<Map<String, dynamic>> value) onValue, {
    Function? onError,
  }) async =>
      await onValue(const []);
}

class _FakePostgrestSingleTransformBuilder extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic>? value) onValue, {
    Function? onError,
  }) async =>
      await onValue(null);
}

class _FakeRealtimeClient extends Fake implements RealtimeClient {
  @override
  Future<void> setAuth(String? token) async {}
}

class _FakeRealtimeChannel extends Fake implements RealtimeChannel {
  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    dynamic filter,
    required void Function(PostgresChangePayload payload) callback,
  }) =>
      this;

  @override
  RealtimeChannel subscribe([
    void Function(RealtimeSubscribeStatus status, Object? error)? callback,
    Duration? timeout,
  ]) =>
      this;

  @override
  Future<String> unsubscribe([Duration? timeout]) async => 'ok';
}

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository(this.tasks);

  final List<TaskModel> tasks;
  final completedTaskIds = <String>[];
  final createdTitles = <String>[];

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(
    String householdId, {
    int limit = 100,
    int offset = 0,
  }) async {
    return right(tasks.skip(offset).take(limit).toList(growable: false));
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
    createdTitles.add(title);
    tasks.add(
      _task(
        id: 'created-${createdTitles.length}',
        title: title,
        status: TaskStatus.active,
        category: category,
        assignedTo: assignedTo,
      ),
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    completedTaskIds.add(task.id);
    final index = tasks.indexWhere((candidate) => candidate.id == task.id);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(
        status: TaskStatus.active,
        completedBy: userIds?.first,
        completedAt: completedAt,
      );
    }
    return right(
      const TaskCompletionResult(
        success: true,
        message: 'ok',
        queued: false,
        xpEarned: 20,
      ),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeTasksBatch(
    List<TaskModel> tasks, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return right({'success': true});
  }

  void markApproved(String taskId) {
    final index = tasks.indexWhere((candidate) => candidate.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(status: TaskStatus.verified);
    }
  }

  @override
  Future<Either<Failure, void>> verifyTask(
    String taskId,
    String verifiedByUserId,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> objectTask(
    String taskId,
    String objectedByUserId,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateSchedule(
    String taskId,
    String? recurrenceType, {
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? assignedTo,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> editTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoTaskCompletion(
    String activityId,
  ) async =>
      right({'success': true});
}

class _DelayedFakeTaskRepository extends _FakeTaskRepository {
  _DelayedFakeTaskRepository(super.tasks);

  final gate = Completer<void>();

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    await gate.future;
    return super.completeTask(
      task,
      userIds: userIds,
      completedAt: completedAt,
    );
  }
}

class _FakeTaskApprovalActions extends TaskApprovalActions {
  _FakeTaskApprovalActions(super.ref, this.repository);

  final _FakeTaskRepository repository;
  final approvedTaskIds = <String>[];

  @override
  Future<bool> approve(String taskId) async {
    approvedTaskIds.add(taskId);
    repository.markApproved(taskId);
    return true;
  }
}

class _DelayedTaskRpcService extends TaskRpcService {
  _DelayedTaskRpcService(SupabaseClient client) : super(clientOverride: client);

  final householdCompleter = Completer<String>();

  @override
  Future<String> requireHouseholdId() => householdCompleter.future;

  @override
  Future<String> requireCurrentUserId() async => 'user-1';

  @override
  Future<TaskCompletionResult> completeTaskTransaction({
    required String taskId,
    required String taskTitle,
    required int xpReward,
    required int coinReward,
    required String householdId,
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    return const TaskCompletionResult(
      success: true,
      message: 'ok',
      queued: false,
      xpEarned: 20,
    );
  }
}

class _FakeHouseholdMembers extends HouseholdMembersNotifier {
  _FakeHouseholdMembers(this.members);

  final List<MemberModel> members;

  @override
  Future<List<MemberModel>> build() async => members;
}

void main() {
  test('critical task flow creates, completes, and approves tasks', () async {
    final repository = _FakeTaskRepository([
      _task(id: 'active-1', title: 'Clean windows'),
      _task(
        id: 'approval-1',
        title: 'Take out trash',
        status: TaskStatus.pendingApproval,
      ),
    ]);
    late _FakeTaskApprovalActions approvalActions;

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
        taskApprovalActionsProvider.overrideWith((ref) {
          approvalActions = _FakeTaskApprovalActions(ref, repository);
          return approvalActions;
        }),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      tasksProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final optimisticSubscription = container.listen(
      optimisticRecentActivityProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(optimisticSubscription.close);

    final initialTasks = await container.read(tasksProvider.future);
    expect(
      initialTasks.map((task) => task.id),
      containsAll(['active-1', 'approval-1']),
    );

    await container.read(tasksProvider.notifier).createTask({
      'title': 'Do laundry',
      'description': null,
      'category': 'general_cleaning',
      'difficulty': 'easy',
      'xpReward': 15,
      'coinReward': 1,
      'assignedTo': 'user-1',
      'recurrenceType': null,
    });
    await container.pump();
    await container.pump();

    expect(repository.createdTitles, ['Do laundry']);
    expect(
      subscription.read().requireValue.map((task) => task.title),
      contains('Do laundry'),
    );

    final completion =
        await container.read(tasksProvider.notifier).completeTask(
              repository.tasks.firstWhere((task) => task.id == 'active-1'),
            );
    await container.pump();
    await container.pump();

    expect(completion?.success, isTrue);
    expect(repository.completedTaskIds, contains('active-1'));
    expect(
      subscription
          .read()
          .requireValue
          .firstWhere((task) => task.id == 'active-1')
          .completedAt,
      isNotNull,
    );
    expect(
      container.read(todayTasksProvider).requireValue.map((task) => task.id),
      isNot(contains('active-1')),
    );
    expect(
      optimisticSubscription.read().map(
            (activity) => (activity['data'] as Map<String, dynamic>)['task_id'],
          ),
      contains('active-1'),
    );

    final approval =
        await container.read(tasksProvider.notifier).approvePendingTask(
              repository.tasks.firstWhere((task) => task.id == 'approval-1'),
            );
    await _pumpUntil(
      container,
      () =>
          subscription
              .read()
              .requireValue
              .firstWhere((task) => task.id == 'approval-1')
              .status ==
          TaskStatus.verified,
    );

    expect(approval?.success, isTrue);
    expect(approvalActions.approvedTaskIds, ['approval-1']);
    expect(
      subscription
          .read()
          .requireValue
          .firstWhere((task) => task.id == 'approval-1')
          .status,
      TaskStatus.verified,
    );
  });

  test('repository completes task even if provider is disposed mid-flight',
      () async {
    final client = _FakeSupabaseClient();
    final rpc = _DelayedTaskRpcService(client);
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('user-1'),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(client),
        taskRpcServiceProvider.overrideWithValue(rpc),
      ],
    );

    final repository = container.read(taskRepositoryProvider);
    final pendingCompletion = repository.completeTask(
      _task(id: 'active-1', title: 'Clean windows'),
    );

    await Future<void>.delayed(Duration.zero);
    container.dispose();
    rpc.householdCompleter.complete('house-1');

    final result = await pendingCompletion;
    expect(result.isRight(), isTrue);
    expect(
      result.getOrElse((_) => throw StateError('expected success')).success,
      isTrue,
    );
  });

  test('task completion ignores duplicate taps while request is in flight',
      () async {
    final repository = _DelayedFakeTaskRepository([
      _task(id: 'active-1', title: 'Clean windows'),
    ]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    final notifier = container.read(tasksProvider.notifier);
    final task = repository.tasks.single;

    final first = notifier.completeTask(task);
    await Future<void>.delayed(Duration.zero);
    final second = notifier.completeTask(task);

    repository.gate.complete();

    expect((await first)?.success, isTrue);
    expect(await second, isNull);
    expect(repository.completedTaskIds, ['active-1']);
  });

  test(
      'task completion keeps activity feed populated while remote stream is stable',
      () async {
    final repository = _FakeTaskRepository([
      _task(id: 'active-1', title: 'Clean windows'),
    ]);
    final remoteActivity = StreamController<List<Map<String, dynamic>>>();

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        recentActivityRealtimeDelayProvider.overrideWith((ref) async => true),
        recentActivityRemoteProvider.overrideWith((ref) {
          ref.onDispose(remoteActivity.close);
          return remoteActivity.stream;
        }),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    final activitySubscription = container.listen(
      recentActivityProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(activitySubscription.close);

    remoteActivity.add(const []);
    await container.read(tasksProvider.future);
    await container.pump();

    final completion =
        await container.read(tasksProvider.notifier).completeTask(
              repository.tasks.single,
            );
    await container.pump();

    expect(completion?.success, isTrue);
    expect(activitySubscription.read().hasValue, isTrue);
    expect(
      activitySubscription.read().requireValue.map(
            (activity) => (activity['data'] as Map<String, dynamic>)['task_id'],
          ),
      contains('active-1'),
    );
  });

  test(
      'task completion stays completed after silent refresh when startup bootstrap is stale',
      () async {
    final task = _task(
      id: 'active-1',
      title: 'Clean windows',
      dueAt: DateTime.now(),
    );
    final repository = _FakeTaskRepository([task]);
    final staleBootstrap = HomeBootstrapData(
      authenticated: true,
      userId: 'user-1',
      householdId: 'house-1',
      memberOnboardingCompleted: true,
      profile: null,
      household: null,
      members: const [],
      tasks: [task.toMap()],
      expenseBalances: const [],
      userBalance: null,
      combinedFeed: const [],
      recentActivities: const [],
    );

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => staleBootstrap),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      todayTasksProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(tasksProvider.future);
    expect(subscription.read().requireValue.map((task) => task.id), [
      'active-1',
    ]);

    final completion =
        await container.read(tasksProvider.notifier).completeTask(task);
    await container.pump();
    await container.pump();

    expect(completion?.success, isTrue);
    expect(
      container
          .read(tasksProvider)
          .requireValue
          .firstWhere((candidate) => candidate.id == 'active-1')
          .completedAt,
      isNotNull,
    );
    expect(
      subscription.read().requireValue.map((task) => task.id),
      isNot(contains('active-1')),
    );

    container.invalidate(tasksProvider);
    await container.read(tasksProvider.future);
    await container.pump();

    expect(
      subscription.read().requireValue.map((task) => task.id),
      isNot(contains('active-1')),
    );
  });

  test('today tasks excludes tasks already present in today activity feed',
      () async {
    final task = _task(
      id: 'active-1',
      title: 'Clean windows',
      dueAt: DateTime.now(),
    );
    final repository = _FakeTaskRepository([
      task.copyWith(
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        recentActivityProvider.overrideWith(
          (ref) => AsyncValue.data([
            {
              'id': 'activity-1',
              'type': 'task',
              'created_at': DateTime.now().toIso8601String(),
              'data': const {
                'task_id': 'active-1',
                'title': 'Clean windows',
              },
            },
          ]),
        ),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    expect(
      container.read(todayTasksProvider).requireValue.map((task) => task.id),
      isNot(contains('active-1')),
    );
  });

  test('today tasks hides repeatable daily tasks once completed today',
      () async {
    final task = _task(
      id: 'active-1',
      title: 'Wash dishes',
      recurrenceType: 'daily',
      allowMultipleDailyCompletions: true,
      dueAt: DateTime.utc(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
    ).copyWith(completedAt: DateTime.now());
    final repository = _FakeTaskRepository([task]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        recentActivityProvider.overrideWith(
          (ref) => AsyncValue.data([
            {
              'id': 'activity-1',
              'type': 'task',
              'created_at': DateTime.now().toIso8601String(),
              'data': const {
                'task_id': 'active-1',
                'title': 'Wash dishes',
              },
            },
          ]),
        ),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    expect(
      container.read(todayTasksProvider).requireValue.map((task) => task.id),
      isNot(contains('active-1')),
    );
  });

  test('today tasks hides recurring tasks already advanced to tomorrow',
      () async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final task = _task(
      id: 'active-1',
      title: 'Deep cleaning',
      recurrenceType: 'daily',
      dueAt: DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day),
    ).copyWith(completedAt: DateTime.now());
    final repository = _FakeTaskRepository([task]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        recentActivityProvider.overrideWith(
          (ref) => AsyncValue.data([
            {
              'id': 'activity-1',
              'type': 'task',
              'created_at': DateTime.now().toIso8601String(),
              'data': const {
                'task_id': 'active-1',
                'title': 'Deep cleaning',
              },
            },
          ]),
        ),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    expect(
      container.read(todayTasksProvider).requireValue.map((task) => task.id),
      isNot(contains('active-1')),
    );
  });

  test(
      'today tasks hides repeatable daily tasks after completion even when '
      'advanced to tomorrow', () async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final task = _task(
      id: 'active-1',
      title: 'Sweep floors',
      recurrenceType: 'daily',
      allowMultipleDailyCompletions: true,
      dueAt: DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day),
    ).copyWith(completedAt: DateTime.now());
    final repository = _FakeTaskRepository([task]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            MemberModel(
              id: 'member-1',
              userId: 'user-1',
              householdId: 'house-1',
              role: 'owner',
              joinedAt: DateTime(2026),
              fullName: 'Test User',
              email: 'test@example.invalid',
              type: MemberType.parent,
            ),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        recentActivityProvider.overrideWith(
          (ref) => AsyncValue.data([
            {
              'id': 'activity-1',
              'type': 'task',
              'created_at': DateTime.now().toIso8601String(),
              'data': const {
                'task_id': 'active-1',
                'title': 'Sweep floors',
              },
            },
          ]),
        ),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    expect(
      container.read(todayTasksProvider).requireValue.map((task) => task.id),
      isNot(contains('active-1')),
    );
  });

  // ── Regression net: optimistic feed + assignment scope ────────────────────

  test('completing a task online records exactly one optimistic feed entry',
      () async {
    final repository = _FakeTaskRepository([
      _task(id: 'active-1', title: 'Clean windows'),
    ]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([_member('user-1')]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    final optimisticSubscription = container.listen(
      optimisticRecentActivityProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(optimisticSubscription.close);

    await container.read(tasksProvider.future);
    await container
        .read(tasksProvider.notifier)
        .completeTask(repository.tasks.single);
    await container.pump();

    // Exactly one optimistic entry: the optimistic feed entry is owned solely
    // by Tasks.completeTask. A second add (previously done by each home view)
    // produced a DUPLICATE row in the activity feed.
    final entriesForTask = optimisticSubscription
        .read()
        .where(
          (activity) =>
              (activity['data'] as Map<String, dynamic>)['task_id'] ==
              'active-1',
        )
        .toList();
    expect(entriesForTask, hasLength(1));
  });

  test('today tasks hides tasks assigned to another member', () async {
    final repository = _FakeTaskRepository([
      _task(
        id: 'mine',
        title: 'My task',
        assignedTo: 'user-1',
        dueAt: DateTime.now(),
      ),
      _task(
        id: 'theirs',
        title: 'Their task',
        assignedTo: 'user-2',
        dueAt: DateTime.now(),
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('user-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([_member('user-1'), _member('user-2')]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    final ids =
        container.read(todayTasksProvider).requireValue.map((t) => t.id);
    expect(ids, contains('mine'));
    expect(ids, isNot(contains('theirs')));
  });

  test('family child today tasks only include their own + unassigned tasks',
      () async {
    final repository = _FakeTaskRepository([
      _task(
        id: 'mine',
        title: 'Child task',
        assignedTo: 'child-1',
        dueAt: DateTime.now(),
      ),
      _task(
        id: 'parent',
        title: 'Parent task',
        assignedTo: 'parent-1',
        dueAt: DateTime.now(),
      ),
      _task(
        id: 'unassigned',
        title: 'Shared task',
        assignedTo: null,
        dueAt: DateTime.now(),
      ),
    ]);

    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        householdIdProvider.overrideWith((ref) async => 'house-1'),
        currentUserIdProvider.overrideWithValue('child-1'),
        currentHouseholdProvider.overrideWith((ref) async => null),
        householdCapabilitiesProvider.overrideWithValue(
          const HouseholdCapabilities(type: HouseholdType.family),
        ),
        householdMembersProvider.overrideWith(
          () => _FakeHouseholdMembers([
            _member('child-1', type: MemberType.child),
            _member('parent-1'),
          ]),
        ),
        homeBootstrapProvider.overrideWith((ref) async => null),
        isOnlineProvider.overrideWith((ref) => true),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(tasksProvider.future);
    // Members must be resolved for the child-scope filter to apply (in the app
    // this is a warmed blocking provider before the home renders).
    await container.read(householdMembersProvider.future);
    final ids = container
        .read(todayTasksProvider)
        .requireValue
        .map((t) => t.id)
        .toList();
    expect(ids, contains('mine'));
    expect(ids, isNot(contains('parent')));
    // The child filter only excludes tasks assigned to OTHERS; an unassigned
    // household task stays visible.
    expect(ids, contains('unassigned'));
  });
}

TaskModel _task({
  required String id,
  required String title,
  TaskStatus status = TaskStatus.active,
  String category = 'general_cleaning',
  String? assignedTo = 'user-1',
  String? recurrenceType,
  bool allowMultipleDailyCompletions = false,
  DateTime? dueAt,
}) {
  return TaskModel(
    id: id,
    title: title,
    category: category,
    assignedTo: assignedTo,
    status: status,
    xpReward: 15,
    coinReward: 1,
    householdId: 'house-1',
    createdAt: DateTime(2026),
    dueAt: dueAt,
    recurrenceType: recurrenceType,
    allowMultipleDailyCompletions: allowMultipleDailyCompletions,
  );
}

MemberModel _member(String userId, {MemberType type = MemberType.parent}) {
  return MemberModel(
    id: 'member-$userId',
    userId: userId,
    householdId: 'house-1',
    role: 'owner',
    joinedAt: DateTime(2026),
    fullName: 'User $userId',
    email: '$userId@example.invalid',
    type: type,
  );
}

Future<void> _pumpUntil(
  ProviderContainer container,
  bool Function() condition,
) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(Duration.zero);
    await container.pump();
  }
}
