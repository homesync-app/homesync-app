import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provides the singleton instance of ExpenseRepository
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(Supabase.instance.client);
});

enum SplitType { equal, fixed, gift, personal }

class ExpenseRepository {
  final SupabaseClient _client;

  ExpenseRepository(this._client);

  /// Get the user's household ID
  Future<String> getHouseholdId(String userId) async {
    final memberData = await _client
        .from('household_members')
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (memberData == null) {
      throw Exception('No pertenecés a un hogar');
    }
    return memberData['household_id'] as String;
  }

  /// Get a list of recent expenses
  Future<List<Map<String, dynamic>>> getRecentExpenses(String householdId) async {
    return await _client
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
          description,
          users!expenses_paid_by_fkey(email, full_name, avatar_url),
          expense_splits(*)
        ''')
        .eq('household_id', householdId)
        .order('paid_at', ascending: false)
        .limit(20);
  }

  /// Get a single expense with its splits
  Future<Map<String, dynamic>> getExpenseWithSplits(String expenseId) async {
    final expense = await _client
        .from('expenses')
        .select('''
          *,
          expense_splits(*)
        ''')
        .eq('id', expenseId)
        .single();
    return expense;
  }

  /// Get balances for all household members
  Future<List<Map<String, dynamic>>> getHouseholdBalances(String householdId) async {
    final response = await _client.rpc(
      'get_expense_balance',
      params: {'p_household_id': householdId},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  /// Save (create or update) an expense
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
    List<Map<String, dynamic>>? splits, // user_id, amount
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    final expenseData = {
      'household_id': householdId,
      'title': title,
      'amount': amount,
      'category': category,
      'paid_by': paidBy,
      'paid_at': paidAt.toIso8601String(),
      'description': description,
      'split_type': splitType.name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (id == null) {
      // Create
      expenseData['created_by_id'] = user.id;
      expenseData['currency'] = 'ARS';
      
      final res = await _client.from('expenses').insert(expenseData).select('id').single();
      final newId = res['id'];

      if (splits != null && splits.isNotEmpty) {
        await _client.from('expense_splits').insert(
          splits.map((s) => {...s, 'expense_id': newId}).toList()
        );
      }
    } else {
      // Update
      await _client.from('expenses').update(expenseData).eq('id', id);
      
      // Delete old splits and insert new ones
      await _client.from('expense_splits').delete().eq('expense_id', id);
      
      if (splits != null && splits.isNotEmpty) {
        await _client.from('expense_splits').insert(
          splits.map((s) => {...s, 'expense_id': id}).toList()
        );
      }
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    await _client.from('expenses').delete().eq('id', id);
  }

  /// Settle debt using the server-side RPC
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
