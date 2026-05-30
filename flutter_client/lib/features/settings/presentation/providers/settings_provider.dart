import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../auth/data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/supabase_settings_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/reset_account_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';

part 'settings_provider.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSettingsRepository(client: client);
}

@riverpod
ResetAccountUseCase resetAccountUseCase(Ref ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return ResetAccountUseCase(repository);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  final repository = ref.read(settingsRepositoryProvider);
  final firebaseAuth = ref.read(firebaseAuthServiceProvider);
  return DeleteAccountUseCase(repository, firebaseAuth);
}

@riverpod
UpdateAvatarUseCase updateAvatarUseCase(Ref ref) {
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
