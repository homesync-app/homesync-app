import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';

/// Qué lectura merece la semana del hogar.
///
/// La prioridad es siempre lo accionable: una categoría que cayó entera del
/// mismo lado se puede charlar y redistribuir; un puntaje general no.
enum CoupleWeekReadingKind {
  /// Todavía no hay tareas completadas en la semana.
  empty,

  /// Hay pocas tareas: todavía no alcanza para leer el reparto, ni para
  /// decir que está parejo.
  early,

  /// Hubo trabajo y ninguna categoría ni el total se cargaron de un lado.
  balanced,

  /// Una categoría concreta la hizo casi toda la misma persona.
  categorySkew,

  /// Ninguna categoría alcanza, pero el total se inclinó claramente.
  overallSkew,
}

/// La única frase que se destaca en el reparto de la semana.
///
/// Nombra un patrón que se puede accionar, nunca un ganador. Quién "lidera"
/// solo sirve para elegir el tono del pedido: si lo hice yo, propongo
/// turnarnos; si lo hizo mi pareja, me ofrezco a tomarlo.
class CoupleWeekReading {
  /// Mínimo de tareas para que el desequilibrio total signifique algo. Con
  /// menos, una sola tarea de diferencia ya parece "casi todo".
  static const int overallMinTasks = 4;

  /// Participación a partir de la cual el total se lee como inclinado.
  static const double overallShareThreshold = 0.75;

  final CoupleWeekReadingKind kind;

  /// Clave cruda de la categoría (`cocina`, `limpieza`…) cuando
  /// [kind] es [CoupleWeekReadingKind.categorySkew].
  final String? category;

  final String? leaderUserId;

  /// Nombre que devolvió el servidor; la UI prefiere el del miembro.
  final String? leaderName;
  final bool leaderIsMe;

  const CoupleWeekReading._({
    required this.kind,
    this.category,
    this.leaderUserId,
    this.leaderName,
    this.leaderIsMe = false,
  });

  static const CoupleWeekReading empty =
      CoupleWeekReading._(kind: CoupleWeekReadingKind.empty);

  static const CoupleWeekReading early =
      CoupleWeekReading._(kind: CoupleWeekReadingKind.early);

  static const CoupleWeekReading balanced =
      CoupleWeekReading._(kind: CoupleWeekReadingKind.balanced);

  bool get isSkewed =>
      kind == CoupleWeekReadingKind.categorySkew ||
      kind == CoupleWeekReadingKind.overallSkew;

  factory CoupleWeekReading.from(
    HouseholdContribution contribution, {
    required String? currentUserId,
  }) {
    if (contribution.isEmpty) return empty;

    // El servidor ya ordena las categorías por total: la primera inclinada es
    // la que más peso tuvo en la semana.
    final skewed = contribution.skewedCategories;
    if (skewed.isNotEmpty) {
      final top = skewed.first;
      return CoupleWeekReading._(
        kind: CoupleWeekReadingKind.categorySkew,
        category: top.category,
        leaderUserId: top.dominantUserId,
        leaderName: top.dominantName,
        leaderIsMe:
            currentUserId != null && top.dominantUserId == currentUserId,
      );
    }

    // Con pocas tareas no hay patrón: decir "parejo" sería tan falso como
    // señalar un desequilibrio.
    if (contribution.totalTasks < overallMinTasks) return early;

    ContributionMember? leader;
    for (final member in contribution.members) {
      if (leader == null || member.tasksDone > leader.tasksDone) {
        leader = member;
      }
    }
    if (leader != null &&
        contribution.shareOf(leader) >= overallShareThreshold) {
      return CoupleWeekReading._(
        kind: CoupleWeekReadingKind.overallSkew,
        leaderUserId: leader.userId,
        leaderName: leader.name,
        leaderIsMe: currentUserId != null && leader.userId == currentUserId,
      );
    }

    return balanced;
  }
}
