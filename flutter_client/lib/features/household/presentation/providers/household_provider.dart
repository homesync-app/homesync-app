import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/core/providers/core_providers.dart';

/// Household ID for the current user — single source of truth.
/// All features that need the householdId watch this provider.
final householdIdFeatureProvider = FutureProvider<String?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final repo = ref.read(householdRepositoryProvider);
  return repo.getHouseholdId(userId);
});
