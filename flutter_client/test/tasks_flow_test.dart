import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/data/repositories/supabase_task_repository.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'tasks_flow_test.mocks.dart';

/// Minimal [SupabaseClient] fake.
///
/// The widget tree may reach Supabase through realtime channels or
/// `client.from(...)` calls (e.g. household repository).  We override every
/// surface that tasks_screen's provider tree touches.
class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  RealtimeChannel channel(String name,
          {RealtimeChannelConfig opts = const RealtimeChannelConfig(),}) =>
      FakeRealtimeChannel();

  @override
  SupabaseQueryBuilder from(String table) => FakeSupabaseQueryBuilder();
}

class FakeRealtimeChannel extends Fake implements RealtimeChannel {
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
  RealtimeChannel subscribe(
          [void Function(RealtimeSubscribeStatus status, Object? error)?
              callback,
          Duration? timeout,]) =>
      this;

  @override
  Future<String> unsubscribe([Duration? timeout]) async => 'ok';
}

/// Returns empty results for any chained query so the widget tree never
/// crashes but also never gets real data.
class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select(
          [String columns = '*',]) =>
      FakePostgrestFilterBuilder();
}

class FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
    String column,
    Object value,
  ) =>
      this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() =>
      FakePostgrestTransformBuilder();
}

class FakePostgrestTransformBuilder extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  @override
  Future<U> then<U>(
    FutureOr<U> Function(Map<String, dynamic>? value) onValue, {
    Function? onError,
  }) async =>
      await onValue(null);
}

@GenerateMocks([TaskRepository])
void main() {
  provideDummy<Either<Failure, List<TaskModel>>>(const Right([]));
  provideDummy<Either<Failure, void>>(const Right(null));

  late MockTaskRepository mockTaskRepo;

  setUp(() {
    mockTaskRepo = MockTaskRepository();
  });

  final testCategory = CategoryModel(
    id: 'limpieza',
    name: 'Limpieza',
    icon: '🧹',
    color: '#3B82F6',
    sortOrder: 1,
  );

  final testTask = TaskModel(
    id: 't1',
    title: 'Lavar platos',
    category: 'limpieza',
    difficulty: TaskDifficulty.easy,
    xpReward: 10,
    coinReward: 5,
    status: TaskStatus.active,
    createdAt: DateTime.now(),
    householdId: 'h1',
  );

  testWidgets('TasksScreen renders tasks and shows inline actions on tap',
      (WidgetTester tester) async {
    when(mockTaskRepo.getTasks('h1',
            limit: anyNamed('limit'), offset: anyNamed('offset'),),)
        .thenAnswer((_) async => Right([testTask]));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockTaskRepo),
        supabaseClientProvider.overrideWithValue(FakeSupabaseClient()),
        householdIdProvider.overrideWith((ref) => 'h1'),
        currentUserIdProvider.overrideWithValue('u1'),
        categoriesProvider.overrideWith((ref) => [testCategory]),
        householdMembersProvider.overrideWith(() => MockHouseholdMembers([
              MemberModel(
                id: 'm1',
                userId: 'u1',
                householdId: 'h1',
                role: 'owner',
                joinedAt: DateTime.now(),
                fullName: 'User One',
                email: 'u1@test.com',
                type: MemberType.parent,
              ),
            ]),),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const TasksScreen(),
      ),
    ),);

    await tester.pumpAndSettle();

    // ── Verify the task renders ──
    expect(find.text('Lavar platos'), findsOneWidget);
    expect(find.text('LIMPIEZA'), findsOneWidget);

    // ── Tap the task card to expand inline actions ──
    await tester.tap(find.text('Lavar platos'));
    await tester.pumpAndSettle();

    // The expanded card shows Editar, Programar (and Completar for non-family)
    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Programar'), findsOneWidget);
    // The current UI shows "Completar" instead of "Eliminar"
    expect(find.text('Completar'), findsOneWidget);
  });
}

class MockHouseholdMembers extends HouseholdMembers {
  final List<MemberModel> members;
  MockHouseholdMembers(this.members);

  @override
  Future<List<MemberModel>> build() async => members;
}
