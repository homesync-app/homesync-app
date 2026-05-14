import 'package:homesync_client/l10n/generated/app_localizations.dart';

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
  final bool onboardingCompleted;

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
    this.onboardingCompleted = true,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    final userMap = map['users'] as Map<String, dynamic>?;
    final rawType = map['member_type'] as String?;
    final role = (map['role'] as String? ?? 'member').toLowerCase();
    final rawDisplayRole = map['display_role'] as String?;

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
    } else {
      // Fallback: derive type from display_role text
      final lower = (rawDisplayRole ?? '').toLowerCase();
      if (lower.contains('hijo') ||
          lower.contains('hija') ||
          lower.contains('nino') ||
          lower.contains('nin')) {
        type = MemberType.child;
      } else if (lower.contains('adolesc') || lower.contains('teen')) {
        type = MemberType.teen;
      } else if (lower.contains('tutor') || lower.contains('guard')) {
        type = MemberType.guardian;
      } else {
        type = MemberType.parent;
      }
    }

    return MemberModel(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      householdId: map['household_id'] as String? ?? '',
      role: role,
      joinedAt: DateTime.tryParse(map['joined_at'] as String? ?? '') ??
          DateTime.now(),
      email: userMap?['email'] as String?,
      fullName: userMap?['full_name'] as String?,
      displayRole: rawDisplayRole,
      type: type,
      avatarUrl: userMap?['avatar_url'] as String?,
      mercadopagoAlias: userMap?['mercadopago_alias'] as String?,
      onboardingCompleted: map['onboarding_completed'] as bool? ?? true,
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
      'onboarding_completed': onboardingCompleted,
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
  bool get isAdmin => isOwner || role == 'admin';
  bool get isParent => type == MemberType.parent;
  bool get isGuardian => type == MemberType.guardian;
  bool get isTeen => type == MemberType.teen;
  bool get isChild => type == MemberType.child;
  // Adults in the permissions sense: parents and guardians.
  bool get isAdult => isParent || isGuardian;
  // Parents and guardians can approve / reject pending tasks.
  bool get canApprove => isAdult;
  // Whether this member needs an adult to approve task completions.
  // Mirrors public.should_require_task_approval (see migrations). Source of
  // truth is the server; this getter is for UI gating only — don't show the
  // approval dialog when the server would just complete directly.
  //
  // [approvalMode] is the household's task_approval_mode column.
  bool needsSubmissionApproval(String? approvalMode) {
    switch (approvalMode) {
      case 'all':
        return true;
      case 'children_only':
        return isChild || isTeen;
      case 'per_member':
        // members.requires_task_approval is not cached client-side. Conservative
        // default: assume child/teen need approval; adults don't.
        return isChild || isTeen;
      case 'off':
      default:
        return false;
    }
  }

  bool get canSeeSharedExpenses => isAdult;
  bool get canSeePersonalFinance => isAdult || isTeen;
  bool get canSeeFinanceTab => canSeePersonalFinance;

  /// Solo adultos (parents y guardians) pueden iniciar una compra de premium.
  /// Teens y children nunca deben ver ni acceder al paywall de pago.
  bool get canUpgradePremium => isAdult;

  /// Solo admins/owners adultos pueden gestionar la configuracion del hogar
  /// (Modo Padres, codigo de invitacion, etc.).
  bool get canManageHousehold => isAdmin && isAdult;

  String localizedRoleLabel(AppLocalizations t) {
    if (displayRole != null && displayRole!.trim().isNotEmpty) {
      final lower = displayRole!.toLowerCase().trim();
      if (lower == 'padre' || lower == 'madre' || lower == 'parent') {
        return t.membersRoleParent;
      }
      if (lower == 'tutor' || lower == 'tutora' || lower == 'guardian') {
        return t.membersRoleGuardian;
      }
      if (lower == 'adolescente' || lower == 'teen') {
        return t.membersRoleTeen;
      }
      if (lower == 'hijo' || lower == 'hija' || lower == 'child') {
        return t.membersRoleChild;
      }
      return displayRole!.trim();
    }
    return localizedTypeLabel(t);
  }

  String localizedTypeLabel(AppLocalizations t) {
    switch (type) {
      case MemberType.parent:
        return t.membersRoleParent;
      case MemberType.guardian:
        return t.membersRoleGuardian;
      case MemberType.teen:
        return t.membersRoleTeen;
      case MemberType.child:
        return t.membersRoleChild;
    }
  }

  String get visibleRoleLabel =>
      displayRole?.trim().isNotEmpty == true ? displayRole!.trim() : typeLabel;

  String get typeLabel {
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
