class TaskCompletionResult {
  final bool success;
  final String message;
  final bool queued;
  final int? xpEarned;
  final int? coinsEarned;
  final String? status;
  final String? requestId;
  final Map<String, dynamic> rawData;

  const TaskCompletionResult({
    required this.success,
    required this.message,
    required this.queued,
    this.xpEarned,
    this.coinsEarned,
    this.status,
    this.requestId,
    this.rawData = const {},
  });

  factory TaskCompletionResult.fromRpcResponse(dynamic response) {
    final data = response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};

    final status = data['status']?.toString();
    final success = data['success'] == true || status == 'ok';

    return TaskCompletionResult(
      success: success,
      message: data['message']?.toString() ?? '',
      queued: data['queued'] == true,
      xpEarned: _asInt(data['xp_earned']),
      coinsEarned: _asInt(data['coins_earned']),
      status: status,
      requestId: data['request_id']?.toString(),
      rawData: data,
    );
  }

  factory TaskCompletionResult.queued({
    required String requestId,
    String message = 'Queued while offline',
  }) {
    return TaskCompletionResult(
      success: true,
      message: message,
      queued: true,
      requestId: requestId,
      rawData: <String, dynamic>{
        'success': true,
        'queued': true,
        'message': message,
        'request_id': requestId,
      },
    );
  }

  /// Sprint 1 Modo Padres: true cuando la submision quedo en `pending_approval`
  /// y los XP/coins se acreditan recien al aprobar. La UI deberia mostrar un
  /// feedback distinto en este caso ("Tu tarea quedo pendiente de aprobacion").
  bool get requiresApproval =>
      status == 'pending_approval' || rawData['requires_approval'] == true;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'queued': queued,
      'xp_earned': xpEarned,
      'coins_earned': coinsEarned,
      'status': status,
      'request_id': requestId,
      'data': rawData,
    };
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
