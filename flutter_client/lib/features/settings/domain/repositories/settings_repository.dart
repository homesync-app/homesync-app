abstract class SettingsRepository {
  /// Permanently deletes the user's account: purges their data, anonymizes the
  /// users row and stamps deleted_at via the `delete_account` RPC. The caller
  /// is responsible for also deleting the Firebase Auth credential and signing
  /// out. Required by Google Play / App Store account-deletion policy.
  ///
  /// Nota: avatar y nombre se actualizan vía AuthRepository.updateProfile, y
  /// el reset de cuenta vive en HouseholdRepository.resetAndClearHousehold —
  /// este repo quedó solo con el borrado de cuenta.
  Future<Map<String, dynamic>> deleteAccount();
}
