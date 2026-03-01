import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import '../../domain/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  final rpc = ref.read(rpcServiceProvider);
  return SupabaseTaskRepository(client: client, rpc: rpc);
});

/// Concrete Supabase implementation of TaskRepository.
/// Only this class can talk to Supabase about tasks.
class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client;
  final dynamic _rpc; // SupabaseRpcService

  SupabaseTaskRepository({required SupabaseClient client, required dynamic rpc})
      : _client = client,
        _rpc = rpc;

  @override
  Future<List<TaskModel>> getTasks(String householdId) async {
    final raw = await _rpc.getTasks();
    return (raw as List).map((t) => TaskModel.fromMap(t as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> completeTask(TaskModel task) async {
    return _rpc.completeTaskTransaction(
      taskId: task.id,
      taskTitle: task.title,
      xpReward: task.xpReward,
      coinReward: task.coinReward,
      householdId: task.householdId,
    );
  }

  @override
  Future<void> verifyTask(String taskId, String verifiedByUserId) async {
    await _client.from(AppConstants.tableTasks).update({
      'status': 'verified',
      'verified_by': verifiedByUserId,
      'verified_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> objectTask(String taskId, String objectedByUserId) async {
    await _client.from(AppConstants.tableTasks).update({
      'status': 'objected',
      'objected_by': objectedByUserId,
      'objected_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _client.from(AppConstants.tableTasks).delete().eq('id', taskId);
  }

  @override
  Future<void> updateSchedule(String taskId, String? recurrenceType) async {
    await _client.from(AppConstants.tableTasks).update({
      'recurrence_type': recurrenceType,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  @override
  Future<void> createTask({
    required String title,
    String? description,
    required String category,
    required String difficulty,
    required int xpReward,
    required int coinReward,
    String? assignedTo,
    String? recurrenceType,
  }) async {
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
  }

  @override
  Future<void> editTask(String taskId, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _client.from(AppConstants.tableTasks).update(updates).eq('id', taskId);
  }
}
