import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/dashboard/domain/models/solo_progress_snapshot.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

void main() {
  group('SoloProgressSnapshot', () {
    test('starts as recent move and suggests creating a task', () {
      final snapshot = SoloProgressSnapshot.fromInputs(
        xp: 0,
        tasks: const [],
        todayTasks: const [],
        financeSummary: const {},
        recentActivities: const [],
        taskStats: const [],
        memberStats: const [],
        xpHistory: const [],
      );

      expect(snapshot.level, 1);
      expect(snapshot.stage, SoloProgressStage.recentMove);
      expect(snapshot.nextAction, SoloProgressNextAction.createTask);
      expect(snapshot.nextActionTargetTab, MainTab.tasks);
      expect(snapshot.milestones, isEmpty);
    });

    test('prioritizes completing pending tasks for today', () {
      final task = _task(dueAt: DateTime.now());
      final snapshot = SoloProgressSnapshot.fromInputs(
        xp: 1200,
        tasks: [task],
        todayTasks: [task],
        financeSummary: const {'expense': 0.0, 'income': 0.0},
        recentActivities: const [],
        taskStats: const [],
        memberStats: const [],
        xpHistory: const [],
      );

      expect(snapshot.level, 2);
      expect(snapshot.nextAction, SoloProgressNextAction.completeTask);
      expect(snapshot.nextActionTargetTab, MainTab.tasks);
    });

    test('unlocks personal milestones for advanced solo progress', () {
      final activities = List.generate(
        4,
        (index) => {
          'created_at':
              DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        },
      );

      final snapshot = SoloProgressSnapshot.fromInputs(
        xp: 5200,
        tasks: [_task()],
        todayTasks: const [],
        financeSummary: const {
          'expense': 3000.0,
          'income': 10000.0,
          'variation': 700.0,
          'balance': 7000.0,
        },
        recentActivities: activities,
        taskStats: const [
          {'completed_count': 50, 'total_xp': 5000},
        ],
        memberStats: const [],
        xpHistory: const [
          {'amount': 20},
          {'amount': 20},
          {'amount': 20},
        ],
      );

      expect(snapshot.level, 6);
      expect(snapshot.stage, isNot(SoloProgressStage.recentMove));
      expect(snapshot.milestones, contains(SoloProgressMilestone.firstStep));
      expect(snapshot.milestones, contains(SoloProgressMilestone.weekInMotion));
      expect(snapshot.milestones, contains(SoloProgressMilestone.clearerHome));
      expect(
        snapshot.milestones,
        contains(SoloProgressMilestone.steadyRoutine),
      );
      expect(snapshot.milestones, contains(SoloProgressMilestone.ownRhythm));
    });

    test('uses server snapshot for weekly progress signals', () {
      final snapshot = SoloProgressSnapshot.fromInputs(
        xp: 100,
        tasks: [_task()],
        todayTasks: const [],
        financeSummary: const {'expense': 0.0, 'income': 0.0},
        recentActivities: const [],
        taskStats: const [],
        memberStats: const [],
        xpHistory: const [],
        serverSnapshot: const {
          'authorized': true,
          'xp': 2400,
          'weekly_xp': 180,
          'previous_week_xp': 80,
          'weekly_xp_delta': 100,
          'tasks_completed': 8,
          'weekly_tasks_completed': 4,
          'previous_week_tasks_completed': 1,
          'tasks_completed_delta': 3,
          'current_streak_days': 3,
          'active_days_14': 5,
          'monthly_expense': '1250.50',
          'monthly_income': 0,
          'recent_activity_count': 4,
          'top_task_category': 'cocina',
          'top_expense_category': 'super',
        },
      );

      expect(snapshot.hasServerSnapshot, isTrue);
      expect(snapshot.xp, 2400);
      expect(snapshot.level, 3);
      expect(snapshot.weeklyXp, 180);
      expect(snapshot.weeklyXpDelta, 100);
      expect(snapshot.weeklyTasksCompleted, 4);
      expect(snapshot.tasksCompletedDelta, 3);
      expect(snapshot.currentStreakDays, 3);
      expect(snapshot.activeDays14, 5);
      expect(snapshot.clarityScore, greaterThan(10));
      expect(snapshot.topTaskCategory, 'cocina');
      expect(snapshot.topExpenseCategory, 'super');
      expect(snapshot.milestones, contains(SoloProgressMilestone.weekInMotion));
      expect(snapshot.insights, contains(SoloEvolutionInsight.streakBuilding));
      expect(snapshot.insights, contains(SoloEvolutionInsight.weekImproved));
      expect(
        snapshot.suggestions,
        contains(SoloEvolutionSuggestion.createRecurringTask),
      );
      expect(
        snapshot.softUnlocks,
        contains(SoloSoftUnlock.recurringTemplates),
      );
      expect(snapshot.softUnlocks, contains(SoloSoftUnlock.habitInsights));
    });

    test('keeps weekly review available for new users', () {
      final snapshot = SoloProgressSnapshot.fromInputs(
        xp: 0,
        tasks: const [],
        todayTasks: const [],
        financeSummary: const {},
        recentActivities: const [],
        taskStats: const [],
        memberStats: const [],
        xpHistory: const [],
      );

      expect(snapshot.insights, contains(SoloEvolutionInsight.noActivityYet));
      expect(
        snapshot.suggestions,
        contains(SoloEvolutionSuggestion.createRecurringTask),
      );
      expect(
        snapshot.suggestions,
        contains(SoloEvolutionSuggestion.registerExpense),
      );
      expect(snapshot.softUnlocks, [SoloSoftUnlock.weeklyReview]);
    });
  });
}

TaskModel _task({DateTime? dueAt}) {
  return TaskModel(
    id: 'task-1',
    title: 'Ordenar cocina',
    status: TaskStatus.active,
    xpReward: 10,
    coinReward: 0,
    householdId: 'household-1',
    createdAt: DateTime.now(),
    dueAt: dueAt,
  );
}
