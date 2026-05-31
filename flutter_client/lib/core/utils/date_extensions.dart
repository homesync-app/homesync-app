/// Helpers de comparación de fechas reutilizables.
///
/// Consolida la lógica `year == ... && month == ... && day == ...` que estaba
/// duplicada en pantallas de tareas, calendario y finanzas. Comparar siempre en
/// la misma zona horaria evita bugs sutiles cerca de medianoche.
extension DateComparison on DateTime {
  /// `true` si [other] cae en el mismo día calendario (año, mes y día).
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// `true` si esta fecha es hoy (en hora local).
  bool isToday() => toLocal().isSameDay(DateTime.now());

  /// `true` si [other] cae en el mismo mes calendario (año y mes).
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// `true` si esta fecha cae en el mes calendario actual (en hora local).
  bool isCurrentMonth() => toLocal().isSameMonth(DateTime.now());

  /// Versión normalizada a medianoche (sin hora), útil para comparar días.
  DateTime get dateOnly => DateTime(year, month, day);
}
