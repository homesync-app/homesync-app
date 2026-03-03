import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/supabase_settings_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/reset_account_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return SupabaseSettingsRepository(client: client);
});

final resetAccountUseCaseProvider = Provider<ResetAccountUseCase>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return ResetAccountUseCase(repository);
});

final updateAvatarUseCaseProvider = Provider<UpdateAvatarUseCase>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return UpdateAvatarUseCase(repository);
});
