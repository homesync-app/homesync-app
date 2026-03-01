import '../models/task_model.dart';

/// Abstract contract for the tasks data source.
/// The domain never depends on Supabase — only on this interface.
abstract class TaskRepository {
  /// Fetch all tasks for a household.
  Future<List<TaskModel>> getTasks(String householdId);

  /// Mark a TaskModel as completed and award XP/coins via RPC.
  /// Returns the result map from the RPC (new balance, etc.)
  Future<Map<String, dynamic>> completeTask(TaskModel task);

  /// Verify a completed TaskModel (done by the other household member).
  Future<void> verifyTask(String taskId, String verifiedByUserId);

  /// Object / dispute a completed task.
  Future<void> objectTask(String taskId, String objectedByUserId);

  /// Delete a TaskModel permanently.
  Future<void> deleteTask(String taskId);

  /// Update the recurrence schedule of a task.
  Future<void> updateSchedule(String taskId, String? recurrenceType);

  /// Create a new TaskModel via RPC.
  Future<void> createTask({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
  });

  /// Edit an existing TaskModel's fields.
  Future<void> editTask(String taskId, Map<String, dynamic> updates);
}
