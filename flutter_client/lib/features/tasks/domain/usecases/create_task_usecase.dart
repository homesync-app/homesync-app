import '../repositories/task_repository.dart';

/// Use case: create a new task.
/// Business rules: title and category must be non-empty.
class CreateTaskUseCase {
  final TaskRepository _repository;
  const CreateTaskUseCase(this._repository);

  Future<void> call({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('El título de la tarea no puede estar vacío');
    }
    if (category.trim().isEmpty) {
      throw ArgumentError('La categoría no puede estar vacía');
    }

    await _repository.createTask(
      title: title.trim(),
      description: description,
      category: category,
      difficulty: difficulty,
      xpReward: xpReward,
      coinReward: coinReward,
      assignedTo: assignedTo,
      recurrenceType: recurrenceType,
    );
  }
}
