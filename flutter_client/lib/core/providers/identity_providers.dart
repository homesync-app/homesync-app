import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/admin_providers.dart';
import 'package:homesync_client/core/providers/service_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';

final appIdentityServiceProvider =
    ChangeNotifierProvider<AppIdentityService>((ref) {
  final service = AppIdentityService.instance;
  service.configure(client: ref.read(supabaseClientProvider));
  return service;
});

final currentUserIdProvider = Provider<String?>((ref) {
  final admin = ref.watch(adminProvider);
  if (isAdminPreviewActive(admin)) {
    return admin.impersonatedUserId ??
        admin.defaultViewerUserId ??
        AdminTestingConfig.adminTestingUserId;
  }
  final identity = ref.watch(appIdentityServiceProvider);
  return identity.currentUserId;
});

final householdIdProvider = FutureProvider<String?>((ref) async {
  final admin = ref.watch(adminProvider);
  if (isAdminPreviewActive(admin)) {
    return admin.selectedHouseholdId;
  }

  String? userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    userId = await AppIdentityService.instance.refresh();
    if (userId == null) return null;
  }

  final client = ref.read(supabaseClientProvider);
  final result = await client
      .from('household_members')
      .select('household_id')
      .eq('user_id', userId)
      .maybeSingle();

  return result?['household_id'] as String?;
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final admin = ref.watch(adminProvider);
  if (isAdminPreviewActive(admin) &&
      admin.impersonatedUserId == null &&
      admin.selectedHouseholdId == null) {
    return {
      'id': AdminTestingConfig.adminTestingUserId,
      'full_name': AdminTestingConfig.adminDisplayName,
      'email': AdminTestingConfig.adminEmail,
      'avatar_url': AdminTestingConfig.adminAvatar,
      'mercadopago_alias': null,
      'is_admin': true,
    };
  }

  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final client = ref.read(supabaseClientProvider);
  return await client
      .from('users')
      .select('id, full_name, email, avatar_url, mercadopago_alias, is_admin')
      .eq('id', userId)
      .maybeSingle();
});

final userBalanceProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) return null;

  final rpc = ref.read(rpcServiceProvider);
  final result = await rpc.getUserBalance(householdId: householdId);
  return result['data'] as Map<String, dynamic>?;
});
