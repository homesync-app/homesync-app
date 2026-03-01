import '../models/task_model.dart';
import '../repositories/task_repository.dart';

/// Use case: complete a task.
/// Business rules: TaskModel must be active, returns RPC result with new balances.
class CompleteTaskUseCase {
  final TaskRepository _repository;
  const CompleteTaskUseCase(this._repository);

  Future<Map<String, dynamic>> call(TaskModel task) async {
    if (!task.isActive) {
      throw StateError('No se puede completar una tarea que no está activa (status: ${task.status})');
    }
    return _repository.completeTask(task);
  }
}
