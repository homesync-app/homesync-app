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
      case 'roommates':
        return HouseholdType.friends;
      default:
        return HouseholdType.couple;
    }
  }
}

class HouseholdCapabilities {
  final HouseholdType type;

  const HouseholdCapabilities({required this.type});

  bool get showPartnerTab => type != HouseholdType.solo;
  bool get usesCoupleRewardsExperience => type == HouseholdType.couple;
  bool get showExpensesSplit => type != HouseholdType.solo;
  bool get hasSharedTasks => type != HouseholdType.solo;
  bool get showLoveNotes => type == HouseholdType.couple;
  bool get showFamilyBoard =>
      type == HouseholdType.family || type == HouseholdType.friends;

  String get socialTabLabel {
    return switch (type) {
      HouseholdType.solo => 'Mi espacio',
      HouseholdType.couple => 'Pareja',
      HouseholdType.family => 'Familia',
      HouseholdType.friends => 'Convivencia',
    };
  }

  String get socialHubTitle {
    return switch (type) {
      HouseholdType.solo => 'Mi espacio',
      HouseholdType.couple => 'Pareja',
      HouseholdType.family => 'Centro familiar',
      HouseholdType.friends => 'Convivencia',
    };
  }

  String get socialHubSubtitle {
    return switch (type) {
      HouseholdType.solo => 'Todo tu progreso personal en un solo lugar.',
      HouseholdType.couple =>
        'Desafios, premios y pequenas recompensas para compartir.',
      HouseholdType.family =>
        'Coordinacion, miembros y acuerdos del hogar para toda la familia.',
      HouseholdType.friends =>
        'Organizacion, convivencia y reparto claro para el piso.',
    };
  }

  String get dashboardGreeting {
    return switch (type) {
      HouseholdType.solo => 'Mi Progreso',
      HouseholdType.couple => 'Nuestro Hogar',
      _ => 'Hogar Familiar',
    };
  }

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
      HouseholdType.solo => 'Agrega tu primera tarea para organizar tu dia.',
      _ => 'Agreguen su primera tarea para organizar el hogar.',
    };
  }

  String get memberLabel {
    return switch (type) {
      HouseholdType.solo => 'Yo',
      HouseholdType.couple => 'Pareja',
      HouseholdType.family => 'Familia',
      HouseholdType.friends => 'Companeros',
    };
  }

  String get actionMemberLabel {
    return switch (type) {
      HouseholdType.solo => 'conmigo',
      HouseholdType.couple => 'con tu pareja',
      HouseholdType.family => 'con la familia',
      HouseholdType.friends => 'con tus companeros',
    };
  }

  IconData get socialTabIcon {
    return switch (type) {
      HouseholdType.solo => Icons.person_outline,
      HouseholdType.couple => Icons.favorite_outline_rounded,
      HouseholdType.family => Icons.family_restroom_outlined,
      HouseholdType.friends => Icons.group_outlined,
    };
  }

  IconData get socialTabSelectedIcon {
    return switch (type) {
      HouseholdType.solo => Icons.person_rounded,
      HouseholdType.couple => Icons.favorite_rounded,
      HouseholdType.family => Icons.family_restroom_rounded,
      HouseholdType.friends => Icons.group_rounded,
    };
  }
}
