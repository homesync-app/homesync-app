import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../domain/models/household_model.dart';
import '../../domain/repositories/household_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/repository_error_handler.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseHouseholdRepository(client: client, ref: ref);
});

class SupabaseHouseholdRepository
    with RepositoryErrorHandler
    implements HouseholdRepository {
  final SupabaseClient _client;
  final Ref _ref;

  SupabaseHouseholdRepository({required SupabaseClient client, required Ref ref})
      : _client = client,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  @override
  Future<Either<Failure, String?>> getHouseholdId(String userId) async {
    return executeWithHandling(() async {
      final result = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id')
          .eq('user_id', userId)
          .maybeSingle();
      return result?['household_id'] as String?;
    }, context: 'SupabaseHouseholdRepository.getHouseholdId', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, HouseholdModel?>> getHousehold(String householdId) async {
    return executeWithHandling(() async {
      final result = await _client
          .from(AppConstants.tableHouseholds)
          .select()
          .eq('id', householdId)
          .maybeSingle();
      if (result == null) return null;
      return HouseholdModel.fromJson(result);
    }, context: 'SupabaseHouseholdRepository.getHousehold', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<String>>> getMemberIds(String householdId) async {
    return executeWithHandling(() async {
      final result = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('user_id')
          .eq('household_id', householdId);
      return (result as List).map((e) => e['user_id'] as String).toList();
    }, context: 'SupabaseHouseholdRepository.getMemberIds', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getHouseholdMembersRaw() async {
    return executeWithHandling(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthFailure();

      final householdMember = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (householdMember == null) return [];

      final response = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select(
              'user_id, role, users(full_name, email, avatar_url, mercadopago_alias)')
          .eq('household_id', householdMember['household_id']);

      return List<Map<String, dynamic>>.from(response);
    }, context: 'SupabaseHouseholdRepository.getHouseholdMembersRaw', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, String>> generateInvitationCode() async {
    return executeWithHandling(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthFailure();

      final householdMember = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id, role')
          .eq('user_id', user.id)
          .maybeSingle();

      if (householdMember == null) {
        throw const HouseholdFailure('No perteneces a ningún hogar');
      }

      final response = await _client.rpc(
        'generate_household_invitation',
        params: {'p_household_id': householdMember['household_id']},
      );

      return response as String;
    }, context: 'SupabaseHouseholdRepository.generateInvitationCode', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinHousehold(String code) async {
    return executeWithHandling(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthFailure();

      final response = await _client.rpc(
        'join_household_by_code',
        params: {'p_code': code.trim().toUpperCase()},
      );

      final result = Map<String, dynamic>.from(response);
      if (result['success'] != true) {
        throw ServerFailure(result['message'] ?? 'Error al unirse al hogar');
      }
      return result;
    }, context: 'SupabaseHouseholdRepository.joinHousehold', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> resetUserAccount() async {
    return executeWithHandling(() async {
      final response = await _client.rpc('reset_user_account');
      return Map<String, dynamic>.from(response);
    }, context: 'SupabaseHouseholdRepository.resetUserAccount', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> removeMember(String userId) async {
    return executeWithHandling(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthFailure();

      final householdMember = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id, role')
          .eq('user_id', user.id)
          .maybeSingle();

      if (householdMember == null || householdMember['role'] != 'owner') {
        throw const ServerFailure('Solo el propietario puede quitar miembros');
      }

      await _client
          .from(AppConstants.tableHouseholdMembers)
          .delete()
          .eq('user_id', userId)
          .eq('household_id', householdMember['household_id']);
    }, context: 'SupabaseHouseholdRepository.removeMember', isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> resetAndClearHousehold() async {
    return executeWithHandling(() async {
      final user = _client.auth.currentUser;
      if (user == null) throw const AuthFailure();

      // 1. Reset data via RPC
      final response = await _client.rpc('reset_user_account');
      final result = Map<String, dynamic>.from(response);

      if (result['success'] == true) {
        // 2. Remove from household
        await _client
            .from(AppConstants.tableHouseholdMembers)
            .delete()
            .eq('user_id', user.id);
      }

      return result;
    }, context: 'SupabaseHouseholdRepository.resetAndClearHousehold', isOnline: _isOnline);
  }
}
