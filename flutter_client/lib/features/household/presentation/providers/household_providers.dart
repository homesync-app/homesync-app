import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

part 'household_providers.g.dart';

@riverpod
class HouseholdMembers extends _$HouseholdMembers {
  @override
  Future<List<MemberModel>> build() async {
    final householdId = await ref.watch(householdIdProvider.future);
    if (householdId == null) return [];

    final rpc = ref.read(rpcServiceProvider);
    final raw = await rpc.getHouseholdMembers();
    return raw.map((m) => MemberModel.fromMap(m)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final rpc = ref.read(rpcServiceProvider);
      final raw = await rpc.getHouseholdMembers();
      return raw.map((m) => MemberModel.fromMap(m)).toList();
    });
  }
}
