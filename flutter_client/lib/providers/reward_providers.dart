import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_rpc_service.dart';

final rewardsProvider = AsyncNotifierProvider<RewardsNotifier, List<Map<String, dynamic>>>(() {
  return RewardsNotifier();
});

class RewardsNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  final _rpc = SupabaseRpcService();

  @override
  Future<List<Map<String, dynamic>>> build() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return [];

    final householdMembers = await client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();
    
    if (householdMembers == null) return [];

    final response = await client
        .from('rewards')
        .select()
        .eq('household_id', householdMembers['household_id'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> suggestReward({
    required String title,
    String? description,
    required int cost,
    String icon = '🎁',
  }) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final householdMember = await client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .single();
    
    final householdId = householdMember['household_id'];

    await client.from('rewards').insert({
      'household_id': householdId,
      'title': title,
      'description': description,
      'cost': cost,
      'icon': icon,
      'created_by': user.id,
      'is_approved': false, // Suggestions start as not approved
    });

    await refresh();
  }

  Future<void> approveReward(String rewardId) async {
    final client = Supabase.instance.client;
    await client.from('rewards').update({'is_approved': true}).eq('id', rewardId);
    await refresh();
  }

  Future<void> redeem(String rewardId) async {
    await _rpc.redeemReward(rewardId);
    await refresh();
  }

  Future<void> deleteReward(String rewardId) async {
    final client = Supabase.instance.client;
    await client.from('rewards').delete().eq('id', rewardId);
    await refresh();
  }
}
