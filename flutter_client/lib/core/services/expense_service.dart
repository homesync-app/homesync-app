import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/expenses/domain/models/expense_models.dart';

class ExpenseService {
  final SupabaseClient _client;

  ExpenseService() : _client = Supabase.instance.client;

  Future<String> createExpense({
    required String householdId,
    required String title,
    required double amount,
    required String paidBy,
    String category = 'other',
    String? description,
    String currency = 'EUR',
    List<String>? splitUserIds,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'create_expense',
      params: {
        'p_user_id': user.id,
        'p_household_id': householdId,
        'p_title': title,
        'p_amount': amount,
        'p_paid_by': paidBy,
        'p_category': category,
        'p_description': description,
        'p_currency': currency,
        'p_split_type': 'equal',
        'p_split_user_ids': splitUserIds,
      },
    );

    return response as String;
  }

  Future<List<ExpenseBalance>> getExpenseBalance(String householdId) async {
    final response = await _client.rpc(
      'get_expense_balance',
      params: {'p_household_id': householdId},
    );

    return (response as List)
        .map((json) => ExpenseBalance.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Debt>> getDebts(String householdId) async {
    final response = await _client.rpc(
      'get_debts',
      params: {'p_household_id': householdId},
    );

    return (response as List)
        .map((json) => Debt.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ExpenseHistoryItem>> getExpenseHistory(
    String householdId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _client.rpc(
      'get_expense_history',
      params: {
        'p_household_id': householdId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );

    return (response as List)
        .map(
            (json) => ExpenseHistoryItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String> settleDebt({
    required String householdId,
    required String toUserId,
    required double amount,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'settle_debt',
      params: {
        'p_user_id': user.id,
        'p_household_id': householdId,
        'p_to_user_id': toUserId,
        'p_amount': amount,
      },
    );

    return response as String;
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final response =
        await _client.from('expense_categories').select().order('name');

    return (response as List)
        .map((json) => ExpenseCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
