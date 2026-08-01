import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
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
      throw StateError('Cannot load notifications without an app user');
    }

    final Object response = await _supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    if (response is! List) {
      throw const FormatException('Expected a list of notifications');
    }

    final notifications = <AppNotification>[];
    for (final item in response) {
      if (item is! Map) {
        log.w('Skipping malformed notification row');
        continue;
      }
      try {
        notifications.add(
          AppNotification.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (error, stackTrace) {
        log.w(
          'Skipping invalid notification row',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return notifications;
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = await _identityService.refresh();
    if (userId == null) {
      throw StateError('Cannot update notifications without an app user');
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
