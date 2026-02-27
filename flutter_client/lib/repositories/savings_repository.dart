import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/savings_goal.dart';

class SavingsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SavingsGoal>> getGoals() async {
    final response = await _client
        .from('savings_goals')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => SavingsGoal.fromJson(json)).toList();
  }

  Future<void> createGoal(SavingsGoal goal) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // Get household_id first
    final memberInfo = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .single();
    
    final householdId = memberInfo['household_id'];

    await _client.from('savings_goals').insert({
      'household_id': householdId,
      'title': goal.title,
      'target_amount': goal.targetAmount,
      'color': goal.color,
      'icon': goal.icon,
    });
  }

  Future<void> addContribution(String goalId, double amount, {String? note}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('savings_contributions').insert({
      'goal_id': goalId,
      'user_id': user.id,
      'amount': amount,
      'note': note,
    });
  }

  Future<void> deleteGoal(String goalId) async {
    await _client.from('savings_goals').delete().eq('id', goalId);
  }
}
