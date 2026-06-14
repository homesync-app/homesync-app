import 'package:flutter/material.dart';

enum TourTarget {
  tasksSection,
  balanceCard,
  rewardsTab,
  expensesTab,
}

enum CoachmarkStepKind { welcomeModal, spotlight, infoModal, finale }

enum TooltipPlacement { auto, above, below }

/// Qué hace el CTA primario del paso. [createTask] abre el flujo real de
/// creación de tareas y, al cerrarse, el tour continúa — la guía no solo
/// muestra: deja el hogar configurado.
enum CoachmarkAction { next, createTask }

/// Estado real del hogar que adapta la guía: copy, pasos y CTAs cambian según
/// el modo del hogar, si hay tareas hoy y cómo configuraron las finanzas.
class HomeTourContext {
  /// true = tour de familia (solo padres/tutores lo ven); false = pareja.
  final bool isFamily;
  final bool hasTasks;

  /// finance_mode == 'shared' (economía integrada, sin deudas entre miembros).
  final bool integratedFinances;

  /// Familia: task_approval_mode != 'off' — los chicos envían para aprobar.
  final bool approvalsOn;

  /// Familia: hay sección de finanzas en el home (2+ adultos).
  final bool hasFinanceSection;

  /// Pareja: nombre del otro miembro para personalizar la bienvenida.
  final String? partnerName;

  const HomeTourContext({
    required this.isFamily,
    required this.hasTasks,
    required this.integratedFinances,
    this.approvalsOn = false,
    this.hasFinanceSection = true,
    this.partnerName,
  });
}

class CoachmarkStep {
  final CoachmarkStepKind kind;
  final String? eyebrow;
  final String title;
  final String body;
  final TourTarget? target;
  final IconData? icon;
  final List<CoachmarkBullet> bullets;
  final String primaryCta;
  final CoachmarkAction primaryAction;

  /// Texto del botón secundario (avanza al siguiente paso). Se usa cuando el
  /// primario es una acción (ej. crear tarea) y el usuario prefiere seguir.
  final String? secondaryCta;
  final TooltipPlacement placement;

  const CoachmarkStep({
    required this.kind,
    required this.title,
    required this.body,
    required this.primaryCta,
    this.primaryAction = CoachmarkAction.next,
    this.secondaryCta,
    this.eyebrow,
    this.target,
    this.icon,
    this.bullets = const [],
    this.placement = TooltipPlacement.auto,
  });
}

class CoachmarkBullet {
  final IconData icon;
  final Color tint;
  final String text;

  const CoachmarkBullet({
    required this.icon,
    required this.tint,
    required this.text,
  });
}
