import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/tasks/domain/models/weekly_family_summary.dart';

/// Sprint 4 Modo Padres: resumen semanal del hogar.
///
/// `p_week_start` queda en null para que el server use el lunes de la semana
/// actual. La UI solo necesita la version mas reciente; si quisieramos un
/// historial habria que armar otro provider.
final weeklyFamilySummaryProvider =
    FutureProvider.autoDispose<WeeklyFamilySummary?>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return null;

  final client = ref.watch(supabaseClientProvider);
  try {
    final result = await client.rpc(
      'get_weekly_family_summary',
      params: {'p_household_id': householdId},
    );
    if (result is Map) {
      return WeeklyFamilySummary.fromMap(
        Map<String, dynamic>.from(result),
      );
    }
    log.w('get_weekly_family_summary returned unexpected shape: $result');
    return null;
  } catch (e, stack) {
    log.e(
      'get_weekly_family_summary failed',
      error: e,
      stackTrace: stack,
    );
    return null;
  }
});
