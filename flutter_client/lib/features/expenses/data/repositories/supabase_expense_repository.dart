import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../domain/models/expense_model.dart';
import '../../domain/models/feed_item_model.dart';
import '../../domain/models/expense_template_model.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import '../../../../core/services/repository_error_handler.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/core/offline/offline_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import 'package:homesync_client/config/app_environment.dart';

class SupabaseExpenseRepository
    with RepositoryErrorHandler
    implements ExpenseRepository {
  final SupabaseClient _client;
  final Ref _ref;
  final OfflineQueueService _offlineQueue = OfflineQueueService();

  SupabaseExpenseRepository(this._client, this._ref);

  bool get _isOnline => _ref.read(isOnlineProvider);
  bool get _isAdminTestingActive {
    final admin = _ref.read(adminProvider);
    return AppEnvironment.enableAdminTesting &&
        admin.isAdminUser &&
        !admin.useRealQaSession &&
        admin.selectedHouseholdId != null;
  }

  bool _isPrivateSplitType(String? splitType) {
    final value = splitType?.toLowerCase();
    return value == 'personal' || value == 'gift';
  }

  bool _isVisibleExpenseRowForUser(Map<String, dynamic> row, String? userId) {
    if (userId == null) return true;

    final rawIsShared = row['is_shared'];
    final isShared = rawIsShared is bool
        ? rawIsShared
        : !_isPrivateSplitType(row['split_type'] as String?);

    if (isShared) return true;

    final paidBy = row['paid_by']?.toString();
    final createdBy = row['created_by_id']?.toString();
    return paidBy == userId || createdBy == userId;
  }

  bool _isVisibleFeedRowForUser(Map<String, dynamic> row, String? userId) {
    if (userId == null) return true;

    final recordType = row['record_type']?.toString();
    final splitType = row['split_type']?.toString();
    final payerId = row['payer_id']?.toString();

    if (_isPrivateSplitType(splitType)) {
      return payerId == userId;
    }

    if (recordType == 'expense') {
      final rawIsShared = row['is_shared'];
      if (rawIsShared is bool && !rawIsShared) {
        return payerId == userId;
      }
    }

    return true;
  }

  List<dynamic> _normalizeRpcList(dynamic response) {
    if (response == null) return const [];
    if (response is List) return response;

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      for (final key in const ['data', 'result', 'items', 'rows']) {
        final value = map[key];
        if (value is List) return value;
      }
      return const [];
    }

    if (response is String) {
      final decoded = jsonDecode(response);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        for (final key in const ['data', 'result', 'items', 'rows']) {
          final value = map[key];
          if (value is List) return value;
        }
      }
      return const [];
    }

    return const [];
  }

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
    },
        context: 'SupabaseExpenseRepository.getHouseholdId',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
      String householdId) async {
    return executeWithHandling(() async {
      final sw = Stopwatch()..start();
      final currentUserId = await AppIdentityService.instance.refresh();
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

      final rows = _normalizeRpcList(response);
      final expenses = rows
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((row) => _isVisibleExpenseRowForUser(row, currentUserId))
          .map(ExpenseModel.fromJson)
          .toList();
      sw.stop();
      log.i(
        'Finance RPC get_filtered_expenses ok household=$householdId items=${expenses.length} ms=${sw.elapsedMilliseconds}',
      );
      return expenses;
    },
        context: 'SupabaseExpenseRepository.getRecentExpenses',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<FeedItemModel>>> getCombinedFeed(
      String householdId) async {
    return executeWithHandling(() async {
      final sw = Stopwatch()..start();
      final currentUserId = await AppIdentityService.instance.refresh();
      final response = await _client.rpc(
        'get_combined_feed',
        params: {
          'p_household_id': householdId,
          'p_limit': 200,
          'p_offset': 0,
        },
      );

      final rows = _normalizeRpcList(response);
      final feed = rows
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((row) => _isVisibleFeedRowForUser(row, currentUserId))
          .map(FeedItemModel.fromJson)
          .toList();
      sw.stop();
      log.i(
        'Finance RPC get_combined_feed ok household=$householdId items=${feed.length} ms=${sw.elapsedMilliseconds}',
      );
      return feed;
    },
        context: 'SupabaseExpenseRepository.getCombinedFeed',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
      String expenseId) async {
    return executeWithHandling(() async {
      if (_isAdminTestingActive) {
        final response = await _client.rpc(
          'qa_admin_get_expense_with_splits',
          params: {'p_expense_id': expenseId},
        );
        return Map<String, dynamic>.from(response as Map);
      }

      return await _client.from('expenses').select('''
            *,
            expense_splits(*, users(email, full_name, avatar_url))
          ''').eq('id', expenseId).single();
    },
        context: 'SupabaseExpenseRepository.getExpenseWithSplits',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
      String householdId) async {
    return executeWithHandling(() async {
      final sw = Stopwatch()..start();
      final response = await _client.rpc(
        'get_expense_balance',
        params: {'p_household_id': householdId},
      );
      final rows = _normalizeRpcList(response);
      final balances = rows
          .map((e) => HouseholdBalanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
      sw.stop();
      log.i(
        'Finance RPC get_expense_balance ok household=$householdId items=${balances.length} ms=${sw.elapsedMilliseconds}',
      );
      return balances;
    },
        context: 'SupabaseExpenseRepository.getHouseholdBalances',
        isOnline: _isOnline);
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
    String? receiptPath,
  }) async {
    return executeWithHandling(
        () async {
          final sw = Stopwatch()..start();
          final userId = _isAdminTestingActive
              ? _ref.read(currentUserIdProvider)
              : await AppIdentityService.instance.refresh();
          if (userId == null || userId.isEmpty) throw const AuthFailure();

          await _client.rpc(
            _isAdminTestingActive
                ? 'qa_admin_save_expense_v1'
                : 'save_expense_v4',
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
              'p_is_shared': splitType != SplitType.personal &&
                  splitType != SplitType.gift,
              'p_type': type,
              'p_splits': splits,
              'p_receipt_path': receiptPath,
              if (_isAdminTestingActive) 'p_actor_user_id': userId,
            },
          );
          sw.stop();
          log.i(
            'Finance RPC ${_isAdminTestingActive ? 'qa_admin_save_expense_v1' : 'save_expense_v4'} ok household=$householdId type=$type split=${splitType.name} amount=$amount receipt=${receiptPath != null} ms=${sw.elapsedMilliseconds}',
          );
          await _ref.read(analyticsServiceProvider).trackExpenseCreated(
                category: category,
                splitType: splitType.name,
                entryType: type,
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
                'p_is_shared': splitType != SplitType.personal &&
                    splitType != SplitType.gift,
                'p_type': type,
                'p_splits': splits,
                'p_receipt_path': receiptPath,
              },
            ),
          );
        });
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    return executeWithHandling(
        () async {
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
    return executeWithHandling(
        () async {
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
            ),
          );
        });
  }

  @override
  Future<Map<String, dynamic>> getPersonalFinanceSummary(
      String userId, String householdId) async {
    final sw = Stopwatch()..start();
    final response = await _client.rpc(
      'get_personal_finance_summary',
      params: {
        'p_user_id': userId,
        'p_household_id': householdId,
      },
    );
    final summary = Map<String, dynamic>.from(response);
    sw.stop();
    log.i(
      'Finance RPC get_personal_finance_summary ok household=$householdId user=$userId ms=${sw.elapsedMilliseconds}',
    );
    return summary;
  }

  @override
  Future<Either<Failure, List<ExpenseTemplateModel>>> getTemplates(
      String householdId) async {
    return executeWithHandling(() async {
      final response = await _client
          .from('expense_templates')
          .select()
          .eq('household_id', householdId)
          .eq('is_active', true)
          .order('day_of_month');

      return (response as List<dynamic>)
          .map((json) =>
              ExpenseTemplateModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }, context: 'SupabaseExpenseRepository.getTemplates', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Unit>> saveTemplate(
      ExpenseTemplateModel template) async {
    return executeWithHandling(
        () async {
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
  Future<Either<Failure, Unit>> toggleTemplateActivity(
      String id, bool active) async {
    return executeWithHandling(
        () async {
          await _client
              .from('expense_templates')
              .update({'is_active': active}).eq('id', id);
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
    return executeWithHandling(
        () async {
          final sw = Stopwatch()..start();
          final response = await _client.rpc(
            'pay_planned_expense',
            params: {
              'p_planned_id': plannedId,
              'p_amount': amount,
              'p_paid_at': paidAt.toIso8601String(),
              'p_paid_by': paidBy,
            },
          );

          // Backward/forward compatible parsing:
          // - legacy SQL may return UUID directly
          // - newer SQL may return { success, expense_id, message }
          if (response is Map) {
            final result = Map<String, dynamic>.from(response);
            if (result['success'] == false) {
              throw ServerFailure(
                result['message'] as String? ?? 'Error al pagar gasto planeado',
              );
            }
            sw.stop();
            log.i(
              'Finance RPC pay_planned_expense ok planned=$plannedId success=${result['success'] != false} ms=${sw.elapsedMilliseconds}',
            );
            return result;
          }

          sw.stop();
          log.i(
            'Finance RPC pay_planned_expense ok planned=$plannedId legacy=true ms=${sw.elapsedMilliseconds}',
          );
          return {
            'success': true,
            'expense_id': response?.toString(),
          };
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
  Future<Either<Failure, Unit>> processRecurringExpenses(
      String householdId) async {
    return executeWithHandling(
        () async {
          final sw = Stopwatch()..start();
          final rpcName = _isAdminTestingActive
              ? 'qa_admin_process_recurring_expenses'
              : 'process_recurring_expenses';
          await _client.rpc(
            rpcName,
            params: {'p_household_id': householdId},
          );
          sw.stop();
          log.i(
            'Finance RPC $rpcName ok household=$householdId ms=${sw.elapsedMilliseconds}',
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
  Future<Either<Failure, List<FeedItemModel>>> getMonthlyPendingPlannedExpenses(
    String householdId, {
    required DateTime month,
  }) async {
    return executeWithHandling(() async {
      final monthStart = DateTime(month.year, month.month, 1);
      final nextMonthStart = DateTime(month.year, month.month + 1, 1);
      final currentUserId = await AppIdentityService.instance.refresh();

      final response = await _client
          .from('planned_expenses')
          .select('''
            id,
            title,
            amount,
            category,
            split_type,
            payer_default,
            due_date,
            status
          ''')
          .eq('household_id', householdId)
          .eq('status', 'pending')
          .gte('due_date', monthStart.toIso8601String().split('T').first)
          .lt('due_date', nextMonthStart.toIso8601String().split('T').first)
          .order('due_date');

      return (response as List<dynamic>)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((row) => _isVisibleFeedRowForUser(
                {
                  ...row,
                  'record_type': 'planned',
                  'payer_id': row['payer_default'],
                },
                currentUserId,
              ))
          .map(
            (row) => FeedItemModel(
              recordType: 'planned',
              transactionType: 'expense',
              id: row['id']?.toString() ?? '',
              title: row['title'] as String? ?? 'Pendiente',
              amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
              category: row['category'] as String?,
              splitType: row['split_type'] as String?,
              payerId: row['payer_default']?.toString() ?? '',
              date: DateTime.tryParse('${row['due_date']}') ?? monthStart,
              status: row['status'] as String? ?? 'pending',
            ),
          )
          .toList();
    },
        context: 'SupabaseExpenseRepository.getMonthlyPendingPlannedExpenses',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Unit>> deletePlannedExpense(String id) async {
    return executeWithHandling(
        () async {
          await _client
              .from('planned_expenses')
              .update({'status': 'skipped'}).eq('id', id);
          return unit;
        },
        context: 'SupabaseExpenseRepository.deletePlannedExpense',
        isOnline: _isOnline,
        onOffline: () async {
          await _queueAction(
            OfflineAction(
              type: OfflineActionType.tableUpdate,
              target: 'planned_expenses',
              values: {'status': 'skipped'},
              filters: [OfflineFilter(column: 'id', value: id)],
            ),
          );
          return unit;
        });
  }
}
