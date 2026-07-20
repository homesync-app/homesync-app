import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/core/services/notification_service.dart';
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

final rpcServiceProvider = Provider<SupabaseRpcService>((ref) {
  throw UnimplementedError(
    'rpcServiceProvider must be overridden in ProviderScope.',
  );
});
