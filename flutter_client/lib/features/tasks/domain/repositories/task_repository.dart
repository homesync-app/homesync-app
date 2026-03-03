import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/task_model.dart';

/// Abstract contract for the tasks data source.
/// The domain never depends on Supabase — only on this interface.
abstract class TaskRepository {
  /// Fetch tasks for a household with pagination.
  Future<Either<Failure, List<TaskModel>>> getTasks(String householdId, {int limit = 100, int offset = 0});

  /// Mark a TaskModel as completed and award XP/coins via RPC.
  /// Returns the result map from the RPC (new balance, etc.)
  Future<Either<Failure, Map<String, dynamic>>> completeTask(TaskModel task, {String? userId});

  /// Verify a completed TaskModel (done by the other household member).
  Future<Either<Failure, void>> verifyTask(String taskId, String verifiedByUserId);

  /// Object / dispute a completed task.
  Future<Either<Failure, void>> objectTask(String taskId, String objectedByUserId);

  /// Delete a TaskModel permanently.
  Future<Either<Failure, void>> deleteTask(String taskId);

  /// Update the recurrence schedule of a task.
  Future<Either<Failure, void>> updateSchedule(String taskId, String? recurrenceType);

  /// Create a new TaskModel via RPC.
  Future<Either<Failure, void>> createTask({
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
  Future<Either<Failure, void>> editTask(String taskId, Map<String, dynamic> updates);
}
