import 'base_rpc_service.dart';

class BalanceRpcService extends BaseRpcService {
  BalanceRpcService({required super.clientOverride});

  Future<Map<String, dynamic>> getUserBalance({
    required String householdId,
  }) async {
    final userId = await requireCurrentUserId();

    final response = await client.rpc(
      'get_user_balance',
      params: {
        'p_user_id': userId,
        'p_household_id': householdId,
      },
    );

    return {
      'success': true,
      'data': response,
    };
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  }) async {
    final userId = await requireCurrentUserId();

    final response = await client.rpc(
      'get_transaction_history',
      params: {
        'p_user_id': userId,
        'p_limit': limit,
        'p_offset': offset,
        'p_type_filter': typeFilter,
      },
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTransactionTypes() async {
    final response = await client.rpc('get_transaction_types');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getHouseholdBalances(String householdId) async {
    final response = await client.rpc(
      'get_expense_balance',
      params: {'p_household_id': householdId},
    );
    return {'balances': response};
  }

  Future<Map<String, dynamic>> runIntegrityCheck(String householdId) async {
    final response = await client.rpc(
      'reconcile_points_and_history',
      params: {'p_household_id': householdId},
    );
    return Map<String, dynamic>.from(response);
  }
}
