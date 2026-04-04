import 'package:homesync_client/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications({
    int limit = 20,
    int offset = 0,
  });
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
