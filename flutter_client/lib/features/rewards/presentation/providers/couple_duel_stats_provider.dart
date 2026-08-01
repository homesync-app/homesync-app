import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';

/// XP propio ganado por día (lunes..domingo) de la semana en curso. Alimenta
/// el "Ritmo semanal" de la card del duelo con datos reales. Lee
/// ledger_entries directo (RLS: cada usuario ve su propio ledger); ante
/// cualquier error devuelve la semana vacía en vez de romper la card.
final weeklyXpByDayProvider = FutureProvider<List<int>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return List.filled(7, 0);

  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));

  try {
    final client = ref.read(supabaseClientProvider);
    final rows = await client
        .from('ledger_entries')
        .select('amount, created_at')
        .eq('user_id', userId)
        .eq('currency', 'XP')
        .gte('created_at', monday.toUtc().toIso8601String());

    final byDay = List<int>.filled(7, 0);
    for (final row in List<Map<String, dynamic>>.from(rows)) {
      final createdAt =
          DateTime.tryParse(row['created_at']?.toString() ?? '')?.toLocal();
      if (createdAt == null || createdAt.isBefore(monday)) continue;
      byDay[createdAt.weekday - 1] += (row['amount'] as num?)?.toInt() ?? 0;
    }
    return byDay;
  } catch (error, stackTrace) {
    log.w(
      'weeklyXpByDayProvider fallback to empty week',
      error: error,
      stackTrace: stackTrace,
    );
    return List.filled(7, 0);
  }
});
