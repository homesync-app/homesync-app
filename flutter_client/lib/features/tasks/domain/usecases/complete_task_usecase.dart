import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

/// Use case: complete a task.
/// Business rules: TaskModel must be active, returns Either with failure or RPC result.
class CompleteTaskUseCase {
  final TaskRepository _repository;
  const CompleteTaskUseCase(this._repository);

  Future<Either<Failure, TaskCompletionResult>> call(TaskModel task,
      {List<String>? userIds}) async {
    if (!task.isActive) {
      return left(ValidationFailure(
          'No se puede completar una tarea que no está activa (status: ${task.status})'));
    }
    return _repository.completeTask(task, userIds: userIds);
  }
}
