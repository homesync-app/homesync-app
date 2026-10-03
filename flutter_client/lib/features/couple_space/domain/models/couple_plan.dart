import 'package:homesync_client/l10n/generated/app_localizations.dart';

/// Curated invitations, with a permanent shared stamp per distinct plan.
/// IDs are persisted and must stay aligned with the server allowlist.
enum CouplePlan {
  movies,
  cooking,
  picnic,
  coffee,
  walk;

  String title(AppLocalizations t) => switch (this) {
        movies => t.couplePlanMoviesTitle,
        cooking => t.couplePlanCookingTitle,
        picnic => t.couplePlanPicnicTitle,
        coffee => t.couplePlanCoffeeTitle,
        walk => t.couplePlanWalkTitle,
      };

  String description(AppLocalizations t) => switch (this) {
        movies => t.couplePlanMoviesBody,
        cooking => t.couplePlanCookingBody,
        picnic => t.couplePlanPicnicBody,
        coffee => t.couplePlanCoffeeBody,
        walk => t.couplePlanWalkBody,
      };

  String details(AppLocalizations t) => switch (this) {
        movies => t.couplePlanMoviesDetails,
        cooking => t.couplePlanCookingDetails,
        picnic => t.couplePlanPicnicDetails,
        coffee => t.couplePlanCoffeeDetails,
        walk => t.couplePlanWalkDetails,
      };

  String stamp(AppLocalizations t) => switch (this) {
        movies => t.couplePlanMoviesStamp,
        cooking => t.couplePlanCookingStamp,
        picnic => t.couplePlanPicnicStamp,
        coffee => t.couplePlanCoffeeStamp,
        walk => t.couplePlanWalkStamp,
      };

  static CouplePlan? fromId(String id) =>
      values.where((plan) => plan.name == id).firstOrNull;
}

enum CouplePlanAction { save, unsave, complete, undo }

class CouplePlanProgress {
  final String planId;
  final bool saved;
  final DateTime? completedAt;

  const CouplePlanProgress({
    required this.planId,
    this.saved = false,
    this.completedAt,
  });

  bool get completed => completedAt != null;

  factory CouplePlanProgress.fromMap(Map<String, dynamic> row) =>
      CouplePlanProgress(
        planId: row['plan_id'] as String,
        saved: row['saved'] as bool? ?? false,
        completedAt: DateTime.tryParse(row['completed_at'] as String? ?? ''),
      );
}
