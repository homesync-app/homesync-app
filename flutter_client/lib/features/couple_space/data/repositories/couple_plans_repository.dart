import 'package:homesync_client/features/couple_space/domain/models/couple_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CouplePlansRepository {
  final SupabaseClient client;

  const CouplePlansRepository(this.client);

  Stream<List<CouplePlanProgress>> watchProgress(String householdId) => client
      .from('couple_plan_progress')
      .stream(primaryKey: ['id'])
      .eq('household_id', householdId)
      .map((rows) => rows.map(CouplePlanProgress.fromMap).toList());

  Future<CouplePlanProgress> act(
    String householdId,
    CouplePlan plan,
    CouplePlanAction action,
  ) async {
    final result = await client.rpc(
      'couple_plan_action_v1',
      params: {
        'p_household_id': householdId,
        'p_plan_id': plan.name,
        'p_action': action.name,
      },
    );
    return CouplePlanProgress.fromMap(Map<String, dynamic>.from(result as Map));
  }
}
