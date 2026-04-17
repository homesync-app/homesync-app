import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'household_providers.g.dart';

@Riverpod(keepAlive: true)
class HouseholdMembers extends _$HouseholdMembers {
  @override
  Future<List<MemberModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    final currentUserId = ref.read(currentUserIdProvider);
    final admin = ref.read(adminProvider);
    if (householdId == null) {
      log.w(
        'HouseholdMembers.build without householdId viewer=$currentUserId adminQa=${admin.isAdminUser} selectedHousehold=${admin.selectedHouseholdId}',
      );
      return [];
    }

    final repo = ref.read(householdRepositoryProvider);
    final result = await repo.getHouseholdMembersRaw();
    final members = result.fold(
      (failure) => <MemberModel>[],
      (raw) => raw.map((m) => MemberModel.fromMap(m)).toList(),
    );
    log.i(
      'HouseholdMembers.build resolved household=$householdId viewer=$currentUserId count=${members.length} members=${members.map((m) => m.fullDisplayName).toList()} adminQa=${admin.isAdminUser}',
    );
    return members;
  }

  Future<void> refresh() async {
    final householdId = await ref.read(householdIdProvider.future);
    final currentUserId = ref.read(currentUserIdProvider);
    log.i(
      'HouseholdMembers.refresh requested household=$householdId viewer=$currentUserId',
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(householdRepositoryProvider);
      final result = await repo.getHouseholdMembersRaw();
      final members = result.fold(
        (failure) => <MemberModel>[],
        (raw) => raw.map((m) => MemberModel.fromMap(m)).toList(),
      );
      log.i(
        'HouseholdMembers.refresh resolved household=$householdId viewer=$currentUserId count=${members.length} members=${members.map((m) => m.fullDisplayName).toList()}',
      );
      return members;
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
