abstract class SettingsRepository {
  /// Resets all user data (tasks, expenses, etc.) but keeps the account and household.
  Future<Map<String, dynamic>> resetUserAccount();

  /// Permanently deletes the user's account: purges their data, anonymizes the
  /// users row and stamps deleted_at via the `delete_account` RPC. The caller
  /// is responsible for also deleting the Firebase Auth credential and signing
  /// out. Required by Google Play / App Store account-deletion policy.
  Future<Map<String, dynamic>> deleteAccount();

  /// Updates the user's avatar (emoji or premium URL).
  Future<void> updateAvatar(String avatarUrl);

  /// Updates the user's full name.
  Future<void> updateFullName(String name);

  /// Updates the user's notification preference.
  Future<void> updateNotificationSettings(bool enabled);
}
