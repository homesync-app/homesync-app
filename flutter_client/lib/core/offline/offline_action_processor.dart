import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/core/offline/offline_action.dart';

typedef OfflineRequestProcessor = Future<void> Function(QueuedRequest request);

final offlineActionProcessorProvider =
    Provider<OfflineRequestProcessor>((ref) {
  final client = ref.read(supabaseClientProvider);
  final taskRpc = ref.read(taskRpcServiceProvider);
  return OfflineActionProcessor(client: client, taskRpc: taskRpc).process;
});

class OfflineActionProcessor {
  final SupabaseClient _client;
  final TaskRpcService _taskRpc;

  OfflineActionProcessor({
    required SupabaseClient client,
    required TaskRpcService taskRpc,
  })  : _client = client,
        _taskRpc = taskRpc;

  Future<void> process(QueuedRequest request) async {
    if (request.method != 'ACTION' || request.body == null) {
      throw Exception('Unsupported queued request');
    }

    final action = OfflineAction.fromMap(request.body!);
    final actionType = action.type.isNotEmpty ? action.type : request.endpoint;

    switch (actionType) {
      case OfflineActionType.rpc:
        await _client.rpc(action.target, params: action.params);
        return;
      case OfflineActionType.tableInsert:
        await _client
            .from(action.target)
            .insert(action.values ?? <String, dynamic>{});
        return;
      case OfflineActionType.tableUpsert:
        await _client
            .from(action.target)
            .upsert(action.values ?? <String, dynamic>{});
        return;
      case OfflineActionType.tableUpdate:
        await _applyFilters(
          _client
              .from(action.target)
              .update(action.values ?? <String, dynamic>{}),
          action.filters,
        );
        return;
      case OfflineActionType.tableDelete:
        await _applyFilters(
          _client.from(action.target).delete(),
          action.filters,
        );
        return;
      case OfflineActionType.taskCreate:
        await _processTaskCreate(action);
        return;
      default:
        throw Exception('Unknown offline action: $actionType');
    }
  }

  Future<void> _processTaskCreate(OfflineAction action) async {
    final params = action.params ?? {};
    final description = params['description'] as String?;

    final taskId = await _taskRpc.createTask(
      title: params['title'] as String,
      description: description,
      category: params['category'] as String?,
      assignedTo: params['assignedTo'] as String?,
      type: params['type'] as String? ?? 'one_time',
      difficulty: params['difficulty'] as String? ?? 'medium',
      xpReward: (params['xpReward'] as num?)?.toInt() ?? 0,
      coinReward: (params['coinReward'] as num?)?.toInt() ?? 0,
      priority: params['priority'] as String? ?? 'medium',
      dueAt: params['dueAt'] != null
          ? DateTime.tryParse(params['dueAt'] as String)
          : null,
      recurrenceType: params['recurrenceType'] as String?,
      recurrenceInterval:
          (params['recurrenceInterval'] as num?)?.toInt() ?? 1,
      recurrenceEndAt: params['recurrenceEndAt'] != null
          ? DateTime.tryParse(params['recurrenceEndAt'] as String)
          : null,
    );

    final createdById = action.meta?['created_by_id'] as String?;
    final status = action.meta?['status'] as String?;
    if ((createdById != null && createdById.isNotEmpty) ||
        (status != null && status.isNotEmpty)) {
      final updates = <String, dynamic>{};
      if (createdById != null && createdById.isNotEmpty) {
        updates['created_by_id'] = createdById;
      }
      if (status != null && status.isNotEmpty) {
        updates['status'] = status;
      }
      await _client.from('tasks').update(updates).eq('id', taskId);
    }
  }

  Future<void> _applyFilters(
    PostgrestFilterBuilder<dynamic> query,
    List<OfflineFilter> filters,
  ) async {
    dynamic current = query;
    for (final filter in filters) {
      if (filter.op != 'eq') {
        throw Exception('Unsupported filter op: ${filter.op}');
      }
      current = current.eq(filter.column, filter.value);
    }
    await current;
  }
}
