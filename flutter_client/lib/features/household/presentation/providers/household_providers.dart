import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';

final householdMembersProvider = FutureProvider<List<MemberModel>>((ref) async {
  final repo = ref.read(householdRepositoryProvider);
  final raw = await repo.getHouseholdMembersRaw();
  return raw.map((m) => MemberModel.fromMap(m)).toList();
});
