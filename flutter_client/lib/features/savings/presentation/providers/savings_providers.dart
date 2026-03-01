import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';
import 'package:homesync_client/features/savings/data/repositories/supabase_savings_repository.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) => SupabaseSavingsRepository());

final goalContributionsProvider = FutureProvider.family<List<SavingsContributionModel>, String>((ref, goalId) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('savings_contributions')
      .select('*, user:users(full_name, avatar_url)')
      .eq('goal_id', goalId)
      .order('created_at', ascending: false);
  
  return (response as List).map((json) => SavingsContributionModel.fromJson(json)).toList();
});

final savingsGoalsProvider = AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoalModel>>(() {
  return SavingsGoalsNotifier();
});

class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoalModel>> {
  Future<List<SavingsGoalModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];
    return ref.watch(savingsRepositoryProvider).getGoals(householdId: householdId);
  }

  Future<void> addGoal(String title, double targetAmount, String color, String icon) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) throw Exception('Household Id needed');
      
      await ref.read(savingsRepositoryProvider).createGoal(
        householdId: householdId,
        title: title,
        targetAmount: targetAmount,
        color: color,
        icon: icon,
      );
      return ref.read(savingsRepositoryProvider).getGoals(householdId: householdId);
    });
  }

  Future<void> contribute(String goalId, double amount, {String? note}) async {
    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      final householdId = await ref.read(householdIdProvider.future);
      if (userId == null || householdId == null) throw Exception('Auth needed');
      
      await ref.read(savingsRepositoryProvider).addContribution(
        goalId: goalId, 
        userId: userId,
        amount: amount, 
        note: note
      );
      ref.invalidate(goalContributionsProvider(goalId));
      return ref.read(savingsRepositoryProvider).getGoals(householdId: householdId);
    });
  }

  Future<void> removeGoal(String goalId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) throw Exception('Household Id needed');
      await ref.read(savingsRepositoryProvider).deleteGoal(goalId: goalId);
      return ref.read(savingsRepositoryProvider).getGoals(householdId: householdId);
    });
  }
}
