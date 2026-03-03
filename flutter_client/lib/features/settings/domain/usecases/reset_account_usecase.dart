import '../repositories/settings_repository.dart';

class ResetAccountUseCase {
  final SettingsRepository _repository;

  ResetAccountUseCase(this._repository);

  Future<Map<String, dynamic>> execute() async {
    return await _repository.resetUserAccount();
  }
}
