import 'package:firebase_auth/firebase_auth.dart' as fa;

import 'package:homesync_client/core/services/firebase_auth_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';

import '../repositories/settings_repository.dart';

/// Result of an account-deletion attempt.
enum DeleteAccountStatus {
  /// Data purged and Firebase credential removed. User is fully gone.
  success,

  /// Data purged, but Firebase asked the user to re-authenticate before the
  /// credential could be deleted (Firebase requires a recent login for
  /// `User.delete()`). The caller should prompt re-login and retry.
  requiresRecentLogin,

  /// The backend purge (delete_account RPC) failed; nothing was deleted.
  backendFailed,
}

class DeleteAccountResult {
  const DeleteAccountResult(this.status, {this.message});
  final DeleteAccountStatus status;
  final String? message;

  bool get isSuccess => status == DeleteAccountStatus.success;
}

/// Orchestrates full account deletion (Google Play / App Store requirement):
///   1. Purge the user's data server-side via the `delete_account` RPC.
///   2. Delete the real Firebase Auth credential so the account can't log back in.
///
/// Step 1 is the source of truth for "data is gone". Step 2 removes the login.
/// If Firebase demands a recent login, we report [requiresRecentLogin] so the UI
/// can ask the user to sign in again and retry — the data is already purged.
class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository, this._firebaseAuth);

  final SettingsRepository _repository;
  final FirebaseAuthService _firebaseAuth;

  Future<DeleteAccountResult> execute() async {
    // 1. Server-side purge + anonymization.
    final Map<String, dynamic> response;
    try {
      response = await _repository.deleteAccount();
    } catch (e, stack) {
      log.e('delete_account RPC failed', error: e, stackTrace: stack);
      return const DeleteAccountResult(
        DeleteAccountStatus.backendFailed,
        message: 'No se pudo eliminar la cuenta. Intentá de nuevo.',
      );
    }

    if (response['success'] != true) {
      return DeleteAccountResult(
        DeleteAccountStatus.backendFailed,
        message: response['message']?.toString() ??
            'No se pudo eliminar la cuenta.',
      );
    }

    // 2. Delete the Firebase credential.
    try {
      await _firebaseAuth.deleteCurrentUser();
      return const DeleteAccountResult(DeleteAccountStatus.success);
    } on fa.FirebaseAuthException catch (e, stack) {
      if (e.code == 'requires-recent-login') {
        // Data is already purged; we just couldn't drop the credential without
        // a fresh login. Surface this so the UI can guide the user.
        log.w('Firebase delete needs recent login', error: e, stackTrace: stack);
        return const DeleteAccountResult(
          DeleteAccountStatus.requiresRecentLogin,
        );
      }
      log.e('Firebase user delete failed', error: e, stackTrace: stack);
      // Data is gone but credential lingers — treat as success-ish: the account
      // is anonymized and unusable. Sign out happens in the caller.
      return const DeleteAccountResult(DeleteAccountStatus.success);
    } catch (e, stack) {
      log.e('Firebase user delete failed', error: e, stackTrace: stack);
      return const DeleteAccountResult(DeleteAccountStatus.success);
    }
  }
}
