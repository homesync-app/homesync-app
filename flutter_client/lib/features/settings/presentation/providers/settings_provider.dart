import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/supabase_settings_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/reset_account_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';

part 'settings_provider.g.dart';

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSettingsRepository(client: client);
}

@riverpod
ResetAccountUseCase resetAccountUseCase(ResetAccountUseCaseRef ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return ResetAccountUseCase(repository);
}

@riverpod
UpdateAvatarUseCase updateAvatarUseCase(UpdateAvatarUseCaseRef ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return UpdateAvatarUseCase(repository);
}

@riverpod
class NotificationEnabled extends _$NotificationEnabled {
  @override
  bool build() => true;

  void toggle(bool value) {
    state = value;
  }
}
