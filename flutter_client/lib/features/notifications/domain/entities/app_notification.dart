class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;

  /// Datos estructurados escritos por los RPCs/triggers (actor, título,
  /// monto, etc.). La UI los usa para localizar por [type]; si faltan
  /// (filas legadas o tipos desconocidos) se cae al [title]/[body] crudos.
  final Map<String, dynamic>? params;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.params,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'];
    return AppNotification(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? 'Notificacion',
      body: (json['body'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'generic',
      params: rawParams is Map
          ? Map<String, dynamic>.from(rawParams)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] == true,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? params,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      params: params ?? this.params,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
