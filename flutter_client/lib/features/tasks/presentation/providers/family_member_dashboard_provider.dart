import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/tasks/domain/models/family_member_dashboard.dart';

/// Sprint 2 Modo Padres: dashboard parental con stats por miembro.
///
/// El periodo es un argumento del provider (family) para que la pantalla pueda
/// alternar entre semana/mes sin invalidar el cache del otro.
final familyMemberDashboardProvider =
    FutureProvider.autoDispose.family<FamilyMemberDashboard?, DashboardPeriod>(
  (ref, period) async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return null;

    final client = ref.watch(supabaseClientProvider);
    try {
      final result = await client.rpc(
        'get_family_member_dashboard',
        params: {
          'p_household_id': householdId,
          'p_period': period.rpcValue,
        },
      );
      if (result is Map) {
        return FamilyMemberDashboard.fromMap(
          Map<String, dynamic>.from(result),
        );
      }
      log.w(
        'get_family_member_dashboard returned unexpected shape: $result',
      );
      return null;
    } catch (e, stack) {
      log.e(
        'get_family_member_dashboard failed',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  },
);
