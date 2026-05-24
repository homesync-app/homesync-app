import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

bool isTaskCompletedOnLocalDate(TaskModel task, DateTime now) {
  final completedAt = task.lastCompletionAt;
  if (completedAt == null) return false;

  final localCompletedAt = completedAt.toLocal();
  return localCompletedAt.year == now.year &&
      localCompletedAt.month == now.month &&
      localCompletedAt.day == now.day;
}
