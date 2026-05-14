class LoveNoteModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const LoveNoteModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory LoveNoteModel.fromJson(Map<String, dynamic> json) {
    return LoveNoteModel(
      id: json['id'] as String,
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  LoveNoteModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return LoveNoteModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
