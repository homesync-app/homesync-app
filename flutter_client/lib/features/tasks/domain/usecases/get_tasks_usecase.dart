import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';

import '../models/task_model.dart';
import '../repositories/task_repository.dart';

/// Use case: fetch all tasks for a household. Returns Either with failure or list.
class GetTasksUseCase {
  final TaskRepository _repository;
  const GetTasksUseCase(this._repository);

  Future<Either<Failure, List<TaskModel>>> call(
    String householdId, {
    int limit = 100,
    int offset = 0,
  }) {
    return _repository.getTasks(householdId, limit: limit, offset: offset);
  }
}
