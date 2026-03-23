import 'base_rpc_service.dart';

class HouseholdRpcService extends BaseRpcService {
  HouseholdRpcService({super.clientOverride});

  Future<Map<String, dynamic>> getHouseholdInfo() async {
    final userId = await requireCurrentUserId();
    final response = await client.rpc(
      'get_household_info',
      params: {'p_user_id': userId},
    );

    return Map<String, dynamic>.from(response);
  }

  Future<String> generateInvitationCode() async {
    final userId = await requireCurrentUserId();

    final householdMember = await client
        .from('household_members')
        .select('household_id, role')
        .eq('user_id', userId)
        .maybeSingle();

    if (householdMember == null) {
      throw Exception('No perteneces a ningun hogar');
    }

    final response = await client.rpc(
      'generate_household_invitation',
      params: {'p_household_id': householdMember['household_id']},
    );

    return response as String;
  }

  Future<Map<String, dynamic>> joinHousehold(String code) async {
    await requireCurrentUserId();

    final response = await client.rpc(
      'join_household_by_code',
      params: {'p_code': code.trim().toUpperCase()},
    );

    final result = Map<String, dynamic>.from(response);
    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Error al unirse al hogar');
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getHouseholdMembers() async {
    final userId = await requireCurrentUserId();

    final householdMember = await client
        .from('household_members')
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (householdMember == null) return [];

    final response = await client
        .from('household_members')
        .select(
          'user_id, role, users(full_name, email, avatar_url, mercadopago_alias)',
        )
        .eq('household_id', householdMember['household_id']);

    return List<Map<String, dynamic>>.from(response);
  }
}
