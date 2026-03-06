import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/repository_error_handler.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';

class SupabaseExpenseRepository
    with RepositoryErrorHandler
    implements ExpenseRepository {
  final SupabaseClient _client;
  final Ref _ref;

  SupabaseExpenseRepository(this._client, this._ref);

  bool get _isOnline => _ref.read(isOnlineProvider);

  @override
  Future<Either<Failure, String>> getHouseholdId(String userId) async {
    return executeWithHandling(() async {
      final memberData = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (memberData == null) {
        throw const HouseholdFailure('No pertenecés a un hogar');
      }
      return memberData['household_id'] as String;
    }, context: 'SupabaseExpenseRepository.getHouseholdId', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
      String householdId) async {
    return executeWithHandling(() async {
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
    }, context: 'SupabaseExpenseRepository.getRecentExpenses', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
      String expenseId) async {
    return executeWithHandling(() async {
      return await _client.from('expenses').select('''
            *,
            expense_splits(*)
          ''').eq('id', expenseId).single();
    }, context: 'SupabaseExpenseRepository.getExpenseWithSplits', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
      String householdId) async {
    return executeWithHandling(() async {
      final response = await _client.rpc(
        'get_expense_balance',
        params: {'p_household_id': householdId},
      );
      return (response as List<dynamic>)
          .map((e) => HouseholdBalanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'SupabaseExpenseRepository.getHouseholdBalances', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> saveExpense({
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
    return executeWithHandling(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthFailure();

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
    }, context: 'SupabaseExpenseRepository.saveExpense', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    return executeWithHandling(() async {
      await _client.from('expenses').delete().eq('id', id);
    }, context: 'SupabaseExpenseRepository.deleteExpense', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String toUserId,
    required double amount,
  }) async {
    return executeWithHandling(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthFailure();

      await _client.rpc(
        'settle_debt',
        params: {
          'p_user_id': user.id,
          'p_household_id': householdId,
          'p_to_user_id': toUserId,
          'p_amount': amount,
        },
      );
    }, context: 'SupabaseExpenseRepository.settleDebt', isOnline: _isOnline);
  }
}
