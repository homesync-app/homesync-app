import 'package:homesync_client/core/constants/app_constants.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_household_repository.dart';

part 'household_provider.g.dart';

@Riverpod(keepAlive: true)
class HouseholdMembersNotifier extends _$HouseholdMembersNotifier {
  RealtimeChannel? _channel;

  @override
  Future<List<MemberModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    _setupRealtime(householdId);

    final repo = ref.read(householdRepositoryProvider);
    final result = await repo.getHouseholdMembersRaw();

    return result.fold(
      (l) {
        log.e('Error fetching household members: ${l.message}');
        return [];
      },
      (r) => r.map((m) => MemberModel.fromMap(m)).toList(),
    );
  }

  void _setupRealtime(String householdId) {
    _channel?.unsubscribe();
    final client = ref.read(supabaseClientProvider);

    _channel = client
        .channel('members_realtime_$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: AppConstants.tableHouseholdMembers,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (payload) {
            log.i('Realtime member change detected: ${payload.eventType}');
            ref.invalidateSelf();
          },
        )
        .subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
