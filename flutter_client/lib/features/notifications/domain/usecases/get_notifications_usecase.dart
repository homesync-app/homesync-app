import 'package:homesync_client/features/notifications/domain/entities/app_notification.dart';
import 'package:homesync_client/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<List<AppNotification>> call({
    int limit = 20,
    int offset = 0,
  }) {
    return _repository.getNotifications(limit: limit, offset: offset);
  }
}
