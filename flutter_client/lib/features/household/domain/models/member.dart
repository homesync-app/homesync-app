enum MemberType { adult, child }

class MemberModel {
  final String id; // household_member id
  final String userId;
  final String householdId;
  final String role; // 'owner' | 'member'
  final DateTime joinedAt;
  final String? email;
  final String? fullName;
  final String? displayRole;
  final MemberType type;
  final String? avatarUrl;
  final String? mercadopagoAlias;

  const MemberModel({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.role,
    required this.joinedAt,
    this.email,
    this.fullName,
    this.displayRole,
    required this.type,
    this.avatarUrl,
    this.mercadopagoAlias,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    final userMap = map['users'] as Map<String, dynamic>?;
    final rawType = map['member_type'] as String?;
    final role = (map['role'] as String? ?? 'member').toLowerCase();
    final displayRole = (map['display_role'] as String? ?? '').toLowerCase();

    final MemberType type;
    if (rawType != null) {
      type = MemberType.values.firstWhere(
        (value) => value.name == rawType,
        orElse: () => MemberType.adult,
      );
    } else if (displayRole.contains('hijo') ||
        displayRole.contains('hija') ||
        displayRole.contains('niñ') ||
        displayRole.contains('nin')) {
      type = MemberType.child;
    } else {
      type = MemberType.adult;
    }

    return MemberModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      householdId: map['household_id'] as String? ?? '',
      role: role,
      joinedAt:
          DateTime.tryParse(map['joined_at'] as String? ?? '') ?? DateTime.now(),
      email: userMap?['email'] as String?,
      fullName: userMap?['full_name'] as String?,
      displayRole: map['display_role'] as String?,
      type: type,
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
      'member_type': type.name,
      'joined_at': joinedAt.toIso8601String(),
      'display_role': displayRole,
      'users': {
        'full_name': fullName,
        'email': email,
        'avatar_url': avatarUrl,
        'mercadopago_alias': mercadopagoAlias,
      },
    };
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!.split(' ').first;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'Miembro';
  }

  String get fullDisplayName =>
      fullName ?? email?.split('@').first ?? 'Miembro';

  String get initial => displayName[0].toUpperCase();

  bool get isOwner => role == 'owner';
  bool get isAdmin => isOwner;
  bool get isAdult => type == MemberType.adult;
  bool get isChild => type == MemberType.child;

  String get roleLabel {
    if (displayRole != null && displayRole!.trim().isNotEmpty) {
      return displayRole!.trim();
    }
    if (isAdmin) return 'Admin del hogar';
    if (isChild) return 'Niño/a';
    if (isAdult) return 'Adulto';
    return 'Integrante';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MemberModel && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'MemberModel(userId: $userId, displayName: $displayName, type: $type)';
}
