import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/repository_error_handler.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/household_model.dart';
import '../../domain/repositories/household_repository.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseHouseholdRepository(client: client, ref: ref);
});

class SupabaseHouseholdRepository
    with RepositoryErrorHandler
    implements HouseholdRepository {
  final SupabaseClient _client;
  final Ref _ref;

  SupabaseHouseholdRepository(
      {required SupabaseClient client, required Ref ref})
      : _client = client,
        _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  Future<String> _requireCurrentUserId() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }

    if (!AppEnvironment.usesFirebaseJwtForSupabase) {
      final user = _client.auth.currentUser;
      if (user != null) return user.id;
    }
    throw const AuthFailure();
  }

  @override
  Future<Either<Failure, String?>> getHouseholdId(String userId) async {
    return executeWithHandling(() async {
      final result = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id')
          .eq('user_id', userId)
          .maybeSingle();
      return result?['household_id'] as String?;
    },
        context: 'SupabaseHouseholdRepository.getHouseholdId',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, HouseholdModel?>> getHousehold(
      String householdId) async {
    return executeWithHandling(() async {
      final result = await _client
          .from(AppConstants.tableHouseholds)
          .select()
          .eq('id', householdId)
          .maybeSingle();
      if (result == null) return null;
      return HouseholdModel.fromJson(result);
    },
        context: 'SupabaseHouseholdRepository.getHousehold',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<String>>> getMemberIds(String householdId) async {
    return executeWithHandling(() async {
      final result = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('user_id')
          .eq('household_id', householdId);
      return (result as List).map((e) => e['user_id'] as String).toList();
    },
        context: 'SupabaseHouseholdRepository.getMemberIds',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getHouseholdMembersRaw() async {
    return executeWithHandling(() async {
      final userId = await _requireCurrentUserId();

      final householdMember = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (householdMember == null) return [];

      final response = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select(
            'user_id, role, display_role, users(full_name, email, avatar_url, mercadopago_alias)',
          )
          .eq('household_id', householdMember['household_id']);

      return List<Map<String, dynamic>>.from(response);
    },
        context: 'SupabaseHouseholdRepository.getHouseholdMembersRaw',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, String>> generateInvitationCode() async {
    return executeWithHandling(() async {
      final userId = await _requireCurrentUserId();

      final householdMember = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id, role')
          .eq('user_id', userId)
          .maybeSingle();

      if (householdMember == null) {
        throw const HouseholdFailure('No perteneces a ningun hogar');
      }

      final response = await _client.rpc(
        'generate_household_invitation',
        params: {'p_household_id': householdMember['household_id']},
      );

      return response as String;
    },
        context: 'SupabaseHouseholdRepository.generateInvitationCode',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinHousehold(
      String code) async {
    return executeWithHandling(() async {
      await _requireCurrentUserId();

      final response = await _client.rpc(
        'join_household_by_code',
        params: {'p_code': code.trim().toUpperCase()},
      );

      final result = Map<String, dynamic>.from(response);
      if (result['success'] != true) {
        throw ServerFailure(result['message'] ?? 'Error al unirse al hogar');
      }
      return result;
    },
        context: 'SupabaseHouseholdRepository.joinHousehold',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> resetUserAccount() async {
    return executeWithHandling(() async {
      final response = await _client.rpc('reset_user_account');
      return Map<String, dynamic>.from(response);
    },
        context: 'SupabaseHouseholdRepository.resetUserAccount',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> removeMember(String userId) async {
    return executeWithHandling(() async {
      final currentUserId = await _requireCurrentUserId();

      final householdMember = await _client
          .from(AppConstants.tableHouseholdMembers)
          .select('household_id, role')
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (householdMember == null || householdMember['role'] != 'owner') {
        throw const ServerFailure('Solo el propietario puede quitar miembros');
      }

      await _client
          .from(AppConstants.tableHouseholdMembers)
          .delete()
          .eq('user_id', userId)
          .eq('household_id', householdMember['household_id']);
    },
        context: 'SupabaseHouseholdRepository.removeMember',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> resetAndClearHousehold() async {
    return executeWithHandling(() async {
      final userId = await _requireCurrentUserId();

      final response = await _client.rpc('reset_user_account');
      final result = Map<String, dynamic>.from(response);

      if (result['success'] == true) {
        await _client
            .from(AppConstants.tableHouseholdMembers)
            .delete()
            .eq('user_id', userId);
      }

      return result;
    },
        context: 'SupabaseHouseholdRepository.resetAndClearHousehold',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> updateDefaultSplitRatio(
    String householdId,
    double ratio,
  ) async {
    return executeWithHandling(() async {
      await _client
          .from(AppConstants.tableHouseholds)
          .update({'default_split_ratio': ratio}).eq('id', householdId);
    },
        context: 'SupabaseHouseholdRepository.updateDefaultSplitRatio',
        isOnline: _isOnline);
  }
  
  @override
  Future<Either<Failure, void>> updateHouseholdType(
    String householdId,
    String type,
  ) async {
    return executeWithHandling(() async {
      await _client
          .from(AppConstants.tableHouseholds)
          .update({'household_type': type.toLowerCase()}).eq('id', householdId);
    },
        context: 'SupabaseHouseholdRepository.updateHouseholdType',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> updateMemberDisplayRole(
    String userId,
    String? displayRole,
  ) async {
    return executeWithHandling(() async {
      await _client
          .from(AppConstants.tableHouseholdMembers)
          .update({'display_role': displayRole})
          .eq('user_id', userId);
    },
        context: 'SupabaseHouseholdRepository.updateMemberDisplayRole',
        isOnline: _isOnline);
  }
}
