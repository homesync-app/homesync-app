import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/supabase_settings_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/delete_account_usecase.dart';

part 'settings_provider.g.dart';

// keepAlive: repos are session-lived singletons (kept consistent with the other
// feature repos so a future ref-using method can't hit "Cannot use the Ref ...
// after it has been disposed"; see expense/stats repos).
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSettingsRepository(client: client);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(Ref ref) {
  final repository = ref.read(settingsRepositoryProvider);
  final firebaseAuth = ref.read(firebaseAuthServiceProvider);
  return DeleteAccountUseCase(repository, firebaseAuth);
}

/// Preferencia de notificaciones. Lee el estado persistido (misma clave que
/// usa NotificationService al inicializar) y al togglear aplica el efecto
/// real: alta de permisos/token FCM al activar, borrado del token al apagar.
@riverpod
class NotificationEnabled extends _$NotificationEnabled {
  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(kNotificationsEnabledPrefsKey) ?? true;
  }

  Future<void> toggle(bool value) async {
    state = value;
    await ref.read(notificationServiceProvider).setEnabled(value);
  }
}
