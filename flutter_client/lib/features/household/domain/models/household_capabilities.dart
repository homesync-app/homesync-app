import 'package:flutter/material.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

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
        // Only warn for genuinely unknown string values. A null input means the
        // household is still loading (valueOrNull) — that's expected during
        // startup and shouldn't pollute logs or signal a backend bug.
        if (type != null) {
          log.w(
            'Unknown HouseholdType received from backend: "$type", falling back to couple',
          );
        }
        return HouseholdType.couple;
    }
  }
}

class HouseholdCapabilities {
  final HouseholdType type;
  final bool tasksEnabled;

  const HouseholdCapabilities({
    required this.type,
    this.tasksEnabled = true,
  });

  bool get showPartnerTab => type != HouseholdType.solo;
  bool get usesCoupleRewardsExperience => type == HouseholdType.couple;
  bool get showExpensesSplit => type != HouseholdType.solo;
  bool get hasSharedTasks => type != HouseholdType.solo;
  bool get showTasks => tasksEnabled;
  bool get showStats => tasksEnabled;
  bool get showLoveNotes => type == HouseholdType.couple;
  bool get showFamilyBoard =>
      type == HouseholdType.family || type == HouseholdType.friends;

  // Mode-aware UI text. Localized via ARB ICU `select` on the type name.
  // Pass `AppLocalizations.of(context)` from the calling widget. Adding new
  // mode-aware labels: define a new key in `app_es.arb` with `select` over
  // {couple, family, friends, solo, other} and add a thin wrapper here.

  String socialTabLabel(AppLocalizations t) =>
      t.householdSocialTabLabel(type.name);

  String socialHubTitle(AppLocalizations t) =>
      t.householdSocialHubTitle(type.name);

  String socialHubSubtitle(AppLocalizations t) =>
      t.householdSocialHubSubtitle(type.name);

  String dashboardGreeting(AppLocalizations t) =>
      t.householdDashboardGreeting(type.name);

  String balanceMessage(AppLocalizations t) =>
      t.householdBalanceMessage(type.name);

  IconData get partnerIcon {
    return switch (type) {
      HouseholdType.solo => Icons.person_rounded,
      HouseholdType.couple => Icons.favorite_rounded,
      HouseholdType.family => Icons.family_restroom_rounded,
      HouseholdType.friends => Icons.group_rounded,
    };
  }

  String emptyStateTasksSubtitle(AppLocalizations t) =>
      t.householdEmptyTasksSubtitle(type.name);

  String memberLabel(AppLocalizations t) => t.householdMemberLabel(type.name);

  String actionMemberLabel(AppLocalizations t) =>
      t.householdActionMemberLabel(type.name);

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
