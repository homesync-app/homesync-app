import '../repositories/settings_repository.dart';

class UpdateAvatarUseCase {
  final SettingsRepository _repository;

  UpdateAvatarUseCase(this._repository);

  Future<void> execute(String avatarUrl) async {
    if (avatarUrl.isEmpty) {
      throw Exception('Avatar no puede estar vacío');
    }
    return await _repository.updateAvatar(avatarUrl);
  }
}
