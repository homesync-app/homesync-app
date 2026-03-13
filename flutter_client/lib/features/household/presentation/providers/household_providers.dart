import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
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
