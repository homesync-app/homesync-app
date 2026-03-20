import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/utils/task_completion_utils.dart';

void main() {
  group('isTaskCompletedOnLocalDate', () {
    TaskModel makeTask({
      DateTime? completedAt,
      String? lastCompletedAt,
    }) {
      return TaskModel(
        id: 'task-1',
        title: 'Test task',
        status: TaskStatus.active,
        xpReward: 10,
        coinReward: 5,
        householdId: 'house-1',
        createdAt: DateTime.utc(2026, 3, 19, 0, 0, 0),
        completedAt: completedAt,
        lastCompletedAt: lastCompletedAt,
      );
    }

    test('returns true when completedAt is the same local day', () {
      final completedAtUtc = DateTime.parse('2026-03-19T01:10:51.429754Z');
      final nowLocal = completedAtUtc.toLocal().add(const Duration(hours: 1));
      final task = makeTask(completedAt: completedAtUtc);

      expect(isTaskCompletedOnLocalDate(task, nowLocal), isTrue);
    });

    test('returns false when completedAt is a different local day', () {
      final completedAtUtc = DateTime.parse('2026-03-19T01:10:51.429754Z');
      final nowOtherDay = completedAtUtc.toLocal().add(const Duration(days: 1));
      final task = makeTask(completedAt: completedAtUtc);

      expect(isTaskCompletedOnLocalDate(task, nowOtherDay), isFalse);
    });

    test('falls back to lastCompletedAt when completedAt is null', () {
      final completedAtUtc = DateTime.parse('2026-03-19T01:10:51.429754Z');
      final nowLocal = completedAtUtc.toLocal();
      final task = makeTask(lastCompletedAt: completedAtUtc.toIso8601String());

      expect(isTaskCompletedOnLocalDate(task, nowLocal), isTrue);
    });
  });
}
