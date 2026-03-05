import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

/// Use case: complete a task.
/// Business rules: TaskModel must be active, returns Either with failure or RPC result.
class CompleteTaskUseCase {
  final TaskRepository _repository;
  const CompleteTaskUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(TaskModel task,
      {String? userId}) async {
    if (!task.isActive) {
      return left(ValidationFailure(
          'No se puede completar una tarea que no está activa (status: ${task.status})'));
    }
    return _repository.completeTask(task, userId: userId);
  }
}
