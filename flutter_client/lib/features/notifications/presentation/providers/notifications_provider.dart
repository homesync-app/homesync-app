import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/notifications/data/repositories/supabase_notification_repository.dart';
import 'package:homesync_client/features/notifications/domain/entities/app_notification.dart';
import 'package:homesync_client/features/notifications/domain/repositories/notification_repository.dart';
import 'package:homesync_client/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:homesync_client/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:homesync_client/features/notifications/domain/usecases/mark_notification_read_usecase.dart';

const _notificationsPageSize = 20;

class NotificationsState {
  final List<AppNotification> items;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationsState({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
  });

  const NotificationsState.initial()
      : items = const [],
        hasMore = true,
        isLoadingMore = false;

  NotificationsState copyWith({
    List<AppNotification>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return SupabaseNotificationRepository(
    supabase: ref.read(supabaseClientProvider),
    identityService: AppIdentityService.instance,
  );
});

final getNotificationsUseCaseProvider =
    Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.read(notificationRepositoryProvider));
});

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(ref.read(notificationRepositoryProvider));
});

final markAllNotificationsReadUseCaseProvider =
    Provider<MarkAllNotificationsReadUseCase>((ref) {
  return MarkAllNotificationsReadUseCase(
    ref.read(notificationRepositoryProvider),
  );
});

class NotificationsController extends AsyncNotifier<NotificationsState> {
  final Set<String> _markingIds = <String>{};
  bool _markingAll = false;

  @override
  Future<NotificationsState> build() async {
    return _load();
  }

  Future<NotificationsState> _load() async {
    final items = await ref.read(getNotificationsUseCaseProvider).call(
          limit: _notificationsPageSize,
          offset: 0,
        );
    return NotificationsState(
      items: items,
      hasMore: items.length == _notificationsPageSize,
      isLoadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<NotificationsState>();
    state = await AsyncValue.guard(_load);
  }

  Future<bool> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return true;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextItems = await ref.read(getNotificationsUseCaseProvider).call(
            limit: _notificationsPageSize,
            offset: current.items.length,
          );
      final latest = state.value ?? current;
      final existingIds = latest.items.map((item) => item.id).toSet();

      state = AsyncData(
        latest.copyWith(
          items: [
            ...latest.items,
            ...nextItems.where((item) => existingIds.add(item.id)),
          ],
          hasMore: nextItems.length == _notificationsPageSize,
          isLoadingMore: false,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isLoadingMore: false));
      log.e(
        'Error loading more notifications: $error',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_markingAll || !_markingIds.add(notificationId)) return;

    final previous = state.value;
    final previousReadState = previous?.items
        .where((notification) => notification.id == notificationId)
        .firstOrNull
        ?.isRead;

    if (previous != null) {
      state = AsyncData(
        previous.copyWith(
          items: [
            for (final notification in previous.items)
              if (notification.id == notificationId)
                notification.copyWith(isRead: true)
              else
                notification,
          ],
        ),
      );
    }

    try {
      await ref.read(markNotificationReadUseCaseProvider).call(notificationId);
      if (previous == null) await refresh();
    } catch (error, stackTrace) {
      final latest = state.value;
      if (latest != null && previousReadState != null) {
        state = AsyncData(
          latest.copyWith(
            items: [
              for (final notification in latest.items)
                if (notification.id == notificationId)
                  notification.copyWith(isRead: previousReadState)
                else
                  notification,
            ],
          ),
        );
      }
      log.e(
        'Error marking notification as read: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _markingIds.remove(notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    if (_markingAll || _markingIds.isNotEmpty) return;
    _markingAll = true;

    final previous = state.value;
    final affectedIds = previous?.items
            .where((notification) => !notification.isRead)
            .map((notification) => notification.id)
            .toSet() ??
        <String>{};

    if (previous != null) {
      state = AsyncData(
        previous.copyWith(
          items: [
            for (final notification in previous.items)
              notification.copyWith(isRead: true),
          ],
        ),
      );
    }

    try {
      await ref.read(markAllNotificationsReadUseCaseProvider).call();
      if (previous == null) await refresh();
    } catch (error, stackTrace) {
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(
          latest.copyWith(
            items: [
              for (final notification in latest.items)
                if (affectedIds.contains(notification.id))
                  notification.copyWith(isRead: false)
                else
                  notification,
            ],
          ),
        );
      }
      log.e(
        'Error marking all notifications as read: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _markingAll = false;
    }
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, NotificationsState>(
  NotificationsController.new,
);
