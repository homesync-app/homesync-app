import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/household_model.dart';
import '../../domain/repositories/household_repository.dart';
import '../../../../core/constants/app_constants.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseHouseholdRepository(client: client);
});

class SupabaseHouseholdRepository implements HouseholdRepository {
  final SupabaseClient _client;

  SupabaseHouseholdRepository({required SupabaseClient client})
      : _client = client;

  @override
  Future<String?> getHouseholdId(String userId) async {
    final result = await _client
        .from(AppConstants.tableHouseholdMembers)
        .select('household_id')
        .eq('user_id', userId)
        .maybeSingle();
    return result?['household_id'] as String?;
  }

  @override
  Future<HouseholdModel?> getHousehold(String householdId) async {
    final result = await _client
        .from(AppConstants.tableHouseholds)
        .select()
        .eq('id', householdId)
        .maybeSingle();
    if (result == null) return null;
    return HouseholdModel.fromJson(result);
  }

  @override
  Future<List<String>> getMemberIds(String householdId) async {
    final result = await _client
        .from(AppConstants.tableHouseholdMembers)
        .select('user_id')
        .eq('household_id', householdId);
    return (result as List).map((e) => e['user_id'] as String).toList();
  }
}
