import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _client;
  final Ref _ref;

  SupabaseDashboardRepository(this._client, this._ref);

  bool get _isAdminTestingActive {
    final admin = _ref.read(adminProvider);
    return AppEnvironment.enableAdminTesting &&
        admin.isAdminUser &&
        !admin.useRealQaSession &&
        admin.selectedHouseholdId != null;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchRecentActivity(
    String householdId,
    String userId,
  ) {
    final now = DateTime.now();
    final since = DateTime(
      now.year,
      now.month,
      now.day,
    ).toUtc().toIso8601String();

    return _client
        .from('household_activities')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .order('created_at', ascending: false)
        .asyncMap((rows) async {
          // Filtrar por fecha en cliente porque SupabaseStreamBuilder no soporta .gte()
          rows = rows.where((r) {
            final createdAt = r['created_at'] as String?;
            if (createdAt == null) return false;
            return DateTime.tryParse(createdAt)
                    ?.isAfter(DateTime.parse(since)) ??
                false;
          }).toList();
          // Obtener los IDs de usuario únicos para buscar sus datos
          final userIds = rows
              .map((r) => r['user_id'] as String?)
              .whereType<String>()
              .toSet();

          Map<String, Map<String, dynamic>> usersMap = {};
          if (userIds.isNotEmpty) {
            final usersResponse = await _client
                .from('users')
                .select('id, full_name, avatar_url')
                .inFilter('id', userIds.toList());
            usersMap = {for (var u in usersResponse) u['id']: u};
          }

          final mapped = rows.map((item) {
            final creatorId = item['user_id'] as String?;
            final eventType = item['event_type'] as String;
            final user = usersMap[creatorId];
            final userName = user?['full_name'] ?? 'Alguien';
            final userAvatar = user?['avatar_url'];
            final metadata = Map<String, dynamic>.from(item['metadata'] ?? {});

            String uiType = 'unknown';
            final data = <String, dynamic>{
              'user_name': userName,
              'avatar_url': userAvatar,
              'title': item['title'],
              ...metadata,
            };

            if (eventType == 'task_completed') {
              uiType = 'task';
              final taskTitle =
                  metadata['task_title'] ?? item['title'] ?? 'Tarea del hogar';
              data['title'] = taskTitle;
              data['task_title'] = taskTitle;
              data['task_id'] = metadata['task_id'] ?? metadata['id'];
              data['category'] = metadata['category'] ??
                  metadata['task_category'] ??
                  metadata['category_name'];
              data['xp_reward'] = metadata['xp_reward'] ??
                  metadata['xpReward'] ??
                  metadata['p_xp_reward'] ??
                  metadata['score_impact'] ??
                  metadata['xp'] ??
                  metadata['reward'];
              data['coins_reward'] = metadata['coins_reward'] ??
                  metadata['coin_reward'] ??
                  metadata['coinsReward'] ??
                  metadata['p_coin_reward'] ??
                  metadata['p_coins_reward'] ??
                  metadata['coins'];
            } else if (eventType == 'expense_added') {
              uiType = 'expense';
              final amount = metadata['amount'] ?? 0;
              final expenseDesc = _resolveExpenseTitle(item, metadata);
              data['title'] = expenseDesc;
              data['amount'] = amount;
              data['description'] = expenseDesc;
              data['expense_id'] = metadata['expense_id'] ?? metadata['id'];
              data['is_shared'] = metadata['is_shared'];
              data['split_type'] = metadata['split_type'];
            } else if (eventType == 'reward_redeemed') {
              uiType = 'reward';
              data['title'] = metadata['reward_title'] ??
                  item['title'] ??
                  'Premio canjeado';
              data['reward_icon'] = metadata['reward_icon'] ?? metadata['icon'];
              data['reward_cost'] = metadata['cost'] ??
                  metadata['coins'] ??
                  metadata['coin_cost'];
            } else {
              data['title'] = item['title'] ??
                  item['description'] ??
                  'Realiz\u00f3 una acci\u00f3n';
            }

            return {
              'id': item['id'],
              'type': uiType,
              'data': data,
              'created_at': item['created_at'],
              'creator_id': creatorId,
            };
          }).toList();

          final filtered = mapped.where((activity) {
            final data = activity['data'] as Map<String, dynamic>;
            final type = activity['type'] as String;
            final creatorId = activity['creator_id'] as String?;

            if (type == 'expense') {
              final isIncome = data['type'] == 'income' ||
                  data['type'] == 'ingreso' ||
                  data['category'] == 'salary';
              if (isIncome) return false;

              final isShared = data['is_shared'] == true;
              final splitType = (data['split_type'] as String?)?.toLowerCase();
              final isGift = splitType == 'gift' || splitType == 'regalo';

              return isShared || isGift || creatorId == userId;
            }
            return true;
          }).toList();

          final pendingApprovals =
              await _getPendingApprovalActivities(householdId, since);
          return _dedupeActivities([...filtered, ...pendingApprovals]);
        });
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentActivity(
    String householdId,
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final since = DateTime(
        now.year,
        now.month,
        now.day,
      ).toUtc().toIso8601String();

      final response = _isAdminTestingActive
          ? await _client.rpc(
              'qa_admin_get_recent_activity',
              params: {
                'p_household_id': householdId,
                'p_since': since,
              },
            )
          : await _client
              .from('household_activities')
              .select('''
                id, event_type, title, description, metadata, created_at, user_id,
                user:users!household_activities_user_id_fkey(id, full_name, avatar_url)
              ''')
              .eq('household_id', householdId)
              .gte('created_at', since)
              .order('created_at', ascending: false)
              .limit(30);

      final mappedActivities = (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .map((item) {
        final eventType = item['event_type'] as String;
        final user = item['user'] as Map<String, dynamic>?;
        final creatorId = item['user_id'] as String?;
        final userName = user?['full_name'] ?? 'Alguien';
        final userAvatar = user?['avatar_url'];
        final metadata = Map<String, dynamic>.from(item['metadata'] ?? {});

        String uiType = 'unknown';
        final data = <String, dynamic>{
          'user_name': userName,
          'avatar_url': userAvatar,
          'title': item['title'],
          ...metadata,
        };

        if (eventType == 'task_completed') {
          uiType = 'task';
          final taskTitle =
              metadata['task_title'] ?? item['title'] ?? 'Tarea del hogar';
          data['title'] = taskTitle;
          data['task_title'] = taskTitle;
          data['task_id'] = metadata['task_id'] ?? metadata['id'];
          data['category'] = metadata['category'] ??
              metadata['task_category'] ??
              metadata['category_name'];
          data['xp_reward'] = metadata['xp_reward'] ??
              metadata['xpReward'] ??
              metadata['p_xp_reward'] ??
              metadata['score_impact'] ??
              metadata['xp'] ??
              metadata['reward'];
          data['coins_reward'] = metadata['coins_reward'] ??
              metadata['coin_reward'] ??
              metadata['coinsReward'] ??
              metadata['p_coin_reward'] ??
              metadata['p_coins_reward'] ??
              metadata['coins'];
        } else if (eventType == 'expense_added') {
          uiType = 'expense';
          final amount = metadata['amount'] ?? 0;
          final expenseDesc = _resolveExpenseTitle(item, metadata);
          data['title'] = expenseDesc;
          data['amount'] = amount;
          data['description'] = expenseDesc;
          data['expense_id'] = metadata['expense_id'] ?? metadata['id'];
          data['is_shared'] = metadata['is_shared'];
          data['split_type'] = metadata['split_type'];
        } else if (eventType == 'reward_redeemed') {
          uiType = 'reward';
          data['title'] = metadata['reward_title'] ??
              item['title'] ??
              'Premio canjeado';
          data['reward_icon'] = metadata['reward_icon'] ?? metadata['icon'];
          data['reward_cost'] = metadata['cost'] ??
              metadata['coins'] ??
              metadata['coin_cost'];
        } else {
          data['title'] = item['title'] ??
              item['description'] ??
              'Realiz\u00f3 una acci\u00f3n';
        }

        return {
          'id': item['id'],
          'type': uiType,
          'data': data,
          'created_at': item['created_at'],
          'creator_id': creatorId,
        };
      }).where((activity) {
        final data = activity['data'] as Map<String, dynamic>;
        final type = activity['type'] as String;
        final creatorId = activity['creator_id'] as String?;

        if (type == 'expense') {
          final isIncome = data['type'] == 'income' ||
              data['type'] == 'ingreso' ||
              data['category'] == 'salary';
          if (isIncome) return false;

          final isShared = data['is_shared'] == true;
          final splitType = (data['split_type'] as String?)?.toLowerCase();
          final isGift = splitType == 'gift' || splitType == 'regalo';

          final shouldShow = isShared || isGift || creatorId == userId;

          dev.log(
            'Activity Filter Trace [Expense]: title="${data['title']}", isShared=$isShared, isGift=$isGift, creatorId=$creatorId, currentUserId=$userId, results SHOW=$shouldShow',
          );

          return shouldShow;
        }

        return true;
      }).toList();

      final pendingApprovals =
          await _getPendingApprovalActivities(householdId, since);
      final activities = _dedupeActivities([
        ...mappedActivities,
        ...pendingApprovals,
      ]);

      dev.log(
        'SupabaseDashboardRepository: Fetched ${activities.length} activities '
        'for household=$householdId since=$since',
      );
      return activities;
    } catch (e) {
      dev.log('Error fetching activities: $e');
      return [];
    }
  }

  String _resolveExpenseTitle(
    Map<dynamic, dynamic> item,
    Map<String, dynamic> metadata,
  ) {
    final candidates = [
      metadata['expense_title'],
      metadata['merchant'],
      metadata['store_name'],
      metadata['place_name'],
      metadata['description'],
      item['description'],
      metadata['category_name'],
      metadata['category'],
      item['title'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null &&
          value.isNotEmpty &&
          value.toLowerCase() != 'un gasto' &&
          value.toLowerCase() != 'gasto') {
        if (candidate == metadata['category'] ||
            candidate == metadata['category_name']) {
          return CategoryMapping.displayName(value);
        }
        return _localizedCategoryTitle(value);
      }
    }

    return 'Gasto del hogar';
  }

  String _localizedCategoryTitle(String value) {
    final lower = value.toLowerCase().trim();
    if (CategoryMapping.categoryNames.containsKey(lower)) {
      return CategoryMapping.displayName(value);
    }
    return value;
  }

  Future<List<Map<String, dynamic>>> _getPendingApprovalActivities(
    String householdId,
    String since,
  ) async {
    try {
      final response = await _client
          .from('tasks')
          .select(
            'id, title, category, xp_reward, coin_reward, completed_at, completed_by, assigned_to, status',
          )
          .eq('household_id', householdId)
          .eq('status', 'pending_approval')
          .order('completed_at', ascending: false)
          .limit(20);

      final sinceDate = DateTime.tryParse(since);
      final rows = List<Map<String, dynamic>>.from(response).where((task) {
        final completedAt = DateTime.tryParse(
          task['completed_at'] as String? ?? '',
        );
        if (completedAt == null || sinceDate == null) return true;
        return completedAt.isAfter(sinceDate);
      }).toList();

      final userIds = rows
          .map((task) => task['completed_by'] as String?)
          .whereType<String>()
          .toSet();

      var usersMap = <String, Map<String, dynamic>>{};
      if (userIds.isNotEmpty) {
        final usersResponse = await _client
            .from('users')
            .select('id, full_name, avatar_url')
            .inFilter('id', userIds.toList());
        usersMap = {
          for (final user in usersResponse)
            user['id'] as String: Map<String, dynamic>.from(user),
        };
      }

      return rows.map((task) {
        final completedBy = task['completed_by'] as String?;
        final user = completedBy != null ? usersMap[completedBy] : null;
        final title = task['title']?.toString() ?? 'Tarea del hogar';

        return {
          'id': 'pending-task-${task['id']}',
          'type': 'task_pending_approval',
          'data': {
            'user_name': user?['full_name'] ?? 'Alguien',
            'avatar_url': user?['avatar_url'],
            'title': title,
            'task_title': title,
            'task_id': task['id'],
            'category': task['category'],
            'xp_reward': task['xp_reward'],
            'coins_reward': task['coin_reward'],
            'approval_status': 'pending_approval',
            'task_status': 'pending_approval',
          },
          'created_at':
              task['completed_at'] ?? DateTime.now().toIso8601String(),
          'creator_id': completedBy,
        };
      }).toList();
    } catch (error, stackTrace) {
      dev.log(
        'SupabaseDashboardRepository: pending approval activity skipped',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  List<Map<String, dynamic>> _dedupeActivities(
    List<Map<String, dynamic>> activities,
  ) {
    final unique = <String, Map<String, dynamic>>{};

    for (final activity in activities) {
      final type = activity['type'] as String?;
      final data = (activity['data'] as Map<String, dynamic>?) ?? const {};
      final stableId = switch (type) {
        'expense' => data['expense_id']?.toString(),
        'task' => data['task_id']?.toString(),
        'task_pending_approval' => data['task_id']?.toString(),
        _ => null,
      };

      final key = stableId != null && stableId.isNotEmpty
          ? '$type:$stableId'
          : '${activity['id']}';

      final current = unique[key];
      if (current == null ||
          _activityScore(activity) > _activityScore(current)) {
        unique[key] = activity;
      }
    }

    final deduped = unique.values.toList()
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(b['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return deduped;
  }

  int _activityScore(Map<String, dynamic> activity) {
    final data = (activity['data'] as Map<String, dynamic>?) ?? const {};
    final title = (data['title'] ?? '').toString().trim().toLowerCase();
    final description =
        (data['description'] ?? '').toString().trim().toLowerCase();

    var score = 0;
    if (title.isNotEmpty &&
        title != 'nuevo movimiento' &&
        title != 'gasto del hogar') {
      score += 3;
    }
    if (description.isNotEmpty) score += 1;
    if (data['expense_id'] != null || data['task_id'] != null) score += 1;
    if (data['approval_status'] == 'pending_approval') score += 2;
    return score;
  }
}
