/// El fondo compartido del hogar en modo pareja.
///
/// Sustancia distinta a Metas de ahorro: acá son monedas simbólicas que entran
/// por completar tareas, no pesos que se aportan. El copy nunca usa "ahorro",
/// "aporte" ni "$" — se "suma" al fondo. Ver docs/couple-shared-fund-plan.md §3.
library;

enum FundGoalStatus {
  active,
  ready,
  unlocked,
  cancelled;

  factory FundGoalStatus.fromString(String? value) {
    return FundGoalStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => FundGoalStatus.active,
    );
  }
}

class FundGoalConfirmation {
  final String userId;
  final String name;
  final DateTime? confirmedAt;

  const FundGoalConfirmation({
    required this.userId,
    required this.name,
    required this.confirmedAt,
  });

  factory FundGoalConfirmation.fromMap(Map<String, dynamic> map) {
    return FundGoalConfirmation(
      userId: map['user_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      confirmedAt:
          DateTime.tryParse(map['confirmed_at']?.toString() ?? '')?.toLocal(),
    );
  }
}

class FundGoal {
  final String id;
  final String? catalogKey;
  final String title;
  final String icon;
  final int cost;
  final FundGoalStatus status;
  final DateTime createdAt;
  final List<FundGoalConfirmation> confirmations;

  const FundGoal({
    required this.id,
    required this.catalogKey,
    required this.title,
    required this.icon,
    required this.cost,
    required this.status,
    required this.createdAt,
    required this.confirmations,
  });

  bool get isReady => status == FundGoalStatus.ready;

  bool confirmedBy(String? userId) {
    if (userId == null || userId.isEmpty) return false;
    return confirmations.any((c) => c.userId == userId);
  }

  factory FundGoal.fromMap(Map<String, dynamic> map) {
    final rawConfirmations = map['confirmations'];
    return FundGoal(
      id: map['id']?.toString() ?? '',
      catalogKey: map['catalog_key']?.toString(),
      title: map['title']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '🎯',
      cost: (map['cost'] as num?)?.toInt() ?? 0,
      status: FundGoalStatus.fromString(map['status']?.toString()),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      confirmations: rawConfirmations is List
          ? rawConfirmations
              .whereType<Map>()
              .map(
                (item) => FundGoalConfirmation.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const [],
    );
  }
}

class HouseholdFund {
  final String householdId;
  final int balance;
  final int weekEarned;
  final int members;

  /// Semanas activas dentro de la ventana. Deliberadamente no es una racha:
  /// una racha castiga justo las semanas en que la pareja necesita flexibilidad.
  final int rhythmWeeks;
  final int rhythmWindow;
  final FundGoal? goal;

  const HouseholdFund({
    required this.householdId,
    required this.balance,
    required this.weekEarned,
    required this.members,
    required this.rhythmWeeks,
    required this.rhythmWindow,
    required this.goal,
  });

  bool get hasGoal => goal != null;

  /// Progreso hacia la meta activa, acotado a [0,1].
  double get progress {
    final current = goal;
    if (current == null || current.cost <= 0) return 0;
    return (balance / current.cost).clamp(0.0, 1.0).toDouble();
  }

  /// Cuánto falta para llegar. Nunca negativo.
  int get remaining {
    final current = goal;
    if (current == null) return 0;
    final missing = current.cost - balance;
    return missing > 0 ? missing : 0;
  }

  /// Cuántas llaves faltan para el desbloqueo. El ritual necesita a todos los
  /// miembros actuales, no un dos fijo.
  int get pendingConfirmations {
    final current = goal;
    if (current == null || !current.isReady) return 0;
    final missing = members - current.confirmations.length;
    return missing > 0 ? missing : 0;
  }

  factory HouseholdFund.fromMap(Map<String, dynamic> map) {
    final rawGoal = map['goal'];
    return HouseholdFund(
      householdId: map['household_id']?.toString() ?? '',
      balance: (map['balance'] as num?)?.toInt() ?? 0,
      weekEarned: (map['week_earned'] as num?)?.toInt() ?? 0,
      members: (map['members'] as num?)?.toInt() ?? 0,
      rhythmWeeks: (map['rhythm_weeks'] as num?)?.toInt() ?? 0,
      rhythmWindow: (map['rhythm_window'] as num?)?.toInt() ?? 4,
      goal: rawGoal is Map
          ? FundGoal.fromMap(Map<String, dynamic>.from(rawGoal))
          : null,
    );
  }
}

/// Resultado de girar una llave del desbloqueo.
class FundConfirmationOutcome {
  final String goalId;
  final FundGoalStatus status;
  final int confirmations;
  final int members;
  final bool unlocked;
  final String? proposalId;

  const FundConfirmationOutcome({
    required this.goalId,
    required this.status,
    required this.confirmations,
    required this.members,
    required this.unlocked,
    required this.proposalId,
  });

  factory FundConfirmationOutcome.fromMap(Map<String, dynamic> map) {
    return FundConfirmationOutcome(
      goalId: map['goal_id']?.toString() ?? '',
      status: FundGoalStatus.fromString(map['status']?.toString()),
      confirmations: (map['confirmations'] as num?)?.toInt() ?? 0,
      members: (map['members'] as num?)?.toInt() ?? 0,
      unlocked: map['unlocked'] == true,
      proposalId: map['proposal_id']?.toString(),
    );
  }
}

/// Catálogo de metas sugeridas.
///
/// Vive en el cliente y no en la base a propósito: los títulos son copy
/// traducible y ya existe el patrón ARB para eso. El servidor no confía en el
/// costo pero tampoco necesita hacerlo: una meta más barata solo significa que
/// la pareja eligió celebrar antes, no que alguien acuñó moneda.
///
/// Todas son celebraciones: llegar a la meta abre una propuesta, no compra un
/// plan. Los cosméticos premium quedaron fuera adrede — el plan marca en §10
/// que su solape con lo que vende el paywall es una decisión sin tomar.
class FundGoalCatalogItem {
  final String key;
  final String icon;
  final int cost;

  const FundGoalCatalogItem({
    required this.key,
    required this.icon,
    required this.cost,
  });

  static const List<FundGoalCatalogItem> all = [
    FundGoalCatalogItem(key: 'movie_night', icon: '🎬', cost: 150),
    FundGoalCatalogItem(key: 'picnic', icon: '🧺', cost: 200),
    FundGoalCatalogItem(key: 'dinner_out', icon: '🍽️', cost: 300),
    FundGoalCatalogItem(key: 'day_trip', icon: '🚗', cost: 450),
    FundGoalCatalogItem(key: 'weekend_away', icon: '🏝️', cost: 700),
  ];
}
