import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/tasks/data/repositories/supabase_task_repository.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
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
    List<PostgresChangeFilter>? filters,
    List<String>? select,
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

class _FailingTaskRepository implements TaskRepository {
  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(
    String householdId, {
    int limit = 100,
    int offset = 0,
  }) async =>
      const Left(ServerFailure('repo boom'));

  @override
  Future<Either<Failure, TaskCompletionResult>> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeTasksBatch(
    List<TaskModel> tasks, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> verifyTask(
    String taskId,
    String verifiedByUserId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> objectTask(
    String taskId,
    String objectedByUserId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> updateSchedule(
    String taskId,
    String? recurrenceType, {
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? assignedTo,
  }) async =>
      throw UnimplementedError();

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
  }) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> editTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Map<String, dynamic>>> undoTaskCompletion(
    String activityId,
  ) async =>
      throw UnimplementedError();
}

void main() {
  test('tasksProvider exposes ServerFailure as provider error', () async {
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(_FailingTaskRepository()),
        householdIdProvider.overrideWith((ref) => 'h1'),
        supabaseClientProvider.overrideWithValue(_FakeSupabaseClient()),
        // Aislar el unit: sin snapshot de bootstrap, _loadTasks cae al fetch
        // del repo (que falla). Evita que el provider real toque Firebase y
        // deje el estado colgado en loading dentro del entorno de test.
        homeBootstrapProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      tasksProvider,
      (_, __) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    // El build encadena varios await (householdId -> bootstrap -> repo). Dejamos
    // que los microtasks/futures se asienten antes de leer el estado final.
    for (var i = 0; i < 10; i++) {
      await container.pump();
      await Future<void>.delayed(Duration.zero);
    }

    final state = subscription.read();
    expect(state.hasError, isTrue);
    expect(
      state.error,
      isA<ServerFailure>().having(
        (failure) => failure.message,
        'message',
        'repo boom',
      ),
    );
  });
}
