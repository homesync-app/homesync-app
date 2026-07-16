import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';

/// Cache de detalles de gasto (fila completa con pagador + splits) para que
/// el sheet del feed abra ya completo, sin la mini-carga visible de la
/// división. Se precalienta en batch desde MainScreen cada vez que el feed
/// remoto trae gastos nuevos (una sola query para todos los ids que falten).
///
/// Provider manual (no autoDispose) a propósito: MainScreen sostiene un
/// listenManual mientras vive el shell, y el estado se limpia solo al cambiar
/// de hogar. El sheet igual revalida en silencio al abrir, así una edición
/// posterior al precacheo nunca muestra datos viejos por más de un frame.
final expenseDetailCacheProvider =
    NotifierProvider<ExpenseDetailCacheNotifier, Map<String, ExpenseModel>>(
  ExpenseDetailCacheNotifier.new,
);

class ExpenseDetailCacheNotifier extends Notifier<Map<String, ExpenseModel>> {
  /// Ids con fetch en vuelo, para no repetir la query con cada reemisión del
  /// stream del feed (el poll de respaldo reemite la misma lista cada 15s).
  final Set<String> _inFlight = {};

  @override
  Map<String, ExpenseModel> build() {
    // Hogar nuevo = cache inválido (ids de otro household).
    ref.watch(householdIdProvider);
    _inFlight.clear();
    return const {};
  }

  /// Trae en una query los gastos de [expenseIds] que aún no están cacheados.
  /// Fire-and-forget: un fallo de red deja el cache como estaba y el sheet
  /// se enriquece solo al abrir, como antes de existir la precarga.
  Future<void> prefetch(List<String> expenseIds) async {
    final missing = expenseIds
        .where((id) => id.isNotEmpty)
        .where((id) => !state.containsKey(id) && !_inFlight.contains(id))
        .toSet()
        .toList();
    if (missing.isEmpty) return;
    _inFlight.addAll(missing);
    try {
      final result = await ref
          .read(expenseRepositoryProvider)
          .getExpensesWithSplitsByIds(missing);
      result.fold(
        (failure) => log.w(
          'Expense detail prefetch skipped: ${failure.message}',
        ),
        (rows) {
          final fresh = <String, ExpenseModel>{};
          for (final row in rows) {
            try {
              final model = ExpenseModel.fromJson(row);
              fresh[model.id] = model;
            } catch (e) {
              log.w('Expense detail prefetch row unparseable', error: e);
            }
          }
          if (fresh.isEmpty) return;
          state = {...state, ...fresh};
        },
      );
    } finally {
      missing.forEach(_inFlight.remove);
    }
  }

  /// Guarda/actualiza una fila fresca (ej. la que el sheet trajo al abrir),
  /// así reabrir el mismo gasto es instantáneo y con datos al día.
  void put(ExpenseModel expense) {
    state = {...state, expense.id: expense};
  }
}
