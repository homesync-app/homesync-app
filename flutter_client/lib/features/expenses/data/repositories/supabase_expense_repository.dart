import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/expense_model.dart';
import '../../domain/models/feed_item_model.dart';
import '../../domain/models/expense_template_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../../../../core/services/repository_error_handler.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/core/offline/offline_action.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';

class SupabaseExpenseRepository
    with RepositoryErrorHandler
    implements ExpenseRepository {
  final SupabaseClient _client;
  final Ref _ref;
  final OfflineQueueService _offlineQueue = OfflineQueueService();

  SupabaseExpenseRepository(this._client, this._ref);

  bool get _isOnline => _ref.read(isOnlineProvider);

  Future<void> _queueAction(OfflineAction action) async {
    await _offlineQueue.enqueueAction(
      actionType: action.type,
      payload: action.toMap(),
    );
  }

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
      final response = await _client.rpc(
        'get_filtered_expenses',
        params: {
          'p_household_id': householdId,
          'p_type': 'all',
          'p_sharing': 'all',
          'p_limit': 30,
          'p_offset': 0,
        },
      );
      
      return (response as List<dynamic>)
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'SupabaseExpenseRepository.getRecentExpenses', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<FeedItemModel>>> getCombinedFeed(
      String householdId) async {
    return executeWithHandling(() async {
      final response = await _client.rpc(
        'get_combined_feed',
        params: {'p_household_id': householdId},
      );

      return (response as List<dynamic>)
          .map((e) => FeedItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }, context: 'SupabaseExpenseRepository.getCombinedFeed', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
      String expenseId) async {
    return executeWithHandling(() async {
      return await _client.from('expenses').select('''
            *,
            expense_splits(*, users(email, full_name, avatar_url))
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
          'p_is_shared': splitType != SplitType.personal && splitType != SplitType.gift,
          'p_type': type,
          'p_splits': splits,
        },
      );
    },
        context: 'SupabaseExpenseRepository.saveExpense',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.rpc,
              target: 'save_expense_v4',
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
                'p_is_shared':
                    splitType != SplitType.personal && splitType != SplitType.gift,
                'p_type': type,
                'p_splits': splits,
              },
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    return executeWithHandling(() async {
      await _client.from('expenses').delete().eq('id', id);
    },
        context: 'SupabaseExpenseRepository.deleteExpense',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableDelete,
              target: 'expenses',
              filters: [OfflineFilter(column: 'id', value: id)],
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  }) async {
    return executeWithHandling(() async {
      await _client.rpc(
        'save_expense_v4',
        params: {
          'p_id': null,
          'p_household_id': householdId,
          'p_title': 'Liquidación de pareja',
          'p_amount': amount,
          'p_category': 'other',
          'p_paid_by': fromUserId,
          'p_paid_at': DateTime.now().toIso8601String(),
          'p_description': 'Saldar balance acumulado',
          'p_split_type': 'fixed',
          'p_is_shared': true,
          'p_type': 'settlement',
          'p_splits': [
            {'user_id': toUserId, 'amount': amount}
          ],
        },
      );
    },
        context: 'SupabaseExpenseRepository.settleDebt',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.rpc,
              target: 'save_expense_v4',
              params: {
                'p_id': null,
                'p_household_id': householdId,
                'p_title': 'LiquidaciÃ³n de pareja',
                'p_amount': amount,
                'p_category': 'other',
                'p_paid_by': fromUserId,
                'p_paid_at': DateTime.now().toIso8601String(),
                'p_description': 'Saldar balance acumulado',
                'p_split_type': 'fixed',
                'p_is_shared': true,
                'p_type': 'settlement',
                'p_splits': [
                  {'user_id': toUserId, 'amount': amount}
                ],
              },
            ),
          );
        });
  }

  @override
  Future<Map<String, dynamic>> getPersonalFinanceSummary(String userId, String householdId) async {
    final response = await _client.rpc(
      'get_personal_finance_summary',
      params: {
        'p_user_id': userId,
        'p_household_id': householdId,
      },
    );
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<Either<Failure, List<ExpenseTemplateModel>>> getTemplates(String householdId) async {
    return executeWithHandling(() async {
      final response = await _client
          .from('expense_templates')
          .select()
          .eq('household_id', householdId)
          .eq('is_active', true)
          .order('day_of_month');
      
      return (response as List<dynamic>)
          .map((json) => ExpenseTemplateModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }, context: 'SupabaseExpenseRepository.getTemplates', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Unit>> saveTemplate(ExpenseTemplateModel template) async {
    return executeWithHandling(() async {
      await _client.from('expense_templates').upsert(template.toJson());
      return unit;
    },
        context: 'SupabaseExpenseRepository.saveTemplate',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpsert,
              target: 'expense_templates',
              values: template.toJson(),
            ),
          );
          return unit;
        });
  }

  @override
  Future<Either<Failure, Unit>> toggleTemplateActivity(String id, bool active) async {
    return executeWithHandling(() async {
      await _client
          .from('expense_templates')
          .update({'is_active': active})
          .eq('id', id);
      return unit;
    },
        context: 'SupabaseExpenseRepository.toggleTemplateActivity',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: 'expense_templates',
              values: {'is_active': active},
              filters: [OfflineFilter(column: 'id', value: id)],
            ),
          );
          return unit;
        });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> payPlannedExpense({
    required String plannedId,
    required double amount,
    required DateTime paidAt,
    required String paidBy,
  }) async {
    return executeWithHandling(() async {
      final response = await _client.rpc(
        'pay_planned_expense',
        params: {
          'p_planned_id': plannedId,
          'p_amount': amount,
          'p_paid_at': paidAt.toIso8601String(),
          'p_paid_by': paidBy,
        },
      );
      
      final result = Map<String, dynamic>.from(response as Map);
      if (result['success'] == true) {
        return result;
      } else {
        throw ServerFailure(result['message'] as String? ?? 'Error al pagar gasto planeado');
      }
    },
        context: 'SupabaseExpenseRepository.payPlannedExpense',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.rpc,
              target: 'pay_planned_expense',
              params: {
                'p_planned_id': plannedId,
                'p_amount': amount,
                'p_paid_at': paidAt.toIso8601String(),
                'p_paid_by': paidBy,
              },
            ),
          );
          return {'success': true, 'queued': true};
        });
  }

  @override
  Future<Either<Failure, Unit>> processRecurringExpenses(String householdId) async {
    return executeWithHandling(() async {
      await _client.rpc(
        'process_recurring_expenses',
        params: {'p_household_id': householdId},
      );
      return unit;
    },
        context: 'SupabaseExpenseRepository.processRecurringExpenses',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.rpc,
              target: 'process_recurring_expenses',
              params: {'p_household_id': householdId},
            ),
          );
          return unit;
        });
  }

  @override
  Future<Either<Failure, Unit>> deletePlannedExpense(String id) async {
    return executeWithHandling(() async {
      await _client.from('planned_expenses').delete().eq('id', id);
      return unit;
    },
        context: 'SupabaseExpenseRepository.deletePlannedExpense',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableDelete,
              target: 'planned_expenses',
              filters: [OfflineFilter(column: 'id', value: id)],
            ),
          );
          return unit;
        });
  }
}
