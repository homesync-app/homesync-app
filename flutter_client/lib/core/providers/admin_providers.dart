import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

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
    AppIdentityService.instance.setDebugOverride(
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

  void forceType(HouseholdType? type) {
    state = state.copyWith(forcedHouseholdType: type);
  }

  void openOnboardingPreview() {
    state = state.copyWith(showOnboardingPreview: true);
  }

  void closeOnboardingPreview() {
    state = state.copyWith(showOnboardingPreview: false);
  }
}

final adminProvider =
    NotifierProvider<AdminNotifier, AdminState>(AdminNotifier.new);

bool isAdminPreviewActive(AdminState admin) {
  return AppEnvironment.enableAdminTesting &&
      admin.isAdminUser &&
      !admin.useRealQaSession;
}
