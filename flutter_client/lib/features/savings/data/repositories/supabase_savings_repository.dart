import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/savings_model.dart';
import '../../domain/repositories/savings_repository.dart';

class SupabaseSavingsRepository implements SavingsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<SavingsGoalModel>> getGoals({required String householdId}) async {
    try {
      final response = await _client
          .from('savings_goals')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);
          
      return (response as List).map((json) => SavingsGoalModel.fromJson(json)).toList();
    } catch (e) {
      dev.log('Error getting goals: $e');
      return [];
    }
  }

  @override
  Future<List<SavingsContributionModel>> getGoalContributions({required String goalId}) async {
    try {
      final response = await _client
          .from('savings_contributions')
          .select('*, user:users!user_id(full_name, avatar_url)')
          .eq('goal_id', goalId)
          .order('created_at', ascending: false);
          
      return (response as List).map((json) => SavingsContributionModel.fromJson(json)).toList();
    } catch (e) {
      dev.log('Error loading contributions: $e');
      return [];
    }
  }

  @override
  Future<void> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  }) async {
    await _client.from('savings_goals').insert({
      'household_id': householdId,
      'title': title,
      'target_amount': targetAmount,
      'color': color,
      'icon': icon,
    });
  }

  @override
  Future<void> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  }) async {
    await _client.from('savings_contributions').insert({
      'goal_id': goalId,
      'user_id': userId,
      'amount': amount,
      'note': note,
    });
  }

  @override
  Future<void> deleteGoal({required String goalId}) async {
    await _client.from('savings_goals').delete().eq('id', goalId);
  }
}
