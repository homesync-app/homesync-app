import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/offline/offline_action.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/repository_error_handler.dart';
import '../../domain/models/savings_model.dart';
import '../../domain/repositories/savings_repository.dart';

class SupabaseSavingsRepository
    with RepositoryErrorHandler
    implements SavingsRepository {
  final SupabaseClient _client;
  final Ref _ref;
  final OfflineQueueService _offlineQueue = OfflineQueueService();

  SupabaseSavingsRepository({
    required SupabaseClient client,
    required Ref ref,
  })  : _client = client,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  Future<void> _queueAction(OfflineAction action) async {
    await _offlineQueue.enqueueAction(
      actionType: action.type,
      payload: action.toMap(),
    );
  }

  @override
  Future<Either<Failure, List<SavingsGoalModel>>> getGoals(
      {required String householdId, int? limit, int? offset,}) async {
    return executeWithHandling(() async {
      var query = _client
          .from('savings_goals')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);
      if (offset != null && limit != null) {
        query = query.range(offset, offset + limit - 1);
      } else if (limit != null) {
        query = query.limit(limit);
      }
      final response = await query;

      return (response as List)
          .map((json) => SavingsGoalModel.fromJson(json))
          .toList();
    }, context: 'SupabaseSavingsRepository.getGoals', isOnline: _isOnline,);
  }

  @override
  Future<Either<Failure, List<SavingsContributionModel>>> getGoalContributions(
      {required String goalId,}) async {
    return executeWithHandling(() async {
      final response = await _client
          .from('savings_contributions')
          .select('*, user:users!user_id(full_name, avatar_url)')
          .eq('goal_id', goalId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SavingsContributionModel.fromJson(json))
          .toList();
    }, context: 'SupabaseSavingsRepository.getGoalContributions', isOnline: _isOnline,);
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
    },
        context: 'SupabaseSavingsRepository.createGoal',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableInsert,
              target: 'savings_goals',
              values: {
                'household_id': householdId,
                'title': title,
                'target_amount': targetAmount,
                'color': color,
                'icon': icon,
              },
            ),
          );
        },);
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
    },
        context: 'SupabaseSavingsRepository.addContribution',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableInsert,
              target: 'savings_contributions',
              values: {
                'goal_id': goalId,
                'user_id': userId,
                'amount': amount,
                'note': note,
              },
            ),
          );
        },);
  }

  @override
  Future<Either<Failure, void>> deleteGoal({required String goalId}) async {
    return executeWithHandling(() async {
      await _client.from('savings_goals').delete().eq('id', goalId);
    },
        context: 'SupabaseSavingsRepository.deleteGoal',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableDelete,
              target: 'savings_goals',
              filters: [OfflineFilter(column: 'id', value: goalId)],
            ),
          );
        },);
  }
}
