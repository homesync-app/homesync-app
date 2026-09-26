import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/providers/theme_provider.dart'
    show sharedPreferencesProvider;
import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/core/services/install_referrer_service.dart';
import 'package:homesync_client/core/services/notification_service.dart';
import 'package:homesync_client/core/services/review_prompt_service.dart';
import 'package:homesync_client/core/services/shopping_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/services/template_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    supabaseClient: ref.read(supabaseClientProvider),
  );
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final shoppingServiceProvider = Provider<ShoppingService>((ref) {
  return ShoppingService(
    supabaseClient: ref.read(supabaseClientProvider),
  );
});

final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService(
    supabaseClient: ref.read(supabaseClientProvider),
  );
});

final installReferrerServiceProvider = Provider<InstallReferrerService>((ref) {
  return InstallReferrerService(ref.read(sharedPreferencesProvider));
});

/// Vive toda la sesión: guarda el flag que evita pedir la reseña dos veces a
/// la vez si se disparan dos triggers seguidos.
final reviewPromptServiceProvider = Provider<ReviewPromptService>((ref) {
  return ReviewPromptService(ref.read(sharedPreferencesProvider));
});

final rpcServiceProvider = Provider<SupabaseRpcService>((ref) {
  throw UnimplementedError(
    'rpcServiceProvider must be overridden in ProviderScope.',
  );
});
