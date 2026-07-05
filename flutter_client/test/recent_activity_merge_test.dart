import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/dashboard/domain/recent_activity_merge.dart';

Map<String, dynamic> _activity({
  required String id,
  String type = 'task',
  String? requestId,
  String? activityId,
  String? taskId,
  String? expenseId,
  String? approvalStatus,
  String? creatorId,
  int? rewardCost,
  String title = 'Una tarea',
  required DateTime createdAt,
}) {
  return {
    'id': id,
    'type': type,
    if (requestId != null) 'request_id': requestId,
    if (creatorId != null) 'creator_id': creatorId,
    'created_at': createdAt.toIso8601String(),
    'data': <String, dynamic>{
      'title': title,
      if (activityId != null) 'activity_id': activityId,
      if (taskId != null) 'task_id': taskId,
      if (expenseId != null) 'expense_id': expenseId,
      if (approvalStatus != null) 'approval_status': approvalStatus,
      if (rewardCost != null) 'reward_cost': rewardCost,
    },
  };
}

void main() {
  group('mergeOptimisticActivities', () {
    test('drops the optimistic row once the matching remote id arrives', () {
      final now = DateTime.now();
      final optimistic = [
        _activity(
          id: 'act-1',
          activityId: 'act-1',
          taskId: 't1',
          createdAt: now,
        ),
      ];
      final remote = [
        _activity(id: 'act-1', taskId: 't1', createdAt: now),
      ];

      final merged = mergeOptimisticActivities(optimistic, remote);

      expect(merged, hasLength(1));
      expect(merged.single['id'], 'act-1');
    });

    test('drops an offline optimistic row (no activity_id) by task + time', () {
      final now = DateTime.now();
      final optimistic = [
        _activity(id: 'optimistic-x', taskId: 't1', createdAt: now),
      ];
      final remote = [
        _activity(id: 'remote-1', taskId: 't1', createdAt: now),
      ];

      final merged = mergeOptimisticActivities(optimistic, remote);

      expect(merged, hasLength(1));
      expect(merged.single['id'], 'remote-1');
    });

    test('keeps the optimistic row when there is no matching remote yet', () {
      final now = DateTime.now();
      final optimistic = [
        _activity(id: 'optimistic-x', taskId: 't1', createdAt: now),
      ];

      final merged = mergeOptimisticActivities(optimistic, const []);

      expect(merged, hasLength(1));
      expect(merged.single['id'], 'optimistic-x');
    });

    test(
        'keeps a new optimistic completion next to an older remote one '
        '(repeatable daily task)', () {
      final now = DateTime.now();
      final optimistic = [
        _activity(id: 'optimistic-x', taskId: 't1', createdAt: now),
      ];
      final remote = [
        _activity(
          id: 'remote-earlier',
          taskId: 't1',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ];

      final merged = mergeOptimisticActivities(optimistic, remote);

      expect(merged, hasLength(2));
    });

    test('drops an optimistic reward once the matching remote row arrives', () {
      final now = DateTime.now();
      final optimistic = [
        _activity(
          id: 'optimistic-reward',
          type: 'reward',
          creatorId: 'u1',
          rewardCost: 15,
          title: 'Snack sorpresa',
          createdAt: now,
        ),
      ];
      final remote = [
        _activity(
          id: 'remote-reward',
          type: 'reward',
          creatorId: 'u1',
          rewardCost: 15,
          title: 'Snack sorpresa',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      ];

      final merged = mergeOptimisticActivities(optimistic, remote);

      expect(merged, hasLength(1));
      expect(merged.single['id'], 'remote-reward');
    });
  });

  group('dedupeRemoteActivities', () {
    test('collapses task rows that share a request_id', () {
      final now = DateTime.now();
      final result = dedupeRemoteActivities([
        _activity(id: 'a', requestId: 'req-1', taskId: 't1', createdAt: now),
        _activity(id: 'b', requestId: 'req-1', taskId: 't1', createdAt: now),
      ]);

      expect(result, hasLength(1));
    });

    test('keeps distinct completions of the same task (different request_ids)',
        () {
      final now = DateTime.now();
      final result = dedupeRemoteActivities([
        _activity(id: 'a', requestId: 'req-1', taskId: 't1', createdAt: now),
        _activity(
          id: 'b',
          requestId: 'req-2',
          taskId: 't1',
          createdAt: now.add(const Duration(minutes: 5)),
        ),
      ]);

      expect(result, hasLength(2));
    });

    test('keeps a completion and its pending-approval row as separate items',
        () {
      final now = DateTime.now();
      final result = dedupeRemoteActivities([
        _activity(id: 'a', requestId: 'req-1', taskId: 't1', createdAt: now),
        _activity(
          id: 'pending-t1',
          type: 'task_pending_approval',
          taskId: 't1',
          approvalStatus: 'pending_approval',
          createdAt: now,
        ),
      ]);

      expect(result, hasLength(2));
    });
  });
}
