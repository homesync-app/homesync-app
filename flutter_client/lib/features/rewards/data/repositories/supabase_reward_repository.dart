import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/repository_error_handler.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/reward_repository.dart';

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  final rpc = ref.read(rewardRpcServiceProvider);
  return SupabaseRewardRepository(client: client, rpc: rpc);
});

class SupabaseRewardRepository
    with RepositoryErrorHandler
    implements RewardRepository {
  final SupabaseClient _client;
  final dynamic _rpc; // rewardRpcServiceProvider type

  SupabaseRewardRepository(
      {required SupabaseClient client, required dynamic rpc})
      : _client = client,
        _rpc = rpc;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRewards(
      String householdId) async {
    return executeWithHandling(() async {
      final response = await _client
          .from('rewards')
          .select()
          .eq('household_id', householdId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    }, context: 'SupabaseRewardRepository.getRewards');
  }

  @override
  Future<Either<Failure, void>> suggestReward({
    required String householdId,
    required String title,
    String? description,
    required int cost,
    required String icon,
    required String createdBy,
  }) async {
    return executeWithHandling(() async {
      await _client.from('rewards').insert({
        'household_id': householdId,
        'title': title,
        'description': description,
        'cost': cost,
        'icon': icon,
        'created_by': createdBy,
        'is_approved': false,
      });
    }, context: 'SupabaseRewardRepository.suggestReward');
  }

  @override
  Future<Either<Failure, void>> approveReward(String rewardId) async {
    return executeWithHandling(() async {
      await _client
          .from('rewards')
          .update({'is_approved': true}).eq('id', rewardId);
    }, context: 'SupabaseRewardRepository.approveReward');
  }

  @override
  Future<Either<Failure, void>> redeemReward(String rewardId) async {
    return executeWithHandling(() async {
      await _rpc.redeemReward(rewardId);
    }, context: 'SupabaseRewardRepository.redeemReward');
  }

  @override
  Future<Either<Failure, void>> deleteReward(String rewardId) async {
    return executeWithHandling(() async {
      await _client.from('rewards').delete().eq('id', rewardId);
    }, context: 'SupabaseRewardRepository.deleteReward');
  }
}
