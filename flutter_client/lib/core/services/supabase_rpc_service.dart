import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRpcService {
  static final SupabaseRpcService _instance = SupabaseRpcService._internal();
  factory SupabaseRpcService() => _instance;
  SupabaseRpcService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    _client = Supabase.instance.client;
  }

  // ============================================
  // CREATE task // ============================================

  Future<String> createTask({
    required String title,
    String? description,
    String? category,
    String? assignedTo,
    String type = 'one_time',
    String difficulty = 'medium',
    int xpReward = 0,
    int coinReward = 0,
    String priority = 'medium',
    DateTime? dueAt,
    String? recurrenceType,
    int recurrenceInterval = 1,
    DateTime? recurrenceEndAt,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'create_task',
      params: {
        'p_user_id': user.id,
        'p_title': title,
        'p_category': category,
        'p_assigned_to': assignedTo,
        'p_type': type,
        'p_difficulty': difficulty,
        'p_xp_reward': xpReward,
        'p_coin_reward': coinReward,
        'p_priority': priority,
        'p_due_at': dueAt?.toIso8601String(),
        'p_recurrence_type': recurrenceType,
        'p_recurrence_interval': recurrenceInterval,
        'p_recurrence_end_at': recurrenceEndAt?.toIso8601String(),
      },
    );

    final taskId = response as String;

    // Update description if provided (not in RPC params)
    if (description != null && description.isNotEmpty) {
      await _client
          .from('tasks')
          .update({'description': description}).eq('id', taskId);
    }

    return taskId;
  }

  // ============================================
  // COMPLETE TaskModel TRANSACTION
  // ============================================

  Future<Map<String, dynamic>> completeTaskTransaction({
    required String taskId,
    required String taskTitle,
    required int xpReward,
    required int coinReward,
    required String householdId,
    String? userId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final requestId = generateRequestId();

    final response = await _client.rpc(
      'complete_task_transaction',
      params: {
        'p_request_id': requestId,
        'p_user_id': userId ?? user.id,
        'p_task_id': taskId,
        'p_household_id': householdId,
        'p_xp_reward': xpReward,
        'p_coin_reward': coinReward,
        'p_task_title': taskTitle,
      },
    );

    return {
      'success': response['success'] ?? false,
      'message': response['message'] ?? '',
      'data': response,
    };
  }

  // ============================================
  // VERIFY TaskModel TRANSACTION
  // ============================================

  Future<Map<String, dynamic>> verifyTaskTransaction({
    required String taskId,
    String? nextDueAt,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final requestId = generateRequestId();

    final response = await _client.rpc(
      'verify_task_transaction',
      params: {
        'p_request_id': requestId,
        'p_user_id': user.id,
        'p_task_id': taskId,
        'p_verified_by': user.id,
        'p_next_due_at': nextDueAt,
      },
    );

    return {
      'success': response['success'] ?? false,
      'message': response['message'] ?? '',
      'data': response,
    };
  }

  // ============================================
  // REJECT TaskModel TRANSACTION
  // ============================================

  Future<Map<String, dynamic>> rejectTaskTransaction({
    required String taskId,
    String? reason,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final requestId = generateRequestId();

    final response = await _client.rpc(
      'reject_task_transaction',
      params: {
        'p_request_id': requestId,
        'p_user_id': user.id,
        'p_task_id': taskId,
        'p_rejected_by': user.id,
        'p_reason': reason,
      },
    );

    return {
      'success': response['success'] ?? false,
      'message': response['message'] ?? '',
      'data': response,
    };
  }

  // ============================================
  // GET USER BALANCE
  // ============================================

  Future<Map<String, dynamic>> getUserBalance({
    required String householdId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_user_balance',
      params: {
        'p_user_id': user.id,
        'p_household_id': householdId,
      },
    );

    return {
      'success': true,
      'data': response,
    };
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  String generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ============================================
  // GET TASKS FROM DATABASE (Direct query)
  // ============================================

  Future<List<Map<String, dynamic>>> getTasks({int limit = 100, int offset = 0}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final householdMembers = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .limit(1);

    if (householdMembers.isEmpty) {
      return [];
    }

    final householdId = householdMembers.first['household_id'];

    final response = await _client
        .from('tasks')
        .select()
        .eq('household_id', householdId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return response;
  }

  // ============================================
  // HOUSEHOLD MEMBERS
  // ============================================

  Future<Map<String, dynamic>> getHouseholdInfo() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_household_info',
      params: {'p_user_id': user.id},
    );

    return Map<String, dynamic>.from(response);
  }

  /// Generates (or returns existing) invitation code via secure backend RPC.
  Future<String> generateInvitationCode() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final householdMember = await _client
        .from('household_members')
        .select('household_id, role')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMember == null) {
      throw Exception('No perteneces a ningún hogar');
    }

    final response = await _client.rpc(
      'generate_household_invitation',
      params: {'p_household_id': householdMember['household_id']},
    );

    return response as String;
  }

  /// Joins a household by code. Migrates user out of their current solo household.
  Future<Map<String, dynamic>> joinHousehold(String code) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final response = await _client.rpc(
      'join_household_by_code',
      params: {'p_code': code.trim().toUpperCase()},
    );

    final result = Map<String, dynamic>.from(response);
    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Error al unirse al hogar');
    }
    return result;
  }

  /// Returns all members of the user's current household.
  Future<List<Map<String, dynamic>>> getHouseholdMembers() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final householdMember = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMember == null) return [];

    final response = await _client
        .from('household_members')
        .select('user_id, role, users(full_name, email, avatar_url, mercadopago_alias)')
        .eq('household_id', householdMember['household_id']);

    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================
  // REWARDS / SHOP
  // ============================================

  Future<List<Map<String, dynamic>>> getAvailableRewards() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
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
    final response = await _client.rpc(
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
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
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
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
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
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_redemption_history',
      params: {'p_user_id': user.id},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> fulfillRedemption(String redemptionId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'fulfill_redemption',
      params: {
        'p_redemption_id': redemptionId,
        'p_user_id': user.id,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  // ============================================
  // TRANSACTION HISTORY
  // ============================================

  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int limit = 50,
    int offset = 0,
    String? typeFilter,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_transaction_history',
      params: {
        'p_user_id': user.id,
        'p_limit': limit,
        'p_offset': offset,
        'p_type_filter': typeFilter,
      },
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTransactionTypes() async {
    final response = await _client.rpc('get_transaction_types');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getHouseholdBalances(String householdId) async {
    final response = await _client.rpc(
      'get_expense_balance',
      params: {'p_household_id': householdId},
    );
    return {'balances': response};
  }

  // ============================================
  // STATISTICS
  // ============================================

  Future<List<Map<String, dynamic>>> getTaskStatsByCategory() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_task_stats_by_category',
      params: {'p_user_id': user.id},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getXpHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    try {
      final response = await _client.rpc(
        'get_xp_history',
        params: {'p_user_id': user.id},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      // RPC may not exist yet — graceful fallback
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCoinHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    try {
      final response = await _client.rpc(
        'get_coin_history',
        params: {'p_user_id': user.id},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExpenseStatsByCategory() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_expense_stats_by_category',
      params: {'p_user_id': user.id},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMemberActivityStats() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_member_activity_stats',
      params: {'p_user_id': user.id},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> objectTask({
    required String taskId,
    String? reason,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'object_task',
      params: {
        'p_task_id': taskId,
        'p_user_id': user.id,
        'p_reason': reason,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> restoreTaskCoins(
      {required String taskId}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'restore_task_coins',
      params: {
        'p_task_id': taskId,
        'p_user_id': user.id,
      },
    );

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTaskHistory({int limit = 50}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_task_history',
      params: {
        'p_user_id': user.id,
        'p_limit': limit,
      },
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getWeeklyRanking() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final householdMembers = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMembers == null) {
      return [];
    }

    final response = await _client.rpc(
      'get_weekly_ranking',
      params: {'p_household_id': householdMembers['household_id']},
    );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> isWeekProcessed() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final householdMembers = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMembers == null) return false;

    final response = await _client.rpc(
      'is_week_processed',
      params: {'p_household_id': householdMembers['household_id']},
    );

    return response == true;
  }

  Future<Map<String, dynamic>> awardWeeklyWinner() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final householdMembers = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMembers == null) {
      throw Exception('No perteneces a un hogar');
    }

    final response = await _client.rpc(
      'award_weekly_winner',
      params: {'p_household_id': householdMembers['household_id']},
    );

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> checkShouldShowWinner() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return {'show_winner': false};
    }

    final householdMembers = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMembers == null) {
      return {'show_winner': false};
    }

    final response = await _client.rpc(
      'should_show_winner',
      params: {'p_household_id': householdMembers['household_id']},
    );

    return Map<String, dynamic>.from(response);
  }

  // ============================================
  // ERROR LOGGING & DIAGNOSTICS
  // ============================================

  Future<void> logApplicationError({
    required String message,
    String? stackTrace,
    String level = 'error',
    Map<String, dynamic>? context,
  }) async {
    final user = _client.auth.currentUser;
    try {
      await _client.from('application_logs').insert({
        'user_id': user?.id,
        'level': level,
        'message': message,
        'stack_trace': stackTrace,
        'context': context ?? {},
        'device_info': {
          'platform': 'flutter',
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
    } catch (e) {
      // If logging fails, we just print so we don't cause an infinite error loop
      print('Failed to log error to Supabase: $e');
    }
  }

  Future<Map<String, dynamic>> runIntegrityCheck(String householdId) async {
    final response = await _client.rpc(
      'reconcile_points_and_history',
      params: {'p_household_id': householdId},
    );
    return Map<String, dynamic>.from(response);
  }
}
