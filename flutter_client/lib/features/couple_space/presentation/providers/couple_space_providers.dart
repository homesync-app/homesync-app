import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/couple_space/data/repositories/couple_space_repository.dart';
import 'package:homesync_client/features/couple_space/domain/couple_money.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_connection_summary.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
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
Future<HouseholdContribution> householdContribution(
  Ref ref,
  String householdId,
) {
  return ref.watch(coupleSpaceRepositoryProvider).getContribution(householdId);
}

/// Lo que puso cada uno este mes, leído del mismo feed que usa Finanzas: sin
/// queries nuevas y con los mismos filtros de privacidad.
@riverpod
Future<CoupleMonthMoney> coupleMonthMoney(Ref ref) async {
  final feed = await ref.watch(combinedFeedControllerProvider.future);
  final household = await ref.watch(currentHouseholdProvider.future);
  final members = await ref.watch(householdMembersProvider.future);
  final currentUserId = ref.watch(currentUserIdProvider);
  final partner =
      members.where((member) => member.userId != currentUserId).firstOrNull;

  return computeCoupleMonthMoney(
    feed: feed,
    now: DateTime.now(),
    currentUserId: currentUserId,
    partnerId: partner?.userId,
    includePersonal: household?.financeMode == 'shared',
  );
}
