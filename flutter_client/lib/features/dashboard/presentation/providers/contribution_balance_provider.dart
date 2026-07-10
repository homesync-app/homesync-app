import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';

/// Aporte de un integrante del piso en el mes en curso.
///
/// Modo convivencia: framing NEUTRO de equidad, no de competencia. No hay
/// ranking, corona ni ganador — solo un espejo de "cómo venimos repartidos"
/// entre tareas hechas y plata puesta en gastos compartidos.
class MemberContribution {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  /// Tareas completadas por este integrante en la ventana de stats.
  final int tasksDone;

  /// Total pagado por este integrante en gastos compartidos del mes en curso.
  final double amountPaid;

  const MemberContribution({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.tasksDone,
    required this.amountPaid,
  });
}

/// Resumen del aporte del piso este mes: lista de integrantes con sus tareas y
/// pagos, más totales para poder mostrar proporciones sin rankear.
class ContributionBalance {
  final List<MemberContribution> members;
  final int totalTasks;
  final double totalPaid;

  const ContributionBalance({
    required this.members,
    required this.totalTasks,
    required this.totalPaid,
  });

  bool get isEmpty => totalTasks == 0 && totalPaid == 0;
}

/// Combina dos fuentes ya existentes (sin queries nuevas):
///  - `statsControllerProvider.weeklyRanking`: tareas hechas por miembro.
///  - `combinedFeedControllerProvider`: gastos reales del mes, sumados por payer.
///
/// El objetivo es transparencia entre roomies, no gamificación. Por eso no
/// ordena por "mejor" — el widget consumidor decide la presentación neutra.
final contributionBalanceProvider =
    FutureProvider.autoDispose<ContributionBalance>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) {
    return const ContributionBalance(members: [], totalTasks: 0, totalPaid: 0);
  }

  final stats = await ref.watch(statsControllerProvider.future);
  final feed = await ref.watch(combinedFeedControllerProvider.future);

  final now = DateTime.now();

  // Gastos reales COMPARTIDOS pagados este mes, agrupados por quien pagó.
  // Solo gastos (no ingresos ni liquidaciones: una liquidación es un pago
  // entre roomies, no aporte al hogar) y solo compartidos: los personales
  // del viewer inflarían su propio aporte, y como el feed llega filtrado por
  // privacidad cada roomie vería números distintos.
  final paidByUser = <String, double>{};
  for (final item in feed) {
    if (!item.isRealExpense || item.transactionType != 'expense') continue;
    final split = (item.splitType ?? 'equal').toLowerCase();
    if (split == 'personal' || split == 'gift') continue;
    if (item.date.month != now.month || item.date.year != now.year) continue;
    final payer = item.payerId;
    if (payer.isEmpty) continue;
    paidByUser[payer] = (paidByUser[payer] ?? 0) + item.amount;
  }

  // Tareas hechas por miembro vienen del ranking semanal (mismo dato que ya
  // alimentaba la sección de familia, reusado con framing neutro).
  final byUser = <String, MemberContribution>{};
  for (final row in stats.weeklyRanking) {
    final userId = row['user_id'] as String? ?? '';
    if (userId.isEmpty) continue;
    final name = (row['user_name'] as String? ?? '').trim();
    final tasks = (row['tasks_completed'] as num?)?.toInt() ?? 0;
    byUser[userId] = MemberContribution(
      userId: userId,
      displayName: name.isNotEmpty ? name.split(' ').first : 'Integrante',
      avatarUrl: row['avatar_url'] as String?,
      tasksDone: tasks,
      amountPaid: paidByUser[userId] ?? 0,
    );
  }

  // Integrantes que pagaron pero no figuran en el ranking de tareas igual deben
  // aparecer (pusieron plata aunque no hayan cerrado tareas esta ventana).
  for (final entry in paidByUser.entries) {
    if (byUser.containsKey(entry.key)) continue;
    byUser[entry.key] = MemberContribution(
      userId: entry.key,
      displayName: 'Integrante',
      avatarUrl: null,
      tasksDone: 0,
      amountPaid: entry.value,
    );
  }

  final members = byUser.values.toList(growable: false);
  final totalTasks = members.fold<int>(0, (s, m) => s + m.tasksDone);
  final totalPaid = members.fold<double>(0, (s, m) => s + m.amountPaid);

  return ContributionBalance(
    members: members,
    totalTasks: totalTasks,
    totalPaid: totalPaid,
  );
});
