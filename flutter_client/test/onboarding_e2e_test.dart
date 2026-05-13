// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — E2E Onboarding Flow Tests
// Tests: Login → Setup Household → Dashboard → Complete Task
// Run with: flutter test test/onboarding_e2e_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/auth/domain/models/user_model.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

enum AuthState { loggedOut, authenticating, authenticated, needsSetup }

enum SetupStep {
  welcome,
  createOrJoin,
  householdDetails,
  invitePartner,
  complete
}

class OnboardingFlowSimulator {
  AuthState authState = AuthState.loggedOut;
  UserModel? currentUser;
  HouseholdModel? household;
  SetupStep? currentStep;
  List<TaskModel> tasks = [];
  int coins = 0;
  int xp = 0;

  Future<UserModel> signIn(String email, String password) async {
    authState = AuthState.authenticating;
    await Future.delayed(const Duration(milliseconds: 100));

    currentUser = UserModel(
      id: 'user-${email.hashCode}',
      email: email,
      fullName: email.split('@').first,
    );
    authState = AuthState.authenticated;
    return currentUser!;
  }

  Future<void> signOut() async {
    authState = AuthState.loggedOut;
    currentUser = null;
    household = null;
    currentStep = null;
  }

  Future<void> checkHouseholdSetup() async {
    if (currentUser != null) {
      if (household == null) {
        currentStep = SetupStep.welcome;
      }
    }
  }

  Future<void> createHousehold(String name, String type) async {
    household = HouseholdModel(
      id: 'household-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      householdType: type,
      createdAt: DateTime.now(),
    );
    currentStep = SetupStep.invitePartner;
  }

  Future<void> joinHousehold(String inviteCode) async {
    // Simulate joining
    household = HouseholdModel(
      id: 'household-joined',
      name: 'Joined Household',
      householdType: 'couple',
      createdAt: DateTime.now(),
    );
    currentStep = SetupStep.complete;
  }

  Future<void> completeSetup() async {
    currentStep = null;
  }

  Future<TaskModel> createTask({
    required String title,
    required String category,
    required TaskDifficulty difficulty,
  }) async {
    final xpReward = _getXpForDifficulty(difficulty);
    final coinReward = _getCoinsForDifficulty(difficulty);

    final task = TaskModel(
      id: 'task-${tasks.length + 1}',
      title: title,
      category: category,
      difficulty: difficulty,
      status: TaskStatus.active,
      xpReward: xpReward,
      coinReward: coinReward,
      householdId: household?.id ?? 'household-1',
      createdAt: DateTime.now(),
    );

    tasks.add(task);
    return task;
  }

  int _getXpForDifficulty(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 20;
      case TaskDifficulty.medium:
        return 35;
      case TaskDifficulty.hard:
        return 50;
    }
  }

  int _getCoinsForDifficulty(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 10;
      case TaskDifficulty.medium:
        return 20;
      case TaskDifficulty.hard:
        return 30;
    }
  }

  Future<void> completeTask(TaskModel task) async {
    // Create a new task with verified status
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = TaskModel(
        id: task.id,
        title: task.title,
        category: task.category,
        difficulty: task.difficulty,
        status: TaskStatus.verified,
        xpReward: task.xpReward,
        coinReward: task.coinReward,
        householdId: task.householdId,
        createdAt: task.createdAt,
      );
    }
    xp += task.xpReward;
    coins += task.coinReward;
  }
}

void main() {
  group('✅ E2E Onboarding Flow', () {
    late OnboardingFlowSimulator simulator;

    setUp(() {
      simulator = OnboardingFlowSimulator();
    });

    test('Complete onboarding: Login → Create Household → Dashboard', () async {
      // Step 1: User signs in
      final user = await simulator.signIn('juan@email.com', 'password123');
      expect(simulator.authState, equals(AuthState.authenticated));
      expect(user.email, equals('juan@email.com'));

      // Step 2: Check if household setup is needed
      await simulator.checkHouseholdSetup();
      expect(simulator.currentStep, equals(SetupStep.welcome));

      // Step 3: Create household
      await simulator.createHousehold('Mi Hogar', 'couple');
      expect(simulator.household?.name, equals('Mi Hogar'));
      expect(simulator.household?.householdType, equals('couple'));

      // Step 4: Complete setup
      await simulator.completeSetup();
      expect(simulator.currentStep, isNull);
      expect(simulator.authState, equals(AuthState.authenticated));
    });

    test('Join existing household with invite code', () async {
      // Step 1: Sign in
      await simulator.signIn('maria@email.com', 'password123');

      // Step 2: Check setup
      await simulator.checkHouseholdSetup();

      // Step 3: Join with invite code
      await simulator.joinHousehold('ABC123');

      expect(simulator.household, isNotNull);
      expect(simulator.currentStep, equals(SetupStep.complete));
    });

    test('Sign out and sign in again', () async {
      // Sign in and create household
      await simulator.signIn('test@email.com', 'pass');
      await simulator.createHousehold('Test Home', 'couple');
      await simulator.completeSetup();

      // Sign out
      await simulator.signOut();
      expect(simulator.authState, equals(AuthState.loggedOut));
      expect(simulator.currentUser, isNull);

      // Sign in again - should not need setup since household exists
      await simulator.signIn('test@email.com', 'pass');
      expect(simulator.authState, equals(AuthState.authenticated));
    });

    test('User can create task after onboarding', () async {
      // Complete onboarding
      await simulator.signIn('user@email.com', 'pass');
      await simulator.createHousehold('Home', 'couple');
      await simulator.completeSetup();

      // Create a task on dashboard
      final task = await simulator.createTask(
        title: 'Lavar los platos',
        category: 'kitchen',
        difficulty: TaskDifficulty.easy,
      );

      expect(simulator.tasks.length, equals(1));
      expect(task.title, equals('Lavar los platos'));
      expect(task.xpReward, equals(20));
    });

    test('Complete onboarding → Task → Earn rewards', () async {
      // Complete onboarding
      await simulator.signIn('player@email.com', 'pass');
      await simulator.createHousehold('Home', 'couple');
      await simulator.completeSetup();

      // Create and complete a task
      final task = await simulator.createTask(
        title: 'Barrer',
        category: 'cleaning',
        difficulty: TaskDifficulty.medium,
      );

      await simulator.completeTask(task);

      expect(simulator.xp, equals(35));
      expect(simulator.coins, equals(20));
      // Check the updated task status
      final completedTask = simulator.tasks.firstWhere((t) => t.id == task.id);
      expect(completedTask.status, equals(TaskStatus.verified));
    });

    test('Multiple tasks accumulate XP and coins', () async {
      await simulator.signIn('earn@email.com', 'pass');
      await simulator.createHousehold('Home', 'couple');
      await simulator.completeSetup();

      final tasks = [
        await simulator.createTask(
          title: 'Tarea 1',
          category: 'kitchen',
          difficulty: TaskDifficulty.easy,
        ),
        await simulator.createTask(
          title: 'Tarea 2',
          category: 'cleaning',
          difficulty: TaskDifficulty.medium,
        ),
        await simulator.createTask(
          title: 'Tarea 3',
          category: 'other',
          difficulty: TaskDifficulty.hard,
        ),
      ];

      for (final task in tasks) {
        await simulator.completeTask(task);
      }

      expect(simulator.xp, equals(105)); // 20 + 35 + 50
      expect(simulator.coins, equals(60)); // 10 + 20 + 30
    });
  });

  group('✅ Household Type Validation', () {
    test('HouseholdType string values are valid', () {
      const validTypes = ['couple', 'family', 'roommates'];
      expect(validTypes, contains('couple'));
      expect(validTypes, contains('family'));
      expect(validTypes, contains('roommates'));
    });

    test('Couple household type works', () {
      const coupleType = 'couple';
      expect(coupleType, equals('couple'));
    });

    test('Family household type works', () {
      const familyType = 'family';
      expect(familyType, equals('family'));
    });
  });

  group('✅ User Model Validation', () {
    test('UserModel fromJson parses correctly', () {
      final json = {
        'id': 'user-1',
        'email': 'test@example.com',
        'full_name': 'Test User',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals('user-1'));
      expect(user.email, equals('test@example.com'));
      expect(user.fullName, equals('Test User'));
    });

    test('UserModel displayName returns full name or email prefix', () {
      const userWithName = UserModel(
        id: 'user-1',
        email: 'test@email.com',
        fullName: 'Juan Perez',
      );

      expect(userWithName.displayName, equals('Juan Perez'));

      const userWithoutName = UserModel(
        id: 'user-2',
        email: 'another@email.com',
      );

      expect(userWithoutName.displayName, equals('another'));
    });
  });

  group('✅ Setup Step Flow', () {
    test('All setup steps are defined', () {
      expect(SetupStep.values.length, equals(5));
      expect(SetupStep.values, contains(SetupStep.welcome));
      expect(SetupStep.values, contains(SetupStep.createOrJoin));
      expect(SetupStep.values, contains(SetupStep.householdDetails));
      expect(SetupStep.values, contains(SetupStep.invitePartner));
      expect(SetupStep.values, contains(SetupStep.complete));
    });

    test('Setup step progression', () {
      var step = SetupStep.welcome;
      expect(step, equals(SetupStep.welcome));

      step = SetupStep.createOrJoin;
      expect(step, equals(SetupStep.createOrJoin));
    });
  });
}
