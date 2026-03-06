import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/repository_error_handler.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';
import 'package:homesync_client/core/services/rpc/task_rpc_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  final rpc = ref.read(taskRpcServiceProvider);
  return SupabaseTaskRepository(client: client, rpc: rpc, ref: ref);
});

/// Concrete Supabase implementation of TaskRepository.
/// Only this class can talk to Supabase about tasks.
class SupabaseTaskRepository
    with RepositoryErrorHandler
    implements TaskRepository {
  final SupabaseClient _client;
  final TaskRpcService _rpc;
  final Ref _ref;

  SupabaseTaskRepository({
    required SupabaseClient client,
    required TaskRpcService rpc,
    required Ref ref,
  })  : _client = client,
        _rpc = rpc,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  @override
  Future<Either<Failure, List<TaskModel>>> getTasks(String householdId,
      {int limit = 100, int offset = 0}) async {
    return executeWithHandling(() async {
      final raw = await _rpc.getTasks(limit: limit, offset: offset);
      return (raw as List)
          .map((t) => TaskModel.fromMap(t as Map<String, dynamic>))
          .toList();
    }, context: 'SupabaseTaskRepository.getTasks', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeTask(TaskModel task,
      {String? userId}) async {
    return executeWithHandling(() async {
      return _rpc.completeTaskTransaction(
        taskId: task.id,
        taskTitle: task.title,
        xpReward: task.xpReward,
        coinReward: task.coinReward,
        householdId: task.householdId,
        userId: userId,
      );
    }, context: 'SupabaseTaskRepository.completeTask', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> verifyTask(
      String taskId, String verifiedByUserId) async {
    return executeWithHandling(() async {
      await _client.from(AppConstants.tableTasks).update({
        'status': TaskStatus.verified.name,
        'verified_by': verifiedByUserId,
        'verified_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', taskId);
    }, context: 'SupabaseTaskRepository.verifyTask', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> objectTask(
      String taskId, String objectedByUserId) async {
    return executeWithHandling(() async {
      await _client.from(AppConstants.tableTasks).update({
        'status': TaskStatus.objected.name,
        'objected_by': objectedByUserId,
        'objected_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', taskId);
    }, context: 'SupabaseTaskRepository.objectTask', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    return executeWithHandling(() async {
      await _client.from(AppConstants.tableTasks).delete().eq('id', taskId);
    }, context: 'SupabaseTaskRepository.deleteTask', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> updateSchedule(
      String taskId, String? recurrenceType) async {
    return executeWithHandling(() async {
      await _client.from(AppConstants.tableTasks).update({
        'recurrence_type': recurrenceType,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', taskId);
    }, context: 'SupabaseTaskRepository.updateSchedule', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> createTask({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
  }) async {
    return executeWithHandling(() async {
      await _rpc.createTask(
        title: title,
        description: description,
        category: category,
        difficulty: difficulty,
        xpReward: xpReward,
        coinReward: coinReward,
        assignedTo: assignedTo,
        recurrenceType: recurrenceType,
      );
    }, context: 'SupabaseTaskRepository.createTask', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> editTask(
      String taskId, Map<String, dynamic> updates) async {
    return executeWithHandling(() async {
      updates['updated_at'] = DateTime.now().toIso8601String();
      await _client
          .from(AppConstants.tableTasks)
          .update(updates)
          .eq('id', taskId);
    }, context: 'SupabaseTaskRepository.editTask', isOnline: _isOnline);
  }
}
