import 'package:homesync_client/core/utils/date_extensions.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

bool isTaskCompletedOnLocalDate(TaskModel task, DateTime now) {
  final completedAt = task.lastCompletionAt;
  if (completedAt == null) return false;

  return completedAt.toLocal().isSameDay(now);
}
