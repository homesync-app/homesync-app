import 'package:homesync_client/core/errors/failures.dart';

import 'base_rpc_service.dart';

class RewardRpcService extends BaseRpcService {
  RewardRpcService({required super.clientOverride});

  Future<Map<String, dynamic>> redeemReward(String rewardId) async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'redeem_reward',
      params: {
        'p_reward_id': rewardId,
        'p_user_id': userId,
      },
    );

    final result = Map<String, dynamic>.from(response as Map);
    // redeem_reward reporta los fallos de negocio (coins insuficientes,
    // premio inexistente) como {'success': false, ...} en vez de lanzar.
    // Convertirlo en Failure acá evita que el caller celebre un canje que
    // el servidor rechazó.
    if (result['success'] != true) {
      throw ValidationFailure(
        (result['message'] as String?) ?? 'No se pudo canjear el premio.',
      );
    }
    return result;
  }

  Future<int> cloneRewardTemplates() async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'clone_reward_templates',
      params: {
        'p_user_id': userId,
      },
    );

    return response as int;
  }

  Future<int> seedFamilyDefaultRewards(String householdId) async {
    final response = await client.rpc(
      'seed_family_default_rewards_v1',
      params: {
        'p_household_id': householdId,
      },
    );

    return (response as num).toInt();
  }
}
