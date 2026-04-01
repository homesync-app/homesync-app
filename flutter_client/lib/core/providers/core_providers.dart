import 'package:flutter/foundation.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/qa_session_service.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';

class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final bottomNavIndexProvider = NotifierProvider<BottomNavNotifier, int>(() {
  return BottomNavNotifier();
});

class SocialHubTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index.clamp(0, 1);
  }
}

final socialHubTabIndexProvider = NotifierProvider<SocialHubTabNotifier, int>(() {
  return SocialHubTabNotifier();
});

// Backwards-compatible alias while older rewards screens still reference the
// previous provider name.
final parejaTabIndexProvider = socialHubTabIndexProvider;

// ── Admin / Debug Panel ──────────────────────────────────────────────────────
class AdminState {
  final bool isDeveloperMode;
  final bool isAdminUser;
  final String? impersonatedUserId;
  final String? defaultViewerUserId;
  final String? selectedHouseholdId;
  final String? selectedHouseholdName;
  final String? selectedScenarioId;
  final HouseholdType? forcedHouseholdType;
  final bool showOnboardingPreview;
  final bool useRealQaSession;
  final bool useAdminPreviewBaseSession;
  final String? adminPreviewBaseEmail;
  final String? realQaUserEmail;
  final String? realQaUserLabel;

  const AdminState({
    this.isDeveloperMode = false,
    this.isAdminUser = false,
    this.impersonatedUserId,
    this.defaultViewerUserId,
    this.selectedHouseholdId,
    this.selectedHouseholdName,
    this.selectedScenarioId,
    this.forcedHouseholdType,
    this.showOnboardingPreview = false,
    this.useRealQaSession = false,
    this.useAdminPreviewBaseSession = false,
    this.adminPreviewBaseEmail,
    this.realQaUserEmail,
    this.realQaUserLabel,
  });

  AdminState copyWith({
    bool? isDeveloperMode,
    bool? isAdminUser,
    String? impersonatedUserId,
    String? defaultViewerUserId,
    String? selectedHouseholdId,
    String? selectedHouseholdName,
    String? selectedScenarioId,
    bool clearSelectedHousehold = false,
    HouseholdType? forcedHouseholdType,
    bool? showOnboardingPreview,
    bool? useRealQaSession,
    bool? useAdminPreviewBaseSession,
    String? adminPreviewBaseEmail,
    String? realQaUserEmail,
    String? realQaUserLabel,
  }) {
    return AdminState(
      isDeveloperMode: isDeveloperMode ?? this.isDeveloperMode,
      isAdminUser: isAdminUser ?? this.isAdminUser,
      impersonatedUserId: impersonatedUserId ?? this.impersonatedUserId,
      defaultViewerUserId: clearSelectedHousehold
          ? null
          : (defaultViewerUserId ?? this.defaultViewerUserId),
      selectedHouseholdId: clearSelectedHousehold
          ? null
          : (selectedHouseholdId ?? this.selectedHouseholdId),
      selectedHouseholdName: clearSelectedHousehold
          ? null
          : (selectedHouseholdName ?? this.selectedHouseholdName),
      selectedScenarioId: clearSelectedHousehold
          ? null
          : (selectedScenarioId ?? this.selectedScenarioId),
      forcedHouseholdType: forcedHouseholdType ?? this.forcedHouseholdType,
      showOnboardingPreview:
          showOnboardingPreview ?? this.showOnboardingPreview,
      useRealQaSession: useRealQaSession ?? this.useRealQaSession,
      useAdminPreviewBaseSession:
          useAdminPreviewBaseSession ?? this.useAdminPreviewBaseSession,
      adminPreviewBaseEmail:
          adminPreviewBaseEmail ?? this.adminPreviewBaseEmail,
      realQaUserEmail: realQaUserEmail ?? this.realQaUserEmail,
      realQaUserLabel: realQaUserLabel ?? this.realQaUserLabel,
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  @override
  AdminState build() => const AdminState();

  void toggleDeveloperMode() {
    final newValue = !state.isDeveloperMode;
    state = state.copyWith(isDeveloperMode: newValue);
    if (!newValue) {
      // If turning off developer mode, also reset any impersonation
      state = state.copyWith(
        impersonatedUserId: null,
        clearSelectedHousehold: true,
        forcedHouseholdType: null,
        showOnboardingPreview: false,
      );
      AppIdentityService.instance.setDebugOverride(null, householdId: null);
    }
  }

  void adminLogin() {
    state = state.copyWith(
      isAdminUser: true,
      isDeveloperMode: true,
      defaultViewerUserId: null,
      clearSelectedHousehold: true,
      impersonatedUserId: null,
      forcedHouseholdType: null,
      showOnboardingPreview: false,
      useRealQaSession: false,
      useAdminPreviewBaseSession: false,
      adminPreviewBaseEmail: null,
      realQaUserEmail: null,
      realQaUserLabel: null,
    );
    AppIdentityService.instance.setDebugOverride(null, householdId: null);
    log.i('Admin testing login activated');
  }

  void activateAutoQaSession({
    String? scenarioId,
    String? viewerUserId,
    bool useAdminPreviewBaseSession = false,
    String? adminPreviewBaseEmail,
  }) {
    adminLogin();

    if (useAdminPreviewBaseSession) {
      state = state.copyWith(
        useAdminPreviewBaseSession: true,
        adminPreviewBaseEmail: adminPreviewBaseEmail,
      );
    }

    final scenario = AdminTestingConfig.scenarioById(scenarioId);
    if (scenario == null) {
      return;
    }

    setAdminScenario(scenario);

    if (viewerUserId != null && viewerUserId.isNotEmpty) {
      impersonate(viewerUserId);
    }
  }

  void setAdminScenario(AdminTestingScenario? scenario) {
    state = state.copyWith(
      impersonatedUserId: null,
      defaultViewerUserId: scenario?.defaultViewerUserId,
      selectedHouseholdId: scenario?.householdId,
      selectedHouseholdName: scenario?.title,
      selectedScenarioId: scenario?.id,
      forcedHouseholdType: scenario?.householdType,
      showOnboardingPreview: false,
      clearSelectedHousehold: scenario == null,
    );
    if (!state.useRealQaSession) {
      AppIdentityService.instance.setDebugOverride(
        scenario?.defaultViewerUserId,
        householdId: scenario?.householdId,
      );
    }
    log.i(
      'Admin scenario selected scenario=${scenario?.id} household=${scenario?.householdId} viewer=${scenario?.defaultViewerUserId} type=${scenario?.householdType.name}',
    );
  }

  void impersonate(String? userId) {
    state = state.copyWith(impersonatedUserId: userId);
    AppIdentityService.instance
        .setDebugOverride(
          userId ?? state.defaultViewerUserId,
          householdId: state.selectedHouseholdId,
        );
    log.i(
      'Admin impersonation changed impersonated=$userId fallbackViewer=${state.defaultViewerUserId} selectedHousehold=${state.selectedHouseholdId}',
    );
  }

  void clearAdminSession() {
    state = const AdminState();
    AppIdentityService.instance.setDebugOverride(null, householdId: null);
    log.i('Admin testing session cleared');
  }

  void beginRealQaSession({
    required AdminTestingScenario scenario,
    required QaTestUser qaUser,
  }) {
    state = state.copyWith(
      isAdminUser: true,
      isDeveloperMode: true,
      selectedHouseholdId: scenario.householdId,
      selectedHouseholdName: scenario.title,
      selectedScenarioId: scenario.id,
      forcedHouseholdType: scenario.householdType,
      impersonatedUserId: null,
      defaultViewerUserId: null,
      useRealQaSession: true,
      useAdminPreviewBaseSession: false,
      adminPreviewBaseEmail: null,
      realQaUserEmail: qaUser.email,
      realQaUserLabel: qaUser.label,
      showOnboardingPreview: false,
    );
    AppIdentityService.instance.setDebugOverride(null, householdId: null);
  }

  void endRealQaSession() {
    final fallbackViewer = state.selectedHouseholdId != null
        ? AdminTestingConfig.scenarioByHouseholdId(state.selectedHouseholdId)
            ?.defaultViewerUserId
        : null;
    state = state.copyWith(
      useRealQaSession: false,
      useAdminPreviewBaseSession: false,
      adminPreviewBaseEmail: null,
      realQaUserEmail: null,
      realQaUserLabel: null,
      impersonatedUserId: null,
      defaultViewerUserId: fallbackViewer,
    );
    AppIdentityService.instance.setDebugOverride(
      fallbackViewer,
      householdId: state.selectedHouseholdId,
    );
  }

  void forceType(HouseholdType? type) =>
      state = state.copyWith(forcedHouseholdType: type);

  void openOnboardingPreview() {
    state = state.copyWith(showOnboardingPreview: true);
  }

  void closeOnboardingPreview() {
    state = state.copyWith(showOnboardingPreview: false);
  }
}

final adminProvider =
    NotifierProvider<AdminNotifier, AdminState>(AdminNotifier.new);

final qaSessionServiceProvider = Provider<QaSessionService>((ref) {
  return QaSessionService(ref);
});

// ── Auth state provider ──────────────────────────────────────────────────────
class AppAuthState {
  const AppAuthState({
    required this.isAuthenticated,
    required this.source,
  });

  final bool isAuthenticated;
  final String source;
}

final authStateProvider = StreamProvider<AppAuthState>((ref) {
  final admin = ref.watch(adminProvider);
  if (AppEnvironment.enableAdminTesting &&
      admin.isAdminUser &&
      !admin.useRealQaSession) {
    return Stream.value(
      const AppAuthState(
        isAuthenticated: true,
        source: 'admin_testing',
      ),
    );
  }

  if (AppEnvironment.usesFirebaseJwtForSupabase) {
    return fa.FirebaseAuth.instance.idTokenChanges().map(
          (user) => AppAuthState(
            isAuthenticated: user != null,
            source: 'firebase',
          ),
        );
  }

  return Supabase.instance.client.auth.onAuthStateChange.map(
    (state) => AppAuthState(
      isAuthenticated: state.session != null,
      source: 'supabase',
    ),
  );
});

// ── Singleton service providers ───────────────────────────────────────────────
final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  throw UnimplementedError(
      'authServiceProvider must be overridden in ProviderScope.');
});

final rpcServiceProvider = Provider<SupabaseRpcService>((ref) {
  throw UnimplementedError(
      'rpcServiceProvider must be overridden in ProviderScope.');
});

final appIdentityServiceProvider =
    ChangeNotifierProvider<AppIdentityService>((ref) {
  return AppIdentityService.instance;
});

// ── Current user convenience providers ────────────────────────────────────────
final currentUserIdProvider = Provider<String?>((ref) {
  final admin = ref.watch(adminProvider);
  if (AppEnvironment.enableAdminTesting &&
      admin.isAdminUser &&
      !admin.useRealQaSession) {
    return admin.impersonatedUserId ??
        admin.defaultViewerUserId ??
        AdminTestingConfig.adminTestingUserId;
  }
  final identity = ref.watch(appIdentityServiceProvider);
  return identity.currentUserId;
});

// ── Household ID — single source of truth ─────────────────────────────────────
final householdIdProvider = FutureProvider<String?>((ref) async {
  final admin = ref.watch(adminProvider);
  if (AppEnvironment.enableAdminTesting &&
      admin.isAdminUser &&
      !admin.useRealQaSession) {
    return admin.selectedHouseholdId;
  }

  String? userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    userId = await AppIdentityService.instance.refresh();
    if (userId == null) return null;
  }

  final client = Supabase.instance.client;
  final result = await client
      .from('household_members')
      .select('household_id')
      .eq('user_id', userId)
      .maybeSingle();

  return result?['household_id'] as String?;
});

// ── User profile (full_name, avatar) ──────────────────────────────────────────
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final admin = ref.watch(adminProvider);
  if (AppEnvironment.enableAdminTesting &&
      admin.isAdminUser &&
      !admin.useRealQaSession &&
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

  final client = Supabase.instance.client;
  return await client
      .from('users')
      .select('id, full_name, email, avatar_url, mercadopago_alias, is_admin')
      .eq('id', userId)
      .maybeSingle();
});

// ── Mercado Pago connection status ─────────────────────────────────────────────
final mercadopagoConnectionProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);

  final client = Supabase.instance.client;
  return client
      .from('mercadopago_connections')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .map((data) => data.isNotEmpty ? data.first : null);
});

final mercadopagoMovementsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  // Re-check connection status
  final connection = ref.watch(mercadopagoConnectionProvider).value;
  if (connection == null) return [];

  try {
    final response = await Supabase.instance.client.functions.invoke(
      'mercadopago-api',
      body: {
        'action': 'get_recent_movements',
        'userId': userId,
      },
    );

    if (response.status == 200) {
      final movements =
          (response.data['movements'] as List).cast<Map<String, dynamic>>();
      return movements;
    }
    return [];
  } catch (e) {
    debugPrint('Error fetching MP movements: $e');
    return [];
  }
});

// ── User balance (XP + coins) ─────────────────────────────────────────────────
final userBalanceProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final householdAsync = await ref.watch(householdIdProvider.future);
  if (householdAsync == null) return null;

  final rpc = ref.read(rpcServiceProvider);
  final result = await rpc.getUserBalance(householdId: householdAsync);
  return result['data'] as Map<String, dynamic>?;
});
