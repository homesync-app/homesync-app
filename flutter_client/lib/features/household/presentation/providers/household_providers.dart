import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'household_providers.g.dart';

@Riverpod(keepAlive: true)
class HouseholdMembers extends _$HouseholdMembers {
  @override
  Future<List<MemberModel>> build() async {
    final notifierMembers =
        await ref.watch(householdMembersNotifierProvider.future);
    log.i(
      'HouseholdMembers.build (delegated) count=${notifierMembers.length} members=${notifierMembers.map((m) => m.fullDisplayName).toList()}',
    );
    return notifierMembers;
  }

  Future<void> refresh() async {
    ref.invalidate(householdMembersNotifierProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(householdMembersNotifierProvider.future);
    });
  }
}

@riverpod
Future<HouseholdModel?> currentHousehold(Ref ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return null;

  final repo = ref.read(householdRepositoryProvider);
  final result = await repo.getHousehold(householdId);
  return result.fold(
    (l) => null,
    (r) => r,
  );
}

@riverpod
HouseholdCapabilities householdCapabilities(Ref ref) {
  final admin = ref.watch(adminProvider);
  if (admin.isDeveloperMode && admin.forcedHouseholdType != null) {
    return HouseholdCapabilities(type: admin.forcedHouseholdType!);
  }

  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  return HouseholdCapabilities(
    type: HouseholdType.fromString(household?.householdType),
    tasksEnabled: household?.tasksEnabled ?? true,
  );
}
