import '../repositories/task_repository.dart';
import '../models/task_model.dart';

/// Use case: fetch all tasks for a household.
class GetTasksUseCase {
  final TaskRepository _repository;
  const GetTasksUseCase(this._repository);

  Future<List<TaskModel>> call(String householdId) {
    return _repository.getTasks(householdId);
  }
}
