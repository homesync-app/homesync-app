import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import '../../domain/models/reward_model.dart';
import '../../domain/repositories/rewards_repository_interface.dart';

final rewardsRepositoryProvider = Provider<RewardsRepositoryInterface>((ref) {
  final client = ref.read(supabaseClientProvider);
  final rpcService = ref.read(rpcServiceProvider);
  return SupabaseRewardsRepository(client: client, rpc: rpcService);
});

/// Concrete Supabase implementation of the rewards data layer.
/// Only this file knows that Supabase exists.
class SupabaseRewardsRepository implements RewardsRepositoryInterface {
  final SupabaseClient _client;
  final SupabaseRpcService _rpc;

  SupabaseRewardsRepository({
    required SupabaseClient client,
    required SupabaseRpcService rpc,
  })  : _client = client,
        _rpc = rpc;

  @override
  Future<List<RewardModel>> getRewards(String householdId) async {
    final response = await _client
        .from('rewards')
        .select()
        .eq('household_id', householdId)
        .order('cost', ascending: true);

    return (response as List)
        .map((e) => RewardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> suggestReward({
    required String householdId,
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
    required String userId,
  }) async {
    await _client.from('rewards').insert({
      'household_id': householdId,
      'title': title,
      'description': description,
      'cost': cost,
      'icon': icon,
      'created_by': userId,
      'is_approved': false,
    });
  }

  @override
  Future<void> approveReward(String rewardId) async {
    await _client
        .from('rewards')
        .update({'is_approved': true})
        .eq('id', rewardId);
  }

  @override
  Future<void> redeemReward(String rewardId) async {
    final response = await _rpc.redeemReward(rewardId);
    if (response['success'] == false) {
      throw Exception(response['message'] ?? 'Error desconocido al canjear');
    }
  }

  @override
  Future<void> deleteReward(String rewardId) async {
    await _client.from('rewards').delete().eq('id', rewardId);
  }
}
