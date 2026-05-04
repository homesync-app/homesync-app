import 'package:flutter/material.dart';

enum TourTarget {
  tasksSection,
  balanceCard,
  rewardsTab,
  expensesTab,
}

enum CoachmarkStepKind { welcomeModal, spotlight, infoModal, finale }

enum TooltipPlacement { auto, above, below }

class CoachmarkStep {
  final CoachmarkStepKind kind;
  final String? eyebrow;
  final String title;
  final String body;
  final TourTarget? target;
  final IconData? icon;
  final List<CoachmarkBullet> bullets;
  final String primaryCta;
  final TooltipPlacement placement;

  const CoachmarkStep({
    required this.kind,
    required this.title,
    required this.body,
    required this.primaryCta,
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
