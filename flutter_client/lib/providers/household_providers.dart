import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';
import 'core_providers.dart';

final householdMembersProvider = FutureProvider<List<Member>>((ref) async {
  final rpc = ref.read(rpcServiceProvider);
  final raw = await rpc.getHouseholdMembers();
  return raw.map((m) => Member.fromMap(m)).toList();
});
