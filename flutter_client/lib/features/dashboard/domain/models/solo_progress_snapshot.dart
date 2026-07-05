import 'dart:math' as math;

import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

enum SoloProgressStage {
  recentMove,
  inMotion,
  steadyRoutine,
  organizedHome,
  ownRhythm,
}

enum SoloProgressMilestone {
  firstStep,
  weekInMotion,
  clearerHome,
  steadyRoutine,
  ownRhythm,
}

enum SoloProgressNextAction {
  createTask,
  completeTask,
  registerExpense,
  reviewShopping,
  keepGoing,
}

enum SoloWeeklyRitualStep {
  reviewTasks,
  checkSpending,
  planShopping,
  chooseNextRoutine,
}

enum SoloEvolutionInsight {
  noActivityYet,
  streakBuilding,
  weekImproved,
  weekSlowedDown,
  financeVisible,
  noFinanceYet,
  strongTaskCategory,
  strongExpenseCategory,
}

enum SoloEvolutionSuggestion {
  createRecurringTask,
  closePending,
  registerExpense,
  reviewShopping,
  protectStreak,
  runWeeklyReview,
}

enum SoloSoftUnlock {
  weeklyReview,
  recurringTemplates,
  habitInsights,
  personalMedal,
  rhythmRecommendations,
}

class SoloProgressSnapshot {
  static const int xpPerLevel = 1000;

  final int level;
  final int xp;
  final int xpInLevel;
  final int xpToNextLevel;
  final double levelProgress;
  final int orderScore;
  final int clarityScore;
  final int continuityScore;
  final bool hasServerSnapshot;
  final int weeklyXp;
  final int previousWeekXp;
  final int weeklyXpDelta;
  final int weeklyTasksCompleted;
  final int previousWeekTasksCompleted;
  final int tasksCompletedDelta;
  final int currentStreakDays;
  final int activeDays14;
  final int recentActivityCount;
  final String? topTaskCategory;
  final String? topExpenseCategory;
  final SoloProgressStage stage;
  final SoloProgressNextAction nextAction;
  final MainTab nextActionTargetTab;
  final List<SoloProgressMilestone> milestones;
  final List<SoloEvolutionInsight> insights;
  final List<SoloEvolutionSuggestion> suggestions;
  final List<SoloSoftUnlock> softUnlocks;

  const SoloProgressSnapshot({
    required this.level,
    required this.xp,
    required this.xpInLevel,
    required this.xpToNextLevel,
    required this.levelProgress,
    required this.orderScore,
    required this.clarityScore,
    required this.continuityScore,
    required this.hasServerSnapshot,
    required this.weeklyXp,
    required this.previousWeekXp,
    required this.weeklyXpDelta,
    required this.weeklyTasksCompleted,
    required this.previousWeekTasksCompleted,
    required this.tasksCompletedDelta,
    required this.currentStreakDays,
    required this.activeDays14,
    required this.recentActivityCount,
    required this.topTaskCategory,
    required this.topExpenseCategory,
    required this.stage,
    required this.nextAction,
    required this.nextActionTargetTab,
    required this.milestones,
    required this.insights,
    required this.suggestions,
    required this.softUnlocks,
  });

  factory SoloProgressSnapshot.fromInputs({
    required int xp,
    required List<TaskModel> tasks,
    required List<TaskModel> todayTasks,
    required Map<String, dynamic>? financeSummary,
    required List<Map<String, dynamic>> recentActivities,
    required List<Map<String, dynamic>> taskStats,
    required List<Map<String, dynamic>> memberStats,
    required List<Map<String, dynamic>> xpHistory,
    Map<String, dynamic>? serverSnapshot,
  }) {
    final remote =
        serverSnapshot?['authorized'] == true ? serverSnapshot : null;
    final safeXp = math.max(0, _readInt(remote, 'xp') ?? xp);
    final level = (safeXp ~/ xpPerLevel) + 1;
    final xpInLevel = safeXp % xpPerLevel;
    final completedTasks = _readInt(remote, 'tasks_completed') ??
        _completedTasks(taskStats, memberStats);
    final activeTasks =
        tasks.where((task) => task.isActive && !task.isPendingApproval).length;
    final pendingToday = todayTasks
        .where((task) => task.isActive && !task.isPendingApproval)
        .length;
    final monthlyExpense = _readDouble(remote, 'monthly_expense') ??
        (financeSummary?['expense'] as num?)?.toDouble() ??
        0.0;
    final monthlyIncome = _readDouble(remote, 'monthly_income') ??
        (financeSummary?['income'] as num?)?.toDouble() ??
        0.0;
    final effectiveFinanceSummary = remote == null
        ? financeSummary
        : <String, dynamic>{
            ...?financeSummary,
            'expense': monthlyExpense,
            'income': monthlyIncome,
          };
    final recentCount = _readInt(remote, 'recent_activity_count') ??
        _recentActivityCount(recentActivities);
    final recentXp = _readInt(remote, 'weekly_xp') ?? _recentXp(xpHistory);
    final weeklyXp = _readInt(remote, 'weekly_xp') ?? recentXp;
    final previousWeekXp = _readInt(remote, 'previous_week_xp') ?? 0;
    final weeklyTasksCompleted =
        _readInt(remote, 'weekly_tasks_completed') ?? 0;
    final previousWeekTasksCompleted =
        _readInt(remote, 'previous_week_tasks_completed') ?? 0;
    final currentStreakDays = _readInt(remote, 'current_streak_days') ?? 0;
    final activeDays14 = _readInt(remote, 'active_days_14') ?? 0;

    final orderScore = _orderScore(
      activeTasks: activeTasks,
      pendingToday: pendingToday,
      completedTasks: completedTasks,
    );
    final clarityScore = _clarityScore(
      monthlyExpense: monthlyExpense,
      monthlyIncome: monthlyIncome,
      financeSummary: effectiveFinanceSummary,
    );
    final continuityScore = _continuityScore(
      xp: safeXp,
      recentCount: recentCount,
      recentXp: recentXp,
      completedTasks: completedTasks,
    );
    final averageScore =
        ((orderScore + clarityScore + continuityScore) / 3).round();
    final stage = _stageFor(level: level, averageScore: averageScore);
    final nextAction = _nextAction(
      activeTasks: activeTasks,
      pendingToday: pendingToday,
      monthlyExpense: monthlyExpense,
      recentCount: recentCount,
    );

    final weeklyXpDelta =
        _readInt(remote, 'weekly_xp_delta') ?? weeklyXp - previousWeekXp;
    final tasksCompletedDelta = _readInt(remote, 'tasks_completed_delta') ??
        weeklyTasksCompleted - previousWeekTasksCompleted;
    final topTaskCategory = _readString(remote, 'top_task_category');
    final topExpenseCategory = _readString(remote, 'top_expense_category');
    final milestones = _milestones(
      level: level,
      completedTasks: completedTasks,
      recentCount: recentCount,
      recentXp: recentXp,
      currentStreakDays: currentStreakDays,
      activeDays14: activeDays14,
      clarityScore: clarityScore,
      orderScore: orderScore,
      continuityScore: continuityScore,
    );

    return SoloProgressSnapshot(
      level: level,
      xp: safeXp,
      xpInLevel: xpInLevel,
      xpToNextLevel: xpPerLevel - xpInLevel,
      levelProgress: xpInLevel / xpPerLevel,
      orderScore: orderScore,
      clarityScore: clarityScore,
      continuityScore: continuityScore,
      stage: stage,
      nextAction: nextAction,
      nextActionTargetTab: _targetFor(nextAction),
      hasServerSnapshot: remote != null,
      weeklyXp: weeklyXp,
      previousWeekXp: previousWeekXp,
      weeklyXpDelta: weeklyXpDelta,
      weeklyTasksCompleted: weeklyTasksCompleted,
      previousWeekTasksCompleted: previousWeekTasksCompleted,
      tasksCompletedDelta: tasksCompletedDelta,
      currentStreakDays: currentStreakDays,
      activeDays14: activeDays14,
      recentActivityCount: recentCount,
      topTaskCategory: topTaskCategory,
      topExpenseCategory: topExpenseCategory,
      milestones: milestones,
      insights: _insights(
        weeklyXpDelta: weeklyXpDelta,
        tasksCompletedDelta: tasksCompletedDelta,
        currentStreakDays: currentStreakDays,
        weeklyTasksCompleted: weeklyTasksCompleted,
        monthlyExpense: monthlyExpense,
        recentCount: recentCount,
        topTaskCategory: topTaskCategory,
        topExpenseCategory: topExpenseCategory,
      ),
      suggestions: _suggestions(
        activeTasks: activeTasks,
        pendingToday: pendingToday,
        monthlyExpense: monthlyExpense,
        currentStreakDays: currentStreakDays,
        weeklyTasksCompleted: weeklyTasksCompleted,
        recentCount: recentCount,
      ),
      softUnlocks: _softUnlocks(
        level: level,
        milestones: milestones,
        currentStreakDays: currentStreakDays,
        activeDays14: activeDays14,
        clarityScore: clarityScore,
      ),
    );
  }

  static int? _readInt(Map<String, dynamic>? source, String key) {
    final value = source?[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _readDouble(Map<String, dynamic>? source, String key) {
    final value = source?[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? _readString(Map<String, dynamic>? source, String key) {
    final value = source?[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  String stageName(AppLocalizations t) {
    return switch (stage) {
      SoloProgressStage.recentMove => t.soloSpaceStageRecentMove,
      SoloProgressStage.inMotion => t.soloSpaceStageInMotion,
      SoloProgressStage.steadyRoutine => t.soloSpaceStageSteadyRoutine,
      SoloProgressStage.organizedHome => t.soloSpaceStageOrganizedHome,
      SoloProgressStage.ownRhythm => t.soloSpaceStageOwnRhythm,
    };
  }

  String stageSubtitle(AppLocalizations t) {
    return switch (stage) {
      SoloProgressStage.recentMove => t.soloSpaceStageRecentMoveSubtitle,
      SoloProgressStage.inMotion => t.soloSpaceStageInMotionSubtitle,
      SoloProgressStage.steadyRoutine => t.soloSpaceStageSteadyRoutineSubtitle,
      SoloProgressStage.organizedHome => t.soloSpaceStageOrganizedHomeSubtitle,
      SoloProgressStage.ownRhythm => t.soloSpaceStageOwnRhythmSubtitle,
    };
  }

  String nextActionTitle(AppLocalizations t) {
    return switch (nextAction) {
      SoloProgressNextAction.createTask => t.soloSpaceNextCreateTask,
      SoloProgressNextAction.completeTask => t.soloSpaceNextCompleteTask,
      SoloProgressNextAction.registerExpense => t.soloSpaceNextRegisterExpense,
      SoloProgressNextAction.reviewShopping => t.soloSpaceNextReviewShopping,
      SoloProgressNextAction.keepGoing => t.soloSpaceNextKeepGoing,
    };
  }

  String nextActionSubtitle(AppLocalizations t) {
    return switch (nextAction) {
      SoloProgressNextAction.createTask => t.soloSpaceNextCreateTaskSubtitle,
      SoloProgressNextAction.completeTask =>
        t.soloSpaceNextCompleteTaskSubtitle,
      SoloProgressNextAction.registerExpense =>
        t.soloSpaceNextRegisterExpenseSubtitle,
      SoloProgressNextAction.reviewShopping =>
        t.soloSpaceNextReviewShoppingSubtitle,
      SoloProgressNextAction.keepGoing => t.soloSpaceNextKeepGoingSubtitle,
    };
  }

  static int _completedTasks(
    List<Map<String, dynamic>> taskStats,
    List<Map<String, dynamic>> memberStats,
  ) {
    final byCategory = taskStats.fold<int>(
      0,
      (sum, item) => sum + ((item['completed_count'] as num?)?.toInt() ?? 0),
    );
    if (byCategory > 0) return byCategory;

    return memberStats.fold<int>(
      0,
      (sum, item) => sum + ((item['tasks_completed'] as num?)?.toInt() ?? 0),
    );
  }

  static int _recentActivityCount(List<Map<String, dynamic>> activities) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return activities.where((activity) {
      final createdAt = DateTime.tryParse(
        activity['created_at']?.toString() ?? '',
      );
      return createdAt != null && createdAt.isAfter(cutoff);
    }).length;
  }

  static int _recentXp(List<Map<String, dynamic>> xpHistory) {
    return xpHistory.take(7).fold<int>(
          0,
          (sum, item) => sum + ((item['amount'] as num?)?.toInt() ?? 0),
        );
  }

  static int _orderScore({
    required int activeTasks,
    required int pendingToday,
    required int completedTasks,
  }) {
    if (activeTasks == 0 && completedTasks == 0) return 12;
    final base = activeTasks == 0 ? 28 : 42;
    final completionLift = math.min(completedTasks * 5, 38);
    final clearDayBonus = activeTasks > 0 && pendingToday == 0 ? 18 : 0;
    final pendingDrag = math.min(pendingToday * 7, 28);
    return (base + completionLift + clearDayBonus - pendingDrag)
        .clamp(8, 96)
        .toInt();
  }

  static int _clarityScore({
    required double monthlyExpense,
    required double monthlyIncome,
    required Map<String, dynamic>? financeSummary,
  }) {
    if (financeSummary == null || financeSummary.isEmpty) return 10;
    var score = 18;
    if (monthlyExpense > 0) score += 42;
    if (monthlyIncome > 0) score += 20;
    final variation = (financeSummary['variation'] as num?)?.abs() ?? 0;
    if (variation > 0) score += 8;
    final balance = (financeSummary['balance'] as num?)?.abs() ?? 0;
    if (balance > 0) score += 6;
    return score.clamp(10, 96).toInt();
  }

  static int _continuityScore({
    required int xp,
    required int recentCount,
    required int recentXp,
    required int completedTasks,
  }) {
    final score = 12 +
        math.min(xp ~/ 80, 28) +
        math.min(recentCount * 9, 32) +
        math.min(recentXp ~/ 8, 16) +
        math.min(completedTasks * 2, 10);
    return score.clamp(10, 96).toInt();
  }

  static SoloProgressStage _stageFor({
    required int level,
    required int averageScore,
  }) {
    if (level >= 9 || averageScore >= 86) return SoloProgressStage.ownRhythm;
    if (level >= 6 || averageScore >= 72) {
      return SoloProgressStage.organizedHome;
    }
    if (level >= 3 || averageScore >= 54) {
      return SoloProgressStage.steadyRoutine;
    }
    if (level >= 2 || averageScore >= 32) return SoloProgressStage.inMotion;
    return SoloProgressStage.recentMove;
  }

  static SoloProgressNextAction _nextAction({
    required int activeTasks,
    required int pendingToday,
    required double monthlyExpense,
    required int recentCount,
  }) {
    if (pendingToday > 0) return SoloProgressNextAction.completeTask;
    if (activeTasks == 0) return SoloProgressNextAction.createTask;
    if (monthlyExpense <= 0) return SoloProgressNextAction.registerExpense;
    if (recentCount < 2) return SoloProgressNextAction.keepGoing;
    return SoloProgressNextAction.reviewShopping;
  }

  static MainTab _targetFor(SoloProgressNextAction action) {
    return switch (action) {
      SoloProgressNextAction.createTask => MainTab.tasks,
      SoloProgressNextAction.completeTask => MainTab.tasks,
      SoloProgressNextAction.registerExpense => MainTab.expenses,
      SoloProgressNextAction.reviewShopping => MainTab.shopping,
      SoloProgressNextAction.keepGoing => MainTab.tasks,
    };
  }

  static List<SoloProgressMilestone> _milestones({
    required int level,
    required int completedTasks,
    required int recentCount,
    required int recentXp,
    required int currentStreakDays,
    required int activeDays14,
    required int clarityScore,
    required int orderScore,
    required int continuityScore,
  }) {
    final items = <SoloProgressMilestone>[];
    if (completedTasks >= 1) items.add(SoloProgressMilestone.firstStep);
    if (recentCount >= 3 ||
        recentXp >= 50 ||
        currentStreakDays >= 3 ||
        activeDays14 >= 3) {
      items.add(SoloProgressMilestone.weekInMotion);
    }
    if (clarityScore >= 60) items.add(SoloProgressMilestone.clearerHome);
    if (orderScore >= 70 && continuityScore >= 50) {
      items.add(SoloProgressMilestone.steadyRoutine);
    }
    if (level >= 5) items.add(SoloProgressMilestone.ownRhythm);
    return items;
  }

  static List<SoloEvolutionInsight> _insights({
    required int weeklyXpDelta,
    required int tasksCompletedDelta,
    required int currentStreakDays,
    required int weeklyTasksCompleted,
    required double monthlyExpense,
    required int recentCount,
    required String? topTaskCategory,
    required String? topExpenseCategory,
  }) {
    final items = <SoloEvolutionInsight>[];
    if (recentCount == 0 && weeklyTasksCompleted == 0 && monthlyExpense == 0) {
      items.add(SoloEvolutionInsight.noActivityYet);
    }
    if (currentStreakDays >= 3) {
      items.add(SoloEvolutionInsight.streakBuilding);
    }
    if (weeklyXpDelta > 0 || tasksCompletedDelta > 0) {
      items.add(SoloEvolutionInsight.weekImproved);
    } else if (weeklyXpDelta < 0 && tasksCompletedDelta < 0) {
      items.add(SoloEvolutionInsight.weekSlowedDown);
    }
    if (monthlyExpense > 0) {
      items.add(SoloEvolutionInsight.financeVisible);
    } else {
      items.add(SoloEvolutionInsight.noFinanceYet);
    }
    if (topTaskCategory != null) {
      items.add(SoloEvolutionInsight.strongTaskCategory);
    }
    if (topExpenseCategory != null) {
      items.add(SoloEvolutionInsight.strongExpenseCategory);
    }
    return items.take(3).toList(growable: false);
  }

  static List<SoloEvolutionSuggestion> _suggestions({
    required int activeTasks,
    required int pendingToday,
    required double monthlyExpense,
    required int currentStreakDays,
    required int weeklyTasksCompleted,
    required int recentCount,
  }) {
    final items = <SoloEvolutionSuggestion>[];
    if (pendingToday > 0) items.add(SoloEvolutionSuggestion.closePending);
    if (activeTasks == 0 || weeklyTasksCompleted >= 3) {
      items.add(SoloEvolutionSuggestion.createRecurringTask);
    }
    if (monthlyExpense <= 0) items.add(SoloEvolutionSuggestion.registerExpense);
    if (currentStreakDays >= 2) {
      items.add(SoloEvolutionSuggestion.protectStreak);
    }
    if (recentCount >= 2) items.add(SoloEvolutionSuggestion.reviewShopping);
    items.add(SoloEvolutionSuggestion.runWeeklyReview);
    return items.toSet().take(3).toList(growable: false);
  }

  static List<SoloSoftUnlock> _softUnlocks({
    required int level,
    required List<SoloProgressMilestone> milestones,
    required int currentStreakDays,
    required int activeDays14,
    required int clarityScore,
  }) {
    final items = <SoloSoftUnlock>[SoloSoftUnlock.weeklyReview];
    if (level >= 2 || milestones.contains(SoloProgressMilestone.firstStep)) {
      items.add(SoloSoftUnlock.recurringTemplates);
    }
    if (activeDays14 >= 3 || currentStreakDays >= 3) {
      items.add(SoloSoftUnlock.habitInsights);
    }
    if (milestones.length >= 3 || level >= 4) {
      items.add(SoloSoftUnlock.personalMedal);
    }
    if (clarityScore >= 60 && level >= 3) {
      items.add(SoloSoftUnlock.rhythmRecommendations);
    }
    return items;
  }
}

extension SoloProgressMilestoneL10n on SoloProgressMilestone {
  String title(AppLocalizations t) {
    return switch (this) {
      SoloProgressMilestone.firstStep => t.soloSpaceMilestoneFirstStep,
      SoloProgressMilestone.weekInMotion => t.soloSpaceMilestoneWeekInMotion,
      SoloProgressMilestone.clearerHome => t.soloSpaceMilestoneClearerHome,
      SoloProgressMilestone.steadyRoutine => t.soloSpaceMilestoneSteadyRoutine,
      SoloProgressMilestone.ownRhythm => t.soloSpaceMilestoneOwnRhythm,
    };
  }

  String description(AppLocalizations t) {
    return switch (this) {
      SoloProgressMilestone.firstStep => t.soloSpaceMilestoneFirstStepDesc,
      SoloProgressMilestone.weekInMotion =>
        t.soloSpaceMilestoneWeekInMotionDesc,
      SoloProgressMilestone.clearerHome => t.soloSpaceMilestoneClearerHomeDesc,
      SoloProgressMilestone.steadyRoutine =>
        t.soloSpaceMilestoneSteadyRoutineDesc,
      SoloProgressMilestone.ownRhythm => t.soloSpaceMilestoneOwnRhythmDesc,
    };
  }
}

extension SoloWeeklyRitualStepL10n on SoloWeeklyRitualStep {
  String title(AppLocalizations t) {
    return switch (this) {
      SoloWeeklyRitualStep.reviewTasks => t.soloSpaceRitualReviewTasks,
      SoloWeeklyRitualStep.checkSpending => t.soloSpaceRitualCheckSpending,
      SoloWeeklyRitualStep.planShopping => t.soloSpaceRitualPlanShopping,
      SoloWeeklyRitualStep.chooseNextRoutine =>
        t.soloSpaceRitualChooseNextRoutine,
    };
  }
}

extension SoloEvolutionInsightL10n on SoloEvolutionInsight {
  String title(AppLocalizations t) {
    return switch (this) {
      SoloEvolutionInsight.noActivityYet => t.soloSpaceInsightNoActivity,
      SoloEvolutionInsight.streakBuilding => t.soloSpaceInsightStreak,
      SoloEvolutionInsight.weekImproved => t.soloSpaceInsightWeekImproved,
      SoloEvolutionInsight.weekSlowedDown => t.soloSpaceInsightWeekSlowed,
      SoloEvolutionInsight.financeVisible => t.soloSpaceInsightFinanceVisible,
      SoloEvolutionInsight.noFinanceYet => t.soloSpaceInsightNoFinance,
      SoloEvolutionInsight.strongTaskCategory => t.soloSpaceInsightTaskCategory,
      SoloEvolutionInsight.strongExpenseCategory =>
        t.soloSpaceInsightExpenseCategory,
    };
  }

  String description(AppLocalizations t, SoloProgressSnapshot snapshot) {
    return switch (this) {
      SoloEvolutionInsight.noActivityYet => t.soloSpaceInsightNoActivityDesc,
      SoloEvolutionInsight.streakBuilding =>
        t.soloSpaceInsightStreakDesc(snapshot.currentStreakDays),
      SoloEvolutionInsight.weekImproved =>
        t.soloSpaceInsightWeekImprovedDesc(snapshot.weeklyXpDelta),
      SoloEvolutionInsight.weekSlowedDown => t.soloSpaceInsightWeekSlowedDesc,
      SoloEvolutionInsight.financeVisible =>
        t.soloSpaceInsightFinanceVisibleDesc,
      SoloEvolutionInsight.noFinanceYet => t.soloSpaceInsightNoFinanceDesc,
      SoloEvolutionInsight.strongTaskCategory =>
        t.soloSpaceInsightTaskCategoryDesc(snapshot.topTaskCategory ?? ''),
      SoloEvolutionInsight.strongExpenseCategory =>
        t.soloSpaceInsightExpenseCategoryDesc(
          snapshot.topExpenseCategory ?? '',
        ),
    };
  }
}

extension SoloEvolutionSuggestionL10n on SoloEvolutionSuggestion {
  MainTab get targetTab {
    return switch (this) {
      SoloEvolutionSuggestion.createRecurringTask => MainTab.tasks,
      SoloEvolutionSuggestion.closePending => MainTab.tasks,
      SoloEvolutionSuggestion.registerExpense => MainTab.expenses,
      SoloEvolutionSuggestion.reviewShopping => MainTab.shopping,
      SoloEvolutionSuggestion.protectStreak => MainTab.tasks,
      SoloEvolutionSuggestion.runWeeklyReview => MainTab.social,
    };
  }

  String title(AppLocalizations t) {
    return switch (this) {
      SoloEvolutionSuggestion.createRecurringTask =>
        t.soloSpaceSuggestionRecurringTask,
      SoloEvolutionSuggestion.closePending => t.soloSpaceSuggestionClosePending,
      SoloEvolutionSuggestion.registerExpense =>
        t.soloSpaceSuggestionRegisterExpense,
      SoloEvolutionSuggestion.reviewShopping =>
        t.soloSpaceSuggestionReviewShopping,
      SoloEvolutionSuggestion.protectStreak =>
        t.soloSpaceSuggestionProtectStreak,
      SoloEvolutionSuggestion.runWeeklyReview =>
        t.soloSpaceSuggestionWeeklyReview,
    };
  }

  String description(AppLocalizations t) {
    return switch (this) {
      SoloEvolutionSuggestion.createRecurringTask =>
        t.soloSpaceSuggestionRecurringTaskDesc,
      SoloEvolutionSuggestion.closePending =>
        t.soloSpaceSuggestionClosePendingDesc,
      SoloEvolutionSuggestion.registerExpense =>
        t.soloSpaceSuggestionRegisterExpenseDesc,
      SoloEvolutionSuggestion.reviewShopping =>
        t.soloSpaceSuggestionReviewShoppingDesc,
      SoloEvolutionSuggestion.protectStreak =>
        t.soloSpaceSuggestionProtectStreakDesc,
      SoloEvolutionSuggestion.runWeeklyReview =>
        t.soloSpaceSuggestionWeeklyReviewDesc,
    };
  }
}

extension SoloSoftUnlockL10n on SoloSoftUnlock {
  String title(AppLocalizations t) {
    return switch (this) {
      SoloSoftUnlock.weeklyReview => t.soloSpaceUnlockWeeklyReview,
      SoloSoftUnlock.recurringTemplates => t.soloSpaceUnlockRecurringTemplates,
      SoloSoftUnlock.habitInsights => t.soloSpaceUnlockHabitInsights,
      SoloSoftUnlock.personalMedal => t.soloSpaceUnlockPersonalMedal,
      SoloSoftUnlock.rhythmRecommendations =>
        t.soloSpaceUnlockRhythmRecommendations,
    };
  }

  String description(AppLocalizations t) {
    return switch (this) {
      SoloSoftUnlock.weeklyReview => t.soloSpaceUnlockWeeklyReviewDesc,
      SoloSoftUnlock.recurringTemplates =>
        t.soloSpaceUnlockRecurringTemplatesDesc,
      SoloSoftUnlock.habitInsights => t.soloSpaceUnlockHabitInsightsDesc,
      SoloSoftUnlock.personalMedal => t.soloSpaceUnlockPersonalMedalDesc,
      SoloSoftUnlock.rhythmRecommendations =>
        t.soloSpaceUnlockRhythmRecommendationsDesc,
    };
  }
}
