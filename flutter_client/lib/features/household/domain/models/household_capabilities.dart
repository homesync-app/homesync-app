import 'package:flutter/material.dart';

enum HouseholdType {
  solo,
  couple,
  family,
  friends;

  factory HouseholdType.fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'solo':
        return HouseholdType.solo;
      case 'couple':
        return HouseholdType.couple;
      case 'family':
        return HouseholdType.family;
      case 'friends':
        return HouseholdType.friends;
      default:
        return HouseholdType.couple;
    }
  }
}

class HouseholdCapabilities {
  final HouseholdType type;

  const HouseholdCapabilities({required this.type});

  // UI Strategy
  bool get showPartnerTab => type != HouseholdType.solo;
  bool get showExpensesSplit => type != HouseholdType.solo;
  bool get hasSharedTasks => type != HouseholdType.solo;
  bool get showLoveNotes => type == HouseholdType.couple;
  bool get showFamilyBoard => type == HouseholdType.family || type == HouseholdType.friends;
  
  // Dashboard Strategy
  String get dashboardGreeting {
    return switch (type) {
      HouseholdType.solo => 'Mi Progreso',
      HouseholdType.couple => 'Nuestro Hogar',
      _ => 'Hogar Familiar',
    };
  }

  // Finance Strategy
  String get balanceMessage {
    return switch (type) {
      HouseholdType.solo => 'Llevas gastado este mes',
      _ => 'Balance acumulado',
    };
  }

  IconData get partnerIcon {
    return switch (type) {
      HouseholdType.solo => Icons.person_rounded,
      HouseholdType.couple => Icons.favorite_rounded,
      HouseholdType.family => Icons.family_restroom_rounded,
      HouseholdType.friends => Icons.group_rounded,
    };
  }

  String get emptyStateTasksSubtitle {
    return switch (type) {
      HouseholdType.solo => 'Agrega tu primera tarea para organizar tu día.',
      _ => 'Agreguen su primera tarea para organizar el hogar.',
    };
  }

  String get memberLabel {
    return switch (type) {
      HouseholdType.solo => 'Yo',
      HouseholdType.couple => 'Pareja',
      HouseholdType.family => 'Familia',
      HouseholdType.friends => 'Amigos',
    };
  }

  String get actionMemberLabel {
    return switch (type) {
      HouseholdType.solo => 'conmigo',
      HouseholdType.couple => 'con tu pareja',
      HouseholdType.family => 'con la familia',
      HouseholdType.friends => 'con el grupo',
    };
  }
}
