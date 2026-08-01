/// El reparto honesto de la semana.
///
/// Es la contraparte de haber sacado el desglose por persona del fondo: si el
/// desequilibrio no se ve en el fondo, tiene que verse acá. La lectura busca
/// ser accionable ("las de cocina cayeron siempre del mismo lado") en vez de un
/// puntaje, que es un juicio. Sin ganador, sin ranking, sin corona.
library;

class ContributionMember {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int tasksDone;

  /// Cuántas de las exigentes (dificultad big/heavy) tomó esta persona.
  ///
  /// No hay duración en ninguna parte de `tasks`, así que el reparto no se
  /// expresa en minutos: inventarlos sería fabricar datos. Este es el proxy de
  /// carga que la app ya le muestra al usuario como "qué tan demandante es".
  final int demandingDone;

  const ContributionMember({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.tasksDone,
    required this.demandingDone,
  });

  factory ContributionMember.fromMap(Map<String, dynamic> map) {
    return ContributionMember(
      userId: map['user_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      avatarUrl: map['avatar_url']?.toString(),
      tasksDone: (map['tasks_done'] as num?)?.toInt() ?? 0,
      demandingDone: (map['demanding_done'] as num?)?.toInt() ?? 0,
    );
  }
}

class ContributionCategory {
  final String category;
  final int total;
  final String? dominantUserId;
  final String? dominantName;
  final int dominantCount;

  /// Una persona tomó al menos tres cuartos y hubo suficientes como para que
  /// el patrón signifique algo. Por debajo de eso es ruido, y señalar ruido
  /// convierte un disparador de conversación en una cantaleta.
  final bool skewed;

  const ContributionCategory({
    required this.category,
    required this.total,
    required this.dominantUserId,
    required this.dominantName,
    required this.dominantCount,
    required this.skewed,
  });

  factory ContributionCategory.fromMap(Map<String, dynamic> map) {
    return ContributionCategory(
      category: map['category']?.toString() ?? '',
      total: (map['total'] as num?)?.toInt() ?? 0,
      dominantUserId: map['dominant_user_id']?.toString(),
      dominantName: map['dominant_name']?.toString(),
      dominantCount: (map['dominant_count'] as num?)?.toInt() ?? 0,
      skewed: map['skewed'] == true,
    );
  }
}

class HouseholdContribution {
  final String householdId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalTasks;

  /// Semanas activas dentro de la ventana. Nunca una racha consecutiva: una
  /// racha castiga justo las semanas en que hace falta flexibilidad.
  final int rhythmWeeks;
  final int rhythmWindow;
  final List<ContributionMember> members;
  final List<ContributionCategory> categories;

  const HouseholdContribution({
    required this.householdId,
    required this.weekStart,
    required this.weekEnd,
    required this.totalTasks,
    required this.rhythmWeeks,
    required this.rhythmWindow,
    required this.members,
    required this.categories,
  });

  bool get isEmpty => totalTasks == 0;

  /// Las categorías que se repiten del mismo lado, que son las únicas que vale
  /// la pena nombrar.
  List<ContributionCategory> get skewedCategories =>
      categories.where((category) => category.skewed).toList(growable: false);

  /// Reparto parejo: hubo trabajo y ninguna categoría se cargó de un solo lado.
  bool get isBalanced => !isEmpty && skewedCategories.isEmpty;

  /// Participación de una persona sobre el total, acotada a [0,1].
  double shareOf(ContributionMember member) {
    if (totalTasks <= 0) return 0;
    return (member.tasksDone / totalTasks).clamp(0.0, 1.0).toDouble();
  }

  static List<T> _mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) build,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => build(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  factory HouseholdContribution.fromMap(Map<String, dynamic> map) {
    return HouseholdContribution(
      householdId: map['household_id']?.toString() ?? '',
      weekStart:
          DateTime.tryParse(map['week_start']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      weekEnd:
          DateTime.tryParse(map['week_end']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      totalTasks: (map['total_tasks'] as num?)?.toInt() ?? 0,
      rhythmWeeks: (map['rhythm_weeks'] as num?)?.toInt() ?? 0,
      rhythmWindow: (map['rhythm_window'] as num?)?.toInt() ?? 4,
      members: _mapList(map['members'], ContributionMember.fromMap),
      categories: _mapList(map['categories'], ContributionCategory.fromMap),
    );
  }
}
