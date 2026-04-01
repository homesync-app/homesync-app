import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';

class QaSessionService {
  QaSessionService(this._ref);

  final Ref _ref;

  SupabaseAuthService get _auth => _ref.read(authServiceProvider);

  Future<void> signInAsQaUser(
    AdminTestingScenario scenario,
    QaTestUser qaUser,
  ) async {
    final adminNotifier = _ref.read(adminProvider.notifier);

    await _auth.signOut();
    await _auth.signIn(email: qaUser.email, password: qaUser.password);
    await AppIdentityService.instance.refresh();

    adminNotifier.beginRealQaSession(
      scenario: scenario,
      qaUser: qaUser,
    );

    log.i(
      'QA real session started scenario=${scenario.id} email=${qaUser.email} household=${scenario.householdId}',
    );
  }

  Future<void> signInAsAdminPreviewSession({
    required String email,
    required String password,
    String? scenarioId,
    String? viewerUserId,
  }) async {
    final adminNotifier = _ref.read(adminProvider.notifier);

    await _auth.signOut();
    await _auth.signIn(email: email, password: password);
    await AppIdentityService.instance.refresh();

    adminNotifier.activateAutoQaSession(
      scenarioId: scenarioId,
      viewerUserId: viewerUserId,
      useAdminPreviewBaseSession: true,
      adminPreviewBaseEmail: email,
    );

    log.i(
      'QA admin preview session started email=$email scenario=$scenarioId viewer=$viewerUserId',
    );
  }

  Future<void> exitRealQaSession() async {
    await _auth.signOut();
    await AppIdentityService.instance.refresh();
    _ref.read(adminProvider.notifier).endRealQaSession();
    log.i('QA real session closed');
  }
}

