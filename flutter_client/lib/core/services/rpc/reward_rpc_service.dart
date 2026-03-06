import 'base_rpc_service.dart';

class RewardRpcService extends BaseRpcService {
  RewardRpcService({super.clientOverride});

  Future<List<Map<String, dynamic>>> getAvailableRewards() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'get_available_rewards',
      params: {'p_user_id': user.id},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<String> createCustomReward({
    required String householdId,
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
  }) async {
    final response = await client.rpc(
      'create_custom_reward',
      params: {
        'p_household_id': householdId,
        'p_title': title,
        'p_description': description,
        'p_cost': cost,
        'p_icon': icon,
      },
    );

    return response as String;
  }

  Future<Map<String, dynamic>> redeemReward(String rewardId) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'redeem_reward',
      params: {
        'p_reward_id': rewardId,
        'p_user_id': user.id,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> transferCoins({
    required String toUserId,
    required int amount,
    required String householdId,
    String? note,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'transfer_coins',
      params: {
        'p_from_user_id': user.id,
        'p_to_user_id': toUserId,
        'p_amount': amount,
        'p_household_id': householdId,
        'p_note': note,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> getRedemptionHistory() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'get_redemption_history',
      params: {'p_user_id': user.id},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> fulfillRedemption(String redemptionId) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'fulfill_redemption',
      params: {
        'p_redemption_id': redemptionId,
        'p_user_id': user.id,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<int> cloneRewardTemplates() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await client.rpc(
      'clone_reward_templates',
      params: {
        'p_user_id': user.id,
      },
    );

    return response as int;
  }
}
