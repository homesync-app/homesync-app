abstract class SettingsRepository {
  /// Resets all user data (tasks, expenses, etc.) but keeps the account and household.
  Future<Map<String, dynamic>> resetUserAccount();

  /// Updates the user's avatar (emoji or premium URL).
  Future<void> updateAvatar(String avatarUrl);

  /// Updates the user's full name.
  Future<void> updateFullName(String name);

  /// Updates the user's notification preference.
  Future<void> updateNotificationSettings(bool enabled);
}
