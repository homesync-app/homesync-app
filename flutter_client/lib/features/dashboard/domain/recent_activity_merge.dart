/// Pure de-duplication + merge logic for the household activity ("movimientos
/// del hogar") feed. Centralised here so the rules live in ONE tested place
/// instead of being scattered as private helpers across the repository and the
/// provider.
///
/// There are intentionally THREE boundaries, each joining different things — do
/// NOT collapse them into a single key:
///
/// 1. [dedupeRemoteActivities] — within the server-sourced list. A completion
///    can surface both as a `task_completed` row and (in approval households)
///    as a `task_pending_approval` row; this collapses logical duplicates by a
///    stable per-type key, keeping the richest one. Distinct completions of the
///    same task in a day stay separate because each has its own `request_id`.
///
/// 2. [mergeOptimisticActivities] — optimistic (local, pre-confirmation) vs
///    remote (confirmed). An optimistic row is suppressed once its real remote
///    counterpart arrives, matched first by `activity_id`↔`id`, then (for
///    offline rows that never got a server id) by `task_id` + time proximity.
///
/// 3. The optimistic LIST itself is managed by `OptimisticRecentActivity`
///    (see dashboard_provider.dart) — it keeps the local list short and free of
///    its own duplicates before this merge runs.
library;

/// Merges optimistic activities with the confirmed remote feed, suppressing any
/// optimistic row whose real counterpart is already present remotely. Returns
/// the newest-first, capped list ready for the UI.
List<Map<String, dynamic>> mergeOptimisticActivities(
  List<Map<String, dynamic>> optimistic,
  List<Map<String, dynamic>> remote,
) {
  final remoteActivityIds = remote
      .map((activity) => activity['id']?.toString())
      .whereType<String>()
      .toSet();
  final remoteTaskActivities = remote
      .where((activity) => activity['type'] == 'task')
      .map((activity) {
        final data = activity['data'] as Map<String, dynamic>? ?? {};
        final createdAt = DateTime.tryParse(
          activity['created_at']?.toString() ?? '',
        );
        return (taskId: data['task_id']?.toString(), createdAt: createdAt);
      })
      .where((item) => item.taskId != null && item.createdAt != null)
      .toList();
  final remoteRewardActivities = remote
      .where((activity) => activity['type'] == 'reward')
      .map((activity) {
        final data = activity['data'] as Map<String, dynamic>? ?? {};
        final createdAt = DateTime.tryParse(
          activity['created_at']?.toString() ?? '',
        );
        return (
          creatorId: activity['creator_id']?.toString(),
          title: _normalizeComparable(data['title']),
          cost: _readInt(data['reward_cost'] ?? data['cost']),
          createdAt: createdAt,
        );
      })
      .where(
        (item) =>
            item.creatorId != null &&
            item.title.isNotEmpty &&
            item.cost != null &&
            item.createdAt != null,
      )
      .toList();

  final visibleOptimistic = optimistic.where((activity) {
    final data = activity['data'] as Map<String, dynamic>? ?? {};
    final activityId =
        data['activity_id']?.toString() ?? activity['id']?.toString();
    if (activityId != null && remoteActivityIds.contains(activityId)) {
      return false;
    }

    if (activity['type'] == 'reward') {
      final optimisticCreatedAt = DateTime.tryParse(
        activity['created_at']?.toString() ?? '',
      );
      if (optimisticCreatedAt == null) return true;

      final creatorId = activity['creator_id']?.toString();
      final title = _normalizeComparable(data['title']);
      final cost = _readInt(data['reward_cost'] ?? data['cost']);
      if (creatorId == null || title.isEmpty || cost == null) return true;

      return !remoteRewardActivities.any(
        (remoteActivity) =>
            remoteActivity.creatorId == creatorId &&
            remoteActivity.title == title &&
            remoteActivity.cost == cost &&
            !remoteActivity.createdAt!.isBefore(
              optimisticCreatedAt.subtract(const Duration(seconds: 5)),
            ) &&
            !remoteActivity.createdAt!.isAfter(
              optimisticCreatedAt.add(const Duration(minutes: 2)),
            ),
      );
    }

    final taskId = data['task_id']?.toString();
    if (taskId == null) return true;

    final optimisticCreatedAt = DateTime.tryParse(
      activity['created_at']?.toString() ?? '',
    );
    if (optimisticCreatedAt == null) return true;

    // Only suppress an optimistic task if a remote activity for the same task
    // was created at or after this completion. Older completions of repeatable
    // daily tasks must not hide the new optimistic row.
    return !remoteTaskActivities.any(
      (remoteActivity) =>
          remoteActivity.taskId == taskId &&
          !remoteActivity.createdAt!.isBefore(
            optimisticCreatedAt.subtract(const Duration(seconds: 5)),
          ),
    );
  });

  final merged = [...visibleOptimistic, ...remote];
  merged.sort((a, b) {
    final aTime = DateTime.tryParse(a['created_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = DateTime.tryParse(b['created_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    return bTime.compareTo(aTime);
  });

  return merged.take(30).toList();
}

/// Collapses logical duplicates inside the server-sourced activity list (task
/// completions + pending-approval rows), keeping the richest row per identity.
List<Map<String, dynamic>> dedupeRemoteActivities(
  List<Map<String, dynamic>> activities,
) {
  final unique = <String, Map<String, dynamic>>{};

  for (final activity in activities) {
    final type = activity['type'] as String?;
    final data = (activity['data'] as Map<String, dynamic>?) ?? const {};
    final stableId = switch (type) {
      'expense' => data['expense_id']?.toString(),
      'task' =>
        activity['request_id']?.toString() ?? activity['id']?.toString(),
      'task_pending_approval' => data['task_id']?.toString(),
      _ => null,
    };

    final key = stableId != null && stableId.isNotEmpty
        ? '$type:$stableId'
        : '${activity['id']}';

    final current = unique[key];
    if (current == null || _activityScore(activity) > _activityScore(current)) {
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

String _normalizeComparable(Object? value) =>
    (value ?? '').toString().trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

int? _readInt(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw.toString());
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
