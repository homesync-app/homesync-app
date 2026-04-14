import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/repository_error_handler.dart';
import 'package:homesync_client/core/offline/offline_storage_service.dart';
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

  bool get _isAdminTestingActive {
    final admin = _ref.read(adminProvider);
    return AppEnvironment.enableAdminTesting &&
        admin.isAdminUser &&
        !admin.useRealQaSession &&
        admin.selectedHouseholdId != null;
  }

  String? get _selectedAdminHouseholdId {
    final admin = _ref.read(adminProvider);
    if (AppEnvironment.enableAdminTesting &&
        admin.isAdminUser &&
        !admin.useRealQaSession) {
      return admin.selectedHouseholdId;
    }
    return null;
  }

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

  Future<Map<String, dynamic>> _requireCurrentHouseholdMembership() async {
    final userId = await _requireCurrentUserId();
    final householdId = _selectedAdminHouseholdId;

    if (householdId != null) {
      log.i(
        'QA Household membership override resolved household=$householdId viewer=$userId',
      );
      return {
        'user_id': userId,
        'household_id': householdId,
        'role': 'owner',
      };
    }

    final householdMember = await _client
        .from(AppConstants.tableHouseholdMembers)
        .select('household_id, role')
        .eq('user_id', userId)
        .maybeSingle();

    if (householdMember == null) {
      throw const HouseholdFailure('No perteneces a ningun hogar');
    }

    return Map<String, dynamic>.from(householdMember);
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
      final householdMember = await _requireCurrentHouseholdMembership();
      final resolvedHouseholdId = householdMember['household_id'] as String?;
      final resolvedViewerId = householdMember['user_id'] as String?;

      late final List<Map<String, dynamic>> members;
      if (_isAdminTestingActive) {
        final response = await _client.rpc(
          'qa_admin_get_household_members',
          params: {'p_household_id': resolvedHouseholdId},
        );

        members = List<Map<String, dynamic>>.from((response as List).map(
          (row) {
            final map = Map<String, dynamic>.from(row as Map);
            return {
              'id': map['id'],
              'user_id': map['user_id'],
              'household_id': map['household_id'],
              'role': map['role'],
              'joined_at': map['joined_at'],
              'display_role': map['display_role'],
              'users': {
                'email': map['email'],
                'full_name': map['full_name'],
                'avatar_url': map['avatar_url'],
                'mercadopago_alias': map['mercadopago_alias'],
              },
            };
          },
        ));
      } else {
        final response = await _client
            .from(AppConstants.tableHouseholdMembers)
            .select(
              'id, user_id, household_id, role, joined_at, display_role, users(full_name, email, avatar_url, mercadopago_alias)',
            )
            .eq('household_id', resolvedHouseholdId!);

        members = List<Map<String, dynamic>>.from(response);
      }

      final names = members
          .map((member) => (member['users'] as Map<String, dynamic>?)?['full_name'])
          .whereType<String>()
          .toList();

      log.i(
        'Household members raw fetched household=$resolvedHouseholdId viewer=$resolvedViewerId count=${members.length} names=$names adminQa=$_isAdminTestingActive',
      );

      // Save to persistence
      if (resolvedHouseholdId != null) {
        try {
          await OfflineStorageService().set(
            'household_members_$resolvedHouseholdId',
            {'members': members},
          );
        } catch (error, stackTrace) {
          log.w(
            'SupabaseHouseholdRepository.getHouseholdMembersRaw: cache persistence skipped: $error',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      return members;
    },
        context: 'SupabaseHouseholdRepository.getHouseholdMembersRaw',
        isOnline: _isOnline,
        onOffline: () async {
          final householdMember = await _requireCurrentHouseholdMembership();
          final resolvedHouseholdId = householdMember['household_id'] as String?;
          final cached = await OfflineStorageService().get('household_members_$resolvedHouseholdId');
          if (cached != null && cached['members'] != null) {
            log.i('SupabaseHouseholdRepository.getHouseholdMembersRaw: Recovered from cache');
            return List<Map<String, dynamic>>.from((cached['members'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
          }
          throw const NetworkFailure('No data in cache');
        });
  }

  @override
  Future<Either<Failure, String>> generateInvitationCode() async {
    return executeWithHandling(() async {
      final householdMember = await _requireCurrentHouseholdMembership();

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
      final householdMember = await _requireCurrentHouseholdMembership();

      if (!_isAdminTestingActive && householdMember['role'] != 'owner') {
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
  Future<Either<Failure, void>> updateTasksEnabled(
    String householdId,
    bool enabled,
  ) async {
    return executeWithHandling(() async {
      await _client
          .from(AppConstants.tableHouseholds)
          .update({'tasks_enabled': enabled}).eq('id', householdId);
    },
        context: 'SupabaseHouseholdRepository.updateTasksEnabled',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, void>> updateMemberDisplayRole(
    String userId,
    String? displayRole,
  ) async {
    return executeWithHandling(() async {
      final householdMember = await _requireCurrentHouseholdMembership();
      await _client
          .from(AppConstants.tableHouseholdMembers)
          .update({'display_role': displayRole})
          .eq('user_id', userId)
          .eq('household_id', householdMember['household_id']);
    },
        context: 'SupabaseHouseholdRepository.updateMemberDisplayRole',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> qaResetScenario(
    String householdId,
  ) async {
    return executeWithHandling(() async {
      final response = await _client.rpc(
        'qa_admin_reset_scenario',
        params: {'p_household_id': householdId},
      );
      return Map<String, dynamic>.from(response as Map);
    },
        context: 'SupabaseHouseholdRepository.qaResetScenario',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> qaAddDummyMember({
    required String householdId,
    required String fullName,
    String? displayRole,
    String? avatarUrl,
    String role = 'member',
  }) async {
    return executeWithHandling(() async {
      final response = await _client.rpc(
        'qa_admin_add_dummy_member',
        params: {
          'p_household_id': householdId,
          'p_full_name': fullName.trim(),
          'p_display_role': displayRole?.trim(),
          'p_avatar_url': avatarUrl?.trim(),
          'p_role': role,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    },
        context: 'SupabaseHouseholdRepository.qaAddDummyMember',
        isOnline: _isOnline);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> qaDeleteDummyMember({
    required String householdId,
    required String userId,
  }) async {
    return executeWithHandling(() async {
      final response = await _client.rpc(
        'qa_admin_delete_dummy_member',
        params: {
          'p_household_id': householdId,
          'p_user_id': userId,
        },
      );
      return Map<String, dynamic>.from(response as Map);
    },
        context: 'SupabaseHouseholdRepository.qaDeleteDummyMember',
        isOnline: _isOnline);
  }
}
