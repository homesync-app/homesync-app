import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';
import 'package:homesync_client/features/savings/data/repositories/supabase_savings_repository.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

final savingsRepositoryProvider =
    Provider<SavingsRepository>((ref) => SupabaseSavingsRepository(ref: ref));

final goalContributionsProvider =
    FutureProvider.family<List<SavingsContributionModel>, String>(
        (ref, goalId) async {
  final repo = ref.watch(savingsRepositoryProvider);
  final result = await repo.getGoalContributions(goalId: goalId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (contributions) => contributions,
  );
});

final savingsGoalsProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoalModel>>(() {
  return SavingsGoalsNotifier();
});

class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoalModel>> {
  @override
  Future<List<SavingsGoalModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];
    
    final result = await ref
        .watch(savingsRepositoryProvider)
        .getGoals(householdId: householdId);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (goals) => goals,
    );
  }

  Future<void> addGoal(
      String title, double targetAmount, String color, String icon) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) throw Exception('Household Id needed');

      final createResult = await ref.read(savingsRepositoryProvider).createGoal(
            householdId: householdId,
            title: title,
            targetAmount: targetAmount,
            color: color,
            icon: icon,
          );
      
      return createResult.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          final goalsResult = await ref
              .read(savingsRepositoryProvider)
              .getGoals(householdId: householdId);
          return goalsResult.fold(
            (f) => throw Exception(f.message),
            (goals) => goals,
          );
        },
      );
    });
  }

  Future<void> contribute(String goalId, double amount, {String? note}) async {
    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      final householdId = await ref.read(householdIdProvider.future);
      if (userId == null || householdId == null) throw Exception('Auth needed');

      final contributeResult = await ref.read(savingsRepositoryProvider).addContribution(
          goalId: goalId, userId: userId, amount: amount, note: note);
      
      return contributeResult.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          ref.invalidate(goalContributionsProvider(goalId));
          final goalsResult = await ref
              .read(savingsRepositoryProvider)
              .getGoals(householdId: householdId);
          return goalsResult.fold(
            (f) => throw Exception(f.message),
            (goals) => goals,
          );
        },
      );
    });
  }

  Future<void> removeGoal(String goalId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) throw Exception('Household Id needed');
      
      final deleteResult = await ref.read(savingsRepositoryProvider).deleteGoal(goalId: goalId);
      
      return deleteResult.fold(
        (failure) => throw Exception(failure.message),
        (_) async {
          final goalsResult = await ref
              .read(savingsRepositoryProvider)
              .getGoals(householdId: householdId);
          return goalsResult.fold(
            (f) => throw Exception(f.message),
            (goals) => goals,
          );
        },
      );
    });
  }
}
