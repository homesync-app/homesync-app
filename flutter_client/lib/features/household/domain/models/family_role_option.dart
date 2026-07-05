import 'package:flutter/material.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

/// Fuente unica de verdad para los roles familiares editables.
///
/// Cada opcion une de forma indivisible el `display_role` (gendered, lo que se
/// muestra y guarda) con su `member_type` estructural (lo que maneja la logica:
/// permisos, tabs, aprobacion). El picker de rol escribe SIEMPRE ambos juntos
/// con [FamilyRoleOption], evitando que se desincronicen (bug B1: un miembro
/// con display_role="Adolescente" pero member_type="child").
enum FamilyRoleOption {
  father(displayRole: 'Padre', memberType: MemberType.parent),
  mother(displayRole: 'Madre', memberType: MemberType.parent),
  guardianMale(displayRole: 'Tutor', memberType: MemberType.guardian),
  guardianFemale(displayRole: 'Tutora', memberType: MemberType.guardian),
  teen(displayRole: 'Adolescente', memberType: MemberType.teen),
  son(displayRole: 'Hijo', memberType: MemberType.child),
  daughter(displayRole: 'Hija', memberType: MemberType.child);

  const FamilyRoleOption({
    required this.displayRole,
    required this.memberType,
  });

  /// Texto canonico (espaniol) que se guarda en `household_members.display_role`.
  /// `genderedRoleLabel` lo reconoce y lo localiza al mostrarlo.
  final String displayRole;

  /// Tipo estructural que se guarda en `household_members.member_type`.
  final MemberType memberType;

  String label(AppLocalizations t) => switch (this) {
        FamilyRoleOption.father => t.membersRoleFather,
        FamilyRoleOption.mother => t.membersRoleMother,
        FamilyRoleOption.guardianMale => t.membersRoleGuardianMale,
        FamilyRoleOption.guardianFemale => t.membersRoleGuardianFemale,
        FamilyRoleOption.teen => t.membersRoleTeen,
        FamilyRoleOption.son => t.membersRoleSon,
        FamilyRoleOption.daughter => t.membersRoleDaughter,
      };

  IconData get icon => switch (this) {
        FamilyRoleOption.father ||
        FamilyRoleOption.mother =>
          Icons.person_rounded,
        FamilyRoleOption.guardianMale ||
        FamilyRoleOption.guardianFemale =>
          Icons.supervisor_account_rounded,
        FamilyRoleOption.teen => Icons.emoji_people_rounded,
        FamilyRoleOption.son ||
        FamilyRoleOption.daughter =>
          Icons.child_care_rounded,
      };

  /// Resuelve la opcion actual de un miembro priorizando `display_role`
  /// (que lleva el genero). Si no matchea ninguna palabra conocida, devuelve
  /// `null` cuando el genero es ambiguo (ej. parent con "Padre/Madre" generico)
  /// o una opcion por defecto cuando el tipo no tiene genero (teen).
  static FamilyRoleOption? fromMember({
    String? displayRole,
    required MemberType type,
  }) {
    final dr = (displayRole ?? '').toLowerCase().trim();
    for (final option in values) {
      if (option.displayRole.toLowerCase() == dr) return option;
    }
    // Sinonimos calidos que tambien implican genero.
    if (dr == 'papa' || dr == 'papá') return FamilyRoleOption.father;
    if (dr == 'mama' || dr == 'mamá') return FamilyRoleOption.mother;
    return switch (type) {
      MemberType.teen => FamilyRoleOption.teen,
      _ => null,
    };
  }
}
