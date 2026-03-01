import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

final householdMembersProvider = FutureProvider<List<MemberModel>>((ref) async {
  final rpc = ref.read(rpcServiceProvider);
  final raw = await rpc.getHouseholdMembers();
  return raw.map((m) => MemberModel.fromMap(m)).toList();
});
