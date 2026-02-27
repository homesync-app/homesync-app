class Member {
  final String id; // household_member id
  final String userId;
  final String householdId;
  final String role; // 'owner' | 'member'
  final DateTime joinedAt;
  final String? email;
  final String? fullName;

  final String? avatarUrl;
  final String? mercadopagoAlias;

  const Member({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.role,
    required this.joinedAt,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.mercadopagoAlias,
  });

  factory Member.fromMap(Map<String, dynamic> map) {
    final userMap = map['users'] as Map<String, dynamic>?;
    return Member(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      householdId: map['household_id'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      joinedAt: DateTime.tryParse(map['joined_at'] as String? ?? '') ??
          DateTime.now(),
      email: userMap?['email'] as String?,
      fullName: userMap?['full_name'] as String?,
      avatarUrl: userMap?['avatar_url'] as String?,
      mercadopagoAlias: userMap?['mercadopago_alias'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'household_id': householdId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'users': {
        'full_name': fullName,
        'email': email,
        'avatar_url': avatarUrl,
        'mercadopago_alias': mercadopagoAlias,
      },
    };
  }

  // ── Display helpers ────────────────────────────────────────────────────────

  /// First name or email prefix — for UI chips/labels
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!.split(' ').first;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'Miembro';
  }

  /// Full display name for profile screens
  String get fullDisplayName =>
      fullName ?? email?.split('@').first ?? 'Miembro';

  /// Single uppercase initial for avatars
  String get initial => displayName[0].toUpperCase();

  bool get isOwner => role == 'owner';

  String get roleLabel => isOwner ? 'Propietario' : 'Miembro';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Member && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'Member(userId: $userId, displayName: $displayName)';
}
