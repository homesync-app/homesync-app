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

  @override
  Future<List<Map<String, dynamic>>> getHouseholdMembersRaw() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final householdMember = await _client
        .from(AppConstants.tableHouseholdMembers)
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMember == null) return [];

    final response = await _client
        .from(AppConstants.tableHouseholdMembers)
        .select('user_id, role, users(full_name, email, avatar_url, mercadopago_alias)')
        .eq('household_id', householdMember['household_id']);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<String> generateInvitationCode() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final householdMember = await _client
        .from(AppConstants.tableHouseholdMembers)
        .select('household_id, role')
        .eq('user_id', user.id)
        .maybeSingle();

    if (householdMember == null) {
      throw Exception('No perteneces a ningún hogar');
    }

    final response = await _client.rpc(
      'generate_household_invitation',
      params: {'p_household_id': householdMember['household_id']},
    );

    return response as String;
  }

  @override
  Future<Map<String, dynamic>> joinHousehold(String code) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final response = await _client.rpc(
      'join_household_by_code',
      params: {'p_code': code.trim().toUpperCase()},
    );

    final result = Map<String, dynamic>.from(response);
    if (result['success'] != true) {
      throw Exception(result['message'] ?? 'Error al unirse al hogar');
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> resetUserAccount() async {
    final response = await _client.rpc('reset_user_account');
    return Map<String, dynamic>.from(response);
  }
}
