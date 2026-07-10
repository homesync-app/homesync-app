import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mesada mensual programada (adulto → teen). Ver
/// supabase/migrations/20260710230000_recurring_allowance_v1.sql.
class AllowanceScheduleModel {
  final String id;
  final String householdId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final int dayOfMonth;
  final String? note;

  const AllowanceScheduleModel({
    required this.id,
    required this.householdId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.dayOfMonth,
    required this.note,
  });

  factory AllowanceScheduleModel.fromJson(Map<String, dynamic> json) {
    return AllowanceScheduleModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String? ?? '',
      fromUserId: json['from_user_id'] as String? ?? '',
      toUserId: json['to_user_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      dayOfMonth: (json['day_of_month'] as num?)?.toInt() ?? 1,
      note: json['note'] as String?,
    );
  }
}

/// Mesadas programadas ACTIVAS que envío yo (adulto emisor).
final myAllowanceSchedulesProvider =
    FutureProvider.autoDispose<List<AllowanceScheduleModel>>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  final userId = ref.watch(currentUserIdProvider);
  if (householdId == null || userId == null) {
    return const <AllowanceScheduleModel>[];
  }

  final rows = await Supabase.instance.client
      .from('allowance_schedules')
      .select()
      .eq('household_id', householdId)
      .eq('from_user_id', userId)
      .eq('is_active', true);

  return (rows as List<dynamic>)
      .whereType<Map>()
      .map(
        (row) =>
            AllowanceScheduleModel.fromJson(Map<String, dynamic>.from(row)),
      )
      .toList(growable: false);
});

// keepAlive: mutaciones que sobreviven al cierre del sheet (trampa del Ref
// disposed, mismo patrón que el resto de finanzas).
final allowanceScheduleMutationsProvider =
    Provider(AllowanceScheduleMutations.new);

class AllowanceScheduleMutations {
  final Ref _ref;

  AllowanceScheduleMutations(this._ref);

  /// Crea (o reemplaza) la mesada mensual hacia [toUserId]. Marca el mes en
  /// curso como corrido: el envío inmediato lo hace transfer_to_member — el
  /// cron arranca recién el mes que viene.
  Future<void> upsert({
    required String toUserId,
    required double amount,
    required int dayOfMonth,
    String? note,
  }) async {
    final householdId = await _ref.read(householdIdProvider.future);
    final userId = _ref.read(currentUserIdProvider);
    if (householdId == null || userId == null) return;

    final client = Supabase.instance.client;
    // Reemplazo del par activo (unique parcial from+to where is_active).
    await client
        .from('allowance_schedules')
        .update({'is_active': false})
        .eq('from_user_id', userId)
        .eq('to_user_id', toUserId)
        .eq('is_active', true);

    final now = DateTime.now();
    final monthStart =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-01';
    await client.from('allowance_schedules').insert({
      'household_id': householdId,
      'from_user_id': userId,
      'to_user_id': toUserId,
      'amount': amount,
      'day_of_month': dayOfMonth,
      'note': note,
      'last_run_month': monthStart,
    });
    log.i('Allowance schedule upserted to=$toUserId day=$dayOfMonth');
    _ref.invalidate(myAllowanceSchedulesProvider);
  }

  Future<void> deactivate(String id) async {
    await Supabase.instance.client
        .from('allowance_schedules')
        .update({'is_active': false}).eq('id', id);
    log.i('Allowance schedule deactivated id=$id');
    _ref.invalidate(myAllowanceSchedulesProvider);
  }
}
