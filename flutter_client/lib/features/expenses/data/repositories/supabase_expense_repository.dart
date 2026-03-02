import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/constants/app_constants.dart';

class SupabaseExpenseRepository implements ExpenseRepository {
  final SupabaseClient _client;

  SupabaseExpenseRepository(this._client);

  @override
  Future<String> getHouseholdId(String userId) async {
    final memberData = await _client
        .from(AppConstants.tableHouseholdMembers)
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (memberData == null) {
      throw Exception('No pertenecés a un hogar');
    }
    return memberData['household_id'] as String;
  }

  @override
  Future<List<ExpenseModel>> getRecentExpenses(String householdId) async {
    final response = await _client
        .from('expenses')
        .select('''
          id,
          title,
          amount,
          category,
          paid_at,
          created_at,
          paid_by,
          split_type,
          split_type,
          is_shared,
          type,
          description,
          users!expenses_paid_by_fkey(email, full_name, avatar_url),
          expense_splits(*)
        ''')
        .eq('household_id', householdId)
        .order('paid_at', ascending: false)
        .limit(30);
        
    return (response as List<dynamic>)
        .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getExpenseWithSplits(String expenseId) async {
    return await _client
        .from('expenses')
        .select('''
          *,
          expense_splits(*)
        ''')
        .eq('id', expenseId)
        .single();
  }

  @override
  Future<List<HouseholdBalanceModel>> getHouseholdBalances(String householdId) async {
    final response = await _client.rpc(
      'get_expense_balance',
      params: {'p_household_id': householdId},
    );
    return (response as List<dynamic>)
        .map((e) => HouseholdBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveExpense({
    String? id,
    required String householdId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime paidAt,
    String? description,
    required SplitType splitType,
    String type = 'expense',
    List<Map<String, dynamic>>? splits,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    await _client.rpc(
      'save_expense_v4',
      params: {
        'p_id': id,
        'p_household_id': householdId,
        'p_title': title,
        'p_amount': amount,
        'p_category': category,
        'p_paid_by': paidBy,
        'p_paid_at': paidAt.toIso8601String(),
        'p_description': description,
        'p_split_type': splitType.name,
        'p_is_shared': splitType != SplitType.personal,
        'p_type': type,
        'p_splits': splits,
      },
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _client.from('expenses').delete().eq('id', id);
  }

  @override
  Future<void> settleDebt({
    required String householdId,
    required String toUserId,
    required double amount,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    await _client.rpc(
      'settle_debt',
      params: {
        'p_user_id': user.id,
        'p_household_id': householdId,
        'p_to_user_id': toUserId,
        'p_amount': amount,
      },
    );
  }
}
