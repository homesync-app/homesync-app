import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';
import 'package:homesync_client/features/savings/domain/usecases/get_savings_goals_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/get_goal_contributions_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/create_savings_goal_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/add_contribution_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/delete_savings_goal_usecase.dart';
import 'package:homesync_client/features/savings/data/repositories/supabase_savings_repository.dart';

part 'savings_provider.g.dart';

@riverpod
SavingsRepository savingsRepository(SavingsRepositoryRef ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSavingsRepository(client: client, ref: ref);
}

@riverpod
GetSavingsGoalsUseCase getSavingsGoalsUseCase(GetSavingsGoalsUseCaseRef ref) {
  return GetSavingsGoalsUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
GetGoalContributionsUseCase getGoalContributionsUseCase(GetGoalContributionsUseCaseRef ref) {
  return GetGoalContributionsUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
CreateSavingsGoalUseCase createSavingsGoalUseCase(CreateSavingsGoalUseCaseRef ref) {
  return CreateSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
AddContributionUseCase addContributionUseCase(AddContributionUseCaseRef ref) {
  return AddContributionUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
DeleteSavingsGoalUseCase deleteSavingsGoalUseCase(DeleteSavingsGoalUseCaseRef ref) {
  return DeleteSavingsGoalUseCase(ref.watch(savingsRepositoryProvider));
}

@riverpod
Future<List<SavingsContributionModel>> goalContributions(GoalContributionsRef ref, String goalId) async {
  final getGoalContributions = ref.watch(getGoalContributionsUseCaseProvider);
  final result = await getGoalContributions.execute(goalId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (items) => items,
  );
}

@riverpod
class SavingsGoals extends _$SavingsGoals {
  @override
  Future<List<SavingsGoalModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];
    
    final getSavingsGoals = ref.watch(getSavingsGoalsUseCaseProvider);
    final result = await getSavingsGoals.execute(householdId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (goals) => goals,
    );
  }

  Future<void> addGoal(String title, double targetAmount, String color, String icon) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(createSavingsGoalUseCaseProvider).execute(
        householdId: householdId,
        title: title,
        targetAmount: targetAmount,
        color: color,
        icon: icon,
      );
      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (goals) => goals,
      );
    });
  }

  Future<void> contribute(String goalId, double amount, {String? note, required String goalTitle}) async {
    final userId = ref.read(currentUserIdProvider);
    final householdId = await ref.read(householdIdProvider.future);
    if (userId == null || householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Add the contribution to the savings goal
      await ref.read(addContributionUseCaseProvider).execute(
        goalId: goalId,
        userId: userId,
        amount: amount,
        note: note,
      );

      // 2. Create a corresponding PERSONAL expense to reflect in global balance
      try {
        final expenseRepo = ref.read(expenseRepositoryProvider);
        await expenseRepo.saveExpense(
          householdId: householdId,
          title: 'Ahorro: $goalTitle',
          amount: amount,
          category: 'finanzas',
          paidBy: userId,
          paidAt: DateTime.now(),
          description: note ?? 'Aportación a meta de ahorro',
          splitType: SplitType.personal,
          type: 'expense',
        );
      } catch (e) {
        // Log error but don't fail the whole operation if ledger failed
        debugPrint('Error creating expense for contribution: $e');
      }
      
      ref.invalidate(goalContributionsProvider(goalId));
      ref.invalidate(personalFinanceSummaryProvider); 
      ref.invalidate(expenseControllerProvider);
      
      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (goals) => goals,
      );
    });
  }

  Future<void> removeGoal(String goalId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteSavingsGoalUseCaseProvider).execute(goalId);
      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      final result = await getSavingsGoals.execute(householdId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (goals) => goals,
      );
    });
  }
}

class SavingsSuggestion {
  final String message;
  final SavingsGoalModel? goal;
  final double surplus;
  
  SavingsSuggestion({required this.message, this.goal, required this.surplus});
}

@riverpod
Future<SavingsSuggestion?> savingsSuggester(SavingsSuggesterRef ref) async {
  final summary = await ref.watch(personalFinanceSummaryProvider.future);
  final projection = await ref.watch(monthlyProjectionProvider.future);
  final goals = await ref.watch(savingsGoalsProvider.future);
  
  if (goals.isEmpty) return null;
  
  final income = (summary['income'] as num?)?.toDouble() ?? 0.0;
  final totalExpectedSpend = projection.total;
  
  // If income is not registered, we can't calculate surplus accurately
  if (income <= 0) return null;
  
  final surplus = income - totalExpectedSpend;
  
  if (surplus > 1000) { // Only suggest if surplus is relevant (e.g. > $1000 ARS)
    // Find the goal with the highest progress but not yet completed
    final eligibleGoals = goals.where((g) => g.currentAmount < g.targetAmount).toList();
    if (eligibleGoals.isEmpty) return null;
    
    eligibleGoals.sort((a, b) => b.progress.compareTo(a.progress));
    final targetGoal = eligibleGoals.first;
    
    final percentageBoost = (surplus / targetGoal.targetAmount) * 100;
    
    return SavingsSuggestion(
      message: 'Basado en tu plan, podrías ahorrar \$${surplus.toStringAsFixed(0)} extra este mes. ¡Eso adelantaría un ${percentageBoost.toStringAsFixed(1)}% tu meta de "${targetGoal.title}"!',
      goal: targetGoal,
      surplus: surplus,
    );
  }
  
  return null;
}
