enum MemberType { parent, guardian, teen, child }

class MemberModel {
  final String id;
  final String userId;
  final String householdId;
  final String role;
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
      // Legacy 'adult' rows map to parent until the migration flips them.
      if (rawType == 'adult') {
        type = MemberType.parent;
      } else {
        type = MemberType.values.firstWhere(
          (value) => value.name == rawType,
          orElse: () => MemberType.parent,
        );
      }
    } else if (displayRole.contains('hijo') ||
        displayRole.contains('hija') ||
        displayRole.contains('nino') ||
        displayRole.contains('nin')) {
      type = MemberType.child;
    } else if (displayRole.contains('adolesc') ||
        displayRole.contains('teen')) {
      type = MemberType.teen;
    } else if (displayRole.contains('tutor') ||
        displayRole.contains('guard')) {
      type = MemberType.guardian;
    } else {
      type = MemberType.parent;
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
  bool get isParent => type == MemberType.parent;
  bool get isGuardian => type == MemberType.guardian;
  bool get isTeen => type == MemberType.teen;
  bool get isChild => type == MemberType.child;
  // Adults in the permissions sense: parents and guardians. Teens and
  // children are minors whose completions still need adult review.
  bool get isAdult => isParent || isGuardian;
  // Parents and guardians can approve / reject pending tasks.
  bool get canApprove => isAdult;
  // Teens and children must route their task completions through the
  // adult approval queue instead of marking tasks done directly.
  bool get submissionRequiresApproval => isTeen || isChild;

  String get visibleRoleLabel {
    if (displayRole != null && displayRole!.trim().isNotEmpty) {
      return displayRole!.trim();
    }
    switch (type) {
      case MemberType.parent:
        return 'Padre/Madre';
      case MemberType.guardian:
        return 'Tutor/a';
      case MemberType.teen:
        return 'Adolescente';
      case MemberType.child:
        return 'Hijo/a';
    }
  }

  String get typeLabel {
    switch (type) {
      case MemberType.parent:
        return 'Padre/Madre';
      case MemberType.guardian:
        return 'Tutor';
      case MemberType.teen:
        return 'Adolescente';
      case MemberType.child:
        return 'Hijo';
    }
  }

  String get permissionLabel => isAdmin ? 'Admin' : 'Participa';

  String get roleLabel => visibleRoleLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MemberModel && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'MemberModel(userId: $userId, displayName: $displayName, type: $type)';
}
