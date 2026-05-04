import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../repositories/task_repository.dart';

/// Use case: create a new task.
/// Business rules: title and category must be non-empty. Returns Either with failure or void.
class CreateTaskUseCase {
  final TaskRepository _repository;
  const CreateTaskUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
    int? recurrenceInterval,
    List<int>? recurrenceWeekdays,
    List<int>? recurrenceMonthDays,
    String? status,
    List<String>? rotationPool,
  }) async {
    if (title.trim().isEmpty) {
      return left(const ValidationFailure(
          'El título de la tarea no puede estar vacío',),);
    }
    if (category.trim().isEmpty) {
      return left(const ValidationFailure('La categoría no puede estar vacía'));
    }

    return _repository.createTask(
      title: title.trim(),
      description: description,
      category: category,
      difficulty: difficulty,
      xpReward: xpReward,
      coinReward: coinReward,
      assignedTo: assignedTo,
      recurrenceType: recurrenceType,
      recurrenceInterval: recurrenceInterval,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMonthDays: recurrenceMonthDays,
      status: status,
      rotationPool: rotationPool,
    );
  }
}
