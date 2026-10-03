import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/couple_space/data/repositories/couple_plans_repository.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_plan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'couple_plans_providers.g.dart';

@Riverpod(keepAlive: true)
CouplePlansRepository couplePlansRepository(Ref ref) =>
    CouplePlansRepository(ref.watch(supabaseClientProvider));

@riverpod
Stream<List<CouplePlanProgress>> couplePlanProgress(
  Ref ref,
  String householdId,
) =>
    ref.watch(couplePlansRepositoryProvider).watchProgress(householdId);
