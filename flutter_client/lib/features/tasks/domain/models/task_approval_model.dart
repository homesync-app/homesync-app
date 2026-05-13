/// Sprint 1 Modo Padres: aprobacion pendiente de una tarea completada.
///
/// Una fila por intento de completion. La RPC `get_pending_approvals` devuelve
/// solo las pendientes; las aprobadas/rechazadas quedan en la tabla para
/// auditoria pero no se traen al cliente.
class TaskApprovalModel {
  final String approvalId;
  final String taskId;
  final String taskTitle;
  final String submittedBy;
  final String submittedByName;
  final List<String> performers;
  final int xpReward;
  final int coinReward;
  final DateTime createdAt;

  const TaskApprovalModel({
    required this.approvalId,
    required this.taskId,
    required this.taskTitle,
    required this.submittedBy,
    required this.submittedByName,
    required this.performers,
    required this.xpReward,
    required this.coinReward,
    required this.createdAt,
  });

  factory TaskApprovalModel.fromMap(Map<String, dynamic> map) {
    final performersRaw = map['performers'];
    return TaskApprovalModel(
      approvalId: map['approval_id'] as String,
      taskId: map['task_id'] as String,
      taskTitle: (map['task_title'] as String?) ?? '',
      submittedBy: map['submitted_by'] as String,
      submittedByName: (map['submitted_by_name'] as String?) ?? 'Miembro',
      performers: performersRaw is List
          ? performersRaw.map((e) => e.toString()).toList()
          : const <String>[],
      xpReward: (map['xp_reward'] as num?)?.toInt() ?? 0,
      coinReward: (map['coin_reward'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
