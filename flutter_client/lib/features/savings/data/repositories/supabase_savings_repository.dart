import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/repository_error_handler.dart';
import '../../domain/models/savings_model.dart';
import '../../domain/repositories/savings_repository.dart';

class SupabaseSavingsRepository
    with RepositoryErrorHandler
    implements SavingsRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final Ref _ref;

  SupabaseSavingsRepository({required Ref ref}) : _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  @override
  Future<Either<Failure, List<SavingsGoalModel>>> getGoals(
      {required String householdId}) async {
    return executeWithHandling(() async {
      final response = await _client
          .from('savings_goals')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SavingsGoalModel.fromJson(json))
          .toList();
    }, context: 'SupabaseSavingsRepository.getGoals', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<SavingsContributionModel>>> getGoalContributions(
      {required String goalId}) async {
    return executeWithHandling(() async {
      final response = await _client
          .from('savings_contributions')
          .select('*, user:users!user_id(full_name, avatar_url)')
          .eq('goal_id', goalId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SavingsContributionModel.fromJson(json))
          .toList();
    }, context: 'SupabaseSavingsRepository.getGoalContributions', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  }) async {
    return executeWithHandling(() async {
      await _client.from('savings_goals').insert({
        'household_id': householdId,
        'title': title,
        'target_amount': targetAmount,
        'color': color,
        'icon': icon,
      });
    }, context: 'SupabaseSavingsRepository.createGoal', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  }) async {
    return executeWithHandling(() async {
      await _client.from('savings_contributions').insert({
        'goal_id': goalId,
        'user_id': userId,
        'amount': amount,
        'note': note,
      });
    }, context: 'SupabaseSavingsRepository.addContribution', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> deleteGoal({required String goalId}) async {
    return executeWithHandling(() async {
      await _client.from('savings_goals').delete().eq('id', goalId);
    }, context: 'SupabaseSavingsRepository.deleteGoal', isOnline: _isOnline);
  }
}
