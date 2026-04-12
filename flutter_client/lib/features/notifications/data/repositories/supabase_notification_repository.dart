import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/features/notifications/domain/entities/app_notification.dart';
import 'package:homesync_client/features/notifications/domain/repositories/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _supabase;
  final AppIdentityService _identityService;

  SupabaseNotificationRepository({
    required SupabaseClient supabase,
    required AppIdentityService identityService,
  })  : _supabase = supabase,
        _identityService = identityService;

  @override
  Future<List<AppNotification>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    final userId = await _identityService.refresh();
    if (userId == null) {
      return const [];
    }

    final data = await _supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List<dynamic>)
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = await _identityService.refresh();
    if (userId == null) {
      return;
    }

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
  }
}
