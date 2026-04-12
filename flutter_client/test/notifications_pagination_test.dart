import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/notifications/domain/entities/app_notification.dart';
import 'package:homesync_client/features/notifications/domain/repositories/notification_repository.dart';
import 'package:homesync_client/features/notifications/presentation/providers/notifications_provider.dart';

class FakeNotificationRepository implements NotificationRepository {
  final List<AppNotification> notifications;

  FakeNotificationRepository(this.notifications);

  @override
  Future<List<AppNotification>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    if (offset >= notifications.length) {
      return const [];
    }

    final end = (offset + limit).clamp(0, notifications.length);
    return notifications.sublist(offset, end);
  }

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String notificationId) async {}
}

AppNotification _notification(int index) {
  return AppNotification(
    id: 'notification-$index',
    title: 'Notification $index',
    body: 'Body $index',
    type: 'system',
    createdAt: DateTime(2026, 1, 1).add(Duration(minutes: index)),
    isRead: false,
  );
}

void main() {
  test('notificationsControllerProvider loads next page and updates hasMore', () async {
    final repository = FakeNotificationRepository(
      List.generate(25, _notification),
    );
    final container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(notificationsControllerProvider.future);
    expect(initial.items, hasLength(20));
    expect(initial.hasMore, isTrue);
    expect(initial.isLoadingMore, isFalse);

    await container.read(notificationsControllerProvider.notifier).loadMore();

    final paged = container.read(notificationsControllerProvider).valueOrNull;
    expect(paged, isNotNull);
    expect(paged!.items, hasLength(25));
    expect(paged.hasMore, isFalse);
    expect(paged.isLoadingMore, isFalse);
  });
}
