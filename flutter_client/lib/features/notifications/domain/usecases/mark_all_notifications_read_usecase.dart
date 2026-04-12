import 'package:homesync_client/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<void> call() {
    return _repository.markAllAsRead();
  }
}
