import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/services/performance_monitor.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/domain/recent_activity_merge.dart';
import 'package:homesync_client/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Firma de contenido de una lista de actividades del feed. Dos listas con la
/// misma firma son visualmente idénticas: id + type + created_at capturan
/// altas, bajas y reordenamientos (las filas del feed son inmutables una vez
/// creadas; una edición de gasto genera invalidaciones aparte).
String recentActivitySignature(List<Map<String, dynamic>> activities) {
  final buffer = StringBuffer();
  for (final activity in activities) {
    buffer
      ..write(activity['id'])
      ..write('|')
      ..write(activity['type'])
      ..write('|')
      ..write(activity['created_at'])
      ..write(';');
  }
  return buffer.toString();
}

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
    late final StreamController<List<Map<String, dynamic>>> controller;
    RealtimeChannel? channel;
    Timer? debounce;
    var disposed = false;
    String? lastEmittedSignature;

    Future<void> emitLatest() async {
      if (disposed) return;
      try {
        final activities = await getRecentActivity(householdId, userId);
        if (!disposed && !controller.isClosed) {
          // El poll de respaldo reemite la misma lista cada 15-60s; sin esta
          // firma cada tick propaga una lista nueva y el Home visible
          // reconstruye la sección de actividad aunque nada haya cambiado.
          final signature = recentActivitySignature(activities);
          if (signature == lastEmittedSignature) return;
          lastEmittedSignature = signature;
          controller.add(activities);
        }
      } catch (error, stackTrace) {
        dev.log(
          'Recent activity realtime refresh failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (!disposed && !controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    void scheduleRefresh() {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 250), () {
        unawaited(emitLatest());
      });
    }

    Timer? pollTimer;
    var realtimeHealthy = false;

    // Safety net: aunque Realtime no entregue eventos (Causa B histórica
    // con Firebase Third-Party Auth + RLS), el feed se mantiene fresco con
    // un refetch periódico. Con el canal confirmado el poll se relaja a 60s
    // (los cambios llegan por realtime); si el canal se cae vuelve a 15s.
    void restartPoll() {
      pollTimer?.cancel();
      pollTimer = Timer.periodic(
        Duration(seconds: realtimeHealthy ? 60 : 15),
        (_) {
          if (disposed) return;
          scheduleRefresh();
        },
      );
    }

    controller = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        unawaited(emitLatest());
        channel = _client
            .channel('recent_activity:$householdId')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'household_activities',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'household_id',
                value: householdId,
              ),
              callback: (_) => scheduleRefresh(),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'tasks',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'household_id',
                value: householdId,
              ),
              callback: (_) => scheduleRefresh(),
            )
            .subscribe((status, error) {
          if (disposed) return;
          final healthy = status == RealtimeSubscribeStatus.subscribed;
          if (healthy != realtimeHealthy) {
            realtimeHealthy = healthy;
            restartPoll();
          }
        });

        restartPoll();
      },
      onCancel: () {
        disposed = true;
        debounce?.cancel();
        pollTimer?.cancel();
        channel?.unsubscribe();
      },
    );

    return controller.stream;
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

      final response = await PerformanceMonitor.measureFuture(
        'repository.recent_activity.query',
        () async {
          if (_isAdminTestingActive) {
            return _client.rpc(
              'qa_admin_get_recent_activity',
              params: {
                'p_household_id': householdId,
                'p_since': since,
              },
            );
          }

          return _client
              .from('household_activities')
              .select('''
                id, request_id, event_type, title, description, metadata, created_at, user_id,
                user:users!household_activities_user_id_fkey(id, full_name, avatar_url)
              ''')
              .eq('household_id', householdId)
              .gte('created_at', since)
              .order('created_at', ascending: false)
              .limit(30);
        },
        context: {'householdId': householdId},
        warnAfterMs: 700,
      );

      final rows = (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      final tasksMap = await _loadActivityTasks(rows);

      final mappedActivities = rows.map((item) {
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
          final taskId = metadata['task_id'] ?? metadata['id'];
          final task = tasksMap[taskId?.toString()];
          final taskTitle = task?['title'] ??
              metadata['task_title'] ??
              item['title'] ??
              'Tarea del hogar';
          data['title'] = taskTitle;
          data['task_title'] = taskTitle;
          data['title_key'] = task?['title_key'] ?? metadata['title_key'];
          data['task_id'] = taskId;
          data['category'] = metadata['category'] ??
              metadata['task_category'] ??
              metadata['category_name'];
          data['completed_at'] = metadata['completed_at'] ??
              metadata['last_completed_at'] ??
              task?['completed_at'] ??
              task?['last_completed_at'] ??
              item['created_at'];
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
        } else if (eventType == 'couple_challenge_completed') {
          uiType = 'couple_challenge';
          data['title'] = item['title'];
          data['description'] = item['description'];
          data['shared_memory'] = true;
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
          data['title'] =
              metadata['reward_title'] ?? item['title'] ?? 'Premio canjeado';
          data['reward_icon'] = metadata['reward_icon'] ?? metadata['icon'];
          data['reward_cost'] =
              metadata['cost'] ?? metadata['coins'] ?? metadata['coin_cost'];
        } else {
          data['title'] = item['title'] ??
              item['description'] ??
              'Realiz\u00f3 una acci\u00f3n';
        }

        return {
          'id': item['id'],
          'request_id': item['request_id'],
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

          // Los gastos personales (no compartidos) solo viven en las
          // finanzas de su dueño; el feed del hogar muestra únicamente lo
          // que atañe a ambos miembros.
          final shouldShow = isShared || isGift;

          if (kDebugMode) {
            dev.log(
              'Activity Filter Trace [Expense]: title="${data['title']}", isShared=$isShared, isGift=$isGift, creatorId=$creatorId, currentUserId=$userId, results SHOW=$shouldShow',
            );
          }

          return shouldShow;
        }

        return true;
      }).toList();

      final pendingApprovals = _ref.read(parentModeAvailableProvider)
          ? await _getPendingApprovalActivities(householdId, since)
          : const <Map<String, dynamic>>[];
      final activities = dedupeRemoteActivities([
        ...mappedActivities,
        ...pendingApprovals,
      ]);

      dev.log(
        'SupabaseDashboardRepository: Fetched ${activities.length} activities '
        'for household=$householdId since=$since',
      );
      return activities;
    } catch (e) {
      // Propagar en vez de devolver []: una falla de DB debe verse como estado
      // de error (o caer al bootstrap en recentActivityProvider), no como
      // "no hay actividad". El stream la captura en emitLatest via addError.
      dev.log('Error fetching activities: $e');
      rethrow;
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
      // El título de la activity ES el título del gasto (lo escriben los RPCs)
      // y debe ganarle al fallback de categoría: si queda último, un "Netflix"
      // se muestra como "Ocio y planes" en el feed y en el primer frame del
      // detalle (que después "salta" al título/color real al enriquecerse).
      // Los títulos genéricos ('un gasto') ya los descarta el guard de abajo.
      item['title'],
      metadata['description'],
      item['description'],
      metadata['category_name'],
      metadata['category'],
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

  Future<Map<String, Map<String, dynamic>>> _loadActivityTasks(
    List<Map<String, dynamic>> rows,
  ) async {
    final taskIds = rows
        .where((row) => row['event_type'] == 'task_completed')
        .map((row) => Map<String, dynamic>.from(row['metadata'] ?? {}))
        .map((metadata) => metadata['task_id'] ?? metadata['id'])
        .whereType<String>()
        .toSet()
        .toList();

    if (taskIds.isEmpty) return const {};

    final response = await _client
        .from('tasks')
        .select('id, title, title_key')
        .inFilter('id', taskIds);

    return {
      for (final task in response)
        task['id'] as String: Map<String, dynamic>.from(task),
    };
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
          .from('task_approvals')
          .select(
            '''
            id, task_id, task_title, submitted_by, xp_reward, coin_reward, created_at,
            task:tasks!task_approvals_task_id_fkey(id, title, title_key, category, status, completed_at, completed_by)
            ''',
          )
          .eq('household_id', householdId)
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(20);

      final sinceDate = DateTime.tryParse(since);
      final rows = List<Map<String, dynamic>>.from(response).where((approval) {
        final createdAt = DateTime.tryParse(
          approval['created_at'] as String? ?? '',
        );
        if (createdAt == null || sinceDate == null) return true;
        return createdAt.isAfter(sinceDate);
      }).toList();

      final userIds = rows
          .map((approval) => approval['submitted_by'] as String?)
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

      return rows.map((approval) {
        final task = Map<String, dynamic>.from(
          (approval['task'] as Map?) ?? const <String, dynamic>{},
        );
        final submittedBy = approval['submitted_by'] as String?;
        final user = submittedBy != null ? usersMap[submittedBy] : null;
        final title = approval['task_title']?.toString() ??
            task['title']?.toString() ??
            'Tarea del hogar';

        return {
          'id': 'pending-task-${approval['id']}',
          'type': 'task_pending_approval',
          'data': {
            'user_name': user?['full_name'] ?? 'Alguien',
            'avatar_url': user?['avatar_url'],
            'title': title,
            'task_title': title,
            'title_key': task['title_key'],
            'task_id': approval['task_id'],
            'approval_id': approval['id'],
            'category': task['category'],
            'xp_reward': approval['xp_reward'],
            'coins_reward': approval['coin_reward'],
            'approval_status': 'pending_approval',
            'task_status': 'pending_approval',
          },
          'created_at':
              approval['created_at'] ?? DateTime.now().toIso8601String(),
          'creator_id': submittedBy,
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
}
