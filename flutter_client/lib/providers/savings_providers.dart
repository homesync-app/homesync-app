import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/savings_goal.dart';
import '../repositories/savings_repository.dart';

final savingsRepositoryProvider = Provider((ref) => SavingsRepository());

final goalContributionsProvider = FutureProvider.family<List<SavingsContribution>, String>((ref, goalId) async {
  final client = Supabase.instance.client;
  final response = await client
      .from('savings_contributions')
      .select('*, user:users(full_name, avatar_url)')
      .eq('goal_id', goalId)
      .order('created_at', ascending: false);
  
  return (response as List).map((json) => SavingsContribution.fromJson(json)).toList();
});

final savingsGoalsProvider = AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoal>>(() {
  return SavingsGoalsNotifier();
});

class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoal>> {
  @override
  Future<List<SavingsGoal>> build() async {
    return ref.watch(savingsRepositoryProvider).getGoals();
  }

  Future<void> addGoal(String title, double targetAmount, String color, String icon) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final goal = SavingsGoal(
        id: '',
        householdId: '',
        title: title,
        targetAmount: targetAmount,
        color: color,
        icon: icon,
        createdAt: DateTime.now(),
      );
      await ref.read(savingsRepositoryProvider).createGoal(goal);
      return ref.read(savingsRepositoryProvider).getGoals();
    });
  }

  Future<void> contribute(String goalId, double amount, {String? note}) async {
    state = await AsyncValue.guard(() async {
      await ref.read(savingsRepositoryProvider).addContribution(goalId, amount, note: note);
      ref.invalidate(goalContributionsProvider(goalId));
      return ref.read(savingsRepositoryProvider).getGoals();
    });
  }

  Future<void> removeGoal(String goalId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(savingsRepositoryProvider).deleteGoal(goalId);
      return ref.read(savingsRepositoryProvider).getGoals();
    });
  }
}
