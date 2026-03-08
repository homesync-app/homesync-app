import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import '../../domain/models/savings_model.dart';
import '../../domain/repositories/savings_repository.dart';
import '../../domain/usecases/get_savings_goals_usecase.dart';
import '../../domain/usecases/get_goal_contributions_usecase.dart';
import '../../domain/usecases/create_savings_goal_usecase.dart';
import '../../domain/usecases/add_contribution_usecase.dart';
import '../../domain/usecases/delete_savings_goal_usecase.dart';
import '../../data/repositories/supabase_savings_repository.dart';

part 'savings_provider.g.dart';

@riverpod
SavingsRepository savingsRepository(SavingsRepositoryRef ref) {
  return SupabaseSavingsRepository();
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
  return await getGoalContributions.execute(goalId);
}

@riverpod
class SavingsGoals extends _$SavingsGoals {
  @override
  Future<List<SavingsGoalModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];
    
    final getSavingsGoals = ref.watch(getSavingsGoalsUseCaseProvider);
    return await getSavingsGoals.execute(householdId);
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
      return await getSavingsGoals.execute(householdId);
    });
  }

  Future<void> contribute(String goalId, double amount, {String? note}) async {
    final userId = ref.read(currentUserIdProvider);
    final householdId = await ref.read(householdIdProvider.future);
    if (userId == null || householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addContributionUseCaseProvider).execute(
        goalId: goalId,
        userId: userId,
        amount: amount,
        note: note,
      );
      
      ref.invalidate(goalContributionsProvider(goalId));
      ref.invalidate(personalFinanceSummaryProvider); // This affects balance
      
      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      return await getSavingsGoals.execute(householdId);
    });
  }

  Future<void> removeGoal(String goalId) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteSavingsGoalUseCaseProvider).execute(goalId);
      final getSavingsGoals = ref.read(getSavingsGoalsUseCaseProvider);
      return await getSavingsGoals.execute(householdId);
    });
  }
}
