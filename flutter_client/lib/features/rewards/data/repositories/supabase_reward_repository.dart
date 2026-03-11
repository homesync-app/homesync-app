import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/repository_error_handler.dart';
import 'package:homesync_client/features/rewards/domain/repositories/reward_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/errors/failures.dart';

part 'supabase_reward_repository.g.dart';

@riverpod
RewardRepository rewardRepository(RewardRepositoryRef ref) {
  final client = ref.read(supabaseClientProvider);
  final rpc = ref.read(rewardRpcServiceProvider);
  return SupabaseRewardRepository(client: client, rpc: rpc, ref: ref);
}

class SupabaseRewardRepository
    with RepositoryErrorHandler
    implements RewardRepository {
  final SupabaseClient _client;
  final dynamic _rpc; // rewardRpcServiceProvider type
  final Ref _ref;

  SupabaseRewardRepository(
      {required SupabaseClient client, required dynamic rpc, required Ref ref})
      : _client = client,
        _rpc = rpc,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

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
    }, context: 'SupabaseRewardRepository.getRewards', isOnline: _isOnline);
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
    }, context: 'SupabaseRewardRepository.suggestReward', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> approveReward(String rewardId) async {
    return executeWithHandling(() async {
      await _client
          .from('rewards')
          .update({'is_approved': true}).eq('id', rewardId);
    }, context: 'SupabaseRewardRepository.approveReward', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> redeemReward(String rewardId) async {
    return executeWithHandling(() async {
      await _rpc.redeemReward(rewardId);
    }, context: 'SupabaseRewardRepository.redeemReward', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> deleteReward(String rewardId) async {
    return executeWithHandling(() async {
      await _client.from('rewards').delete().eq('id', rewardId);
    }, context: 'SupabaseRewardRepository.deleteReward', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, int>> cloneTemplates() async {
    return executeWithHandling(() async {
      return await _rpc.cloneRewardTemplates();
    }, context: 'SupabaseRewardRepository.cloneTemplates', isOnline: _isOnline);
  }
}
