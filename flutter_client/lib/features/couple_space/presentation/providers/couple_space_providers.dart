import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/couple_space/data/repositories/couple_space_repository.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_connection_summary.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_fund.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'couple_space_providers.g.dart';

@Riverpod(keepAlive: true)
CoupleSpaceRepository coupleSpaceRepository(Ref ref) {
  return CoupleSpaceRepository(ref.watch(supabaseClientProvider));
}

@riverpod
Future<CoupleConnectionSummary> coupleConnectionSummary(
  Ref ref,
  String householdId,
) {
  return ref.watch(coupleSpaceRepositoryProvider).getSummary(householdId);
}

@riverpod
Stream<List<CoupleProposal>> coupleProposals(
  Ref ref,
  String householdId,
) {
  return ref.watch(coupleSpaceRepositoryProvider).watchProposals(householdId);
}

@riverpod
Future<HouseholdFund> householdFund(
  Ref ref,
  String householdId,
) {
  return ref.watch(coupleSpaceRepositoryProvider).getFund(householdId);
}
