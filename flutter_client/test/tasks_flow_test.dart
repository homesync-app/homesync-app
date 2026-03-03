import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/data/repositories/supabase_task_repository.dart';
import 'package:homesync_client/features/tasks/domain/repositories/task_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';

import 'tasks_flow_test.mocks.dart';

// Fake Supabase for Realtime setup
class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  RealtimeChannel channel(String name, {RealtimeChannelConfig opts = const RealtimeChannelConfig()}) => FakeRealtimeChannel();
}

class FakeRealtimeChannel extends Fake implements RealtimeChannel {
  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    dynamic filter,
    required void Function(PostgresChangePayload payload) callback,
  }) => this;

  @override
  RealtimeChannel subscribe([void Function(RealtimeSubscribeStatus status, Object? error)? callback, Duration? timeout]) => this;

  @override
  Future<String> unsubscribe([Duration? timeout]) async => 'ok';
}

@GenerateMocks([TaskRepository])
void main() {
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

  testWidgets('TasksScreen renders tasks and allows completion', (WidgetTester tester) async {
    // 1. Mock Repository Responses
    when(mockTaskRepo.getTasks(any, limit: anyNamed('limit'), offset: anyNamed('offset')))
        .thenAnswer((_) async => [testTask]);
    
    // For completion
    when(mockTaskRepo.completeTask(any, userId: anyNamed('userId')))
        .thenAnswer((_) async => {'xp_earned': 10, 'coins_earned': 5});

    // 2. Build Widget with Overrides
    await tester.pumpWidget(ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockTaskRepo),
        supabaseClientProvider.overrideWithValue(FakeSupabaseClient()),
        householdIdProvider.overrideWith((ref) => 'h1'),
        currentUserIdProvider.overrideWithValue('u1'),
        categoriesProvider.overrideWith((ref) => [testCategory]),
        householdMembersProvider.overrideWith((ref) => [
          MemberModel(
            id: 'm1',
            userId: 'u1',
            householdId: 'h1',
            role: 'owner',
            joinedAt: DateTime.now(),
            fullName: 'User One',
            email: 'u1@test.com',
          )
        ]),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const TasksScreen(),
      ),
    ));

    // 3. Verify initial state
    await tester.pumpAndSettle();
    expect(find.text('Lavar platos'), findsOneWidget);
    expect(find.text('LIMPIEZA'), findsOneWidget);

    // 4. Click to Expand
    await tester.tap(find.text('Lavar platos'));
    await tester.pumpAndSettle();

    // 5. Click Complete
    final completeButton = find.text('Completar');
    expect(completeButton, findsOneWidget);
    await tester.tap(completeButton);
    await tester.pumpAndSettle();
    
    // 6. Verify Repository Call
    verify(mockTaskRepo.completeTask(any, userId: 'u1')).called(1);

    // 7. Verify Snackbar
    expect(find.textContaining('¡Ganaste 10 XP y 5 coins!'), findsOneWidget);
  });
}
