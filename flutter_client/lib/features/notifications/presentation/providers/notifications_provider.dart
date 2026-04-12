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

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
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
    state = const AsyncLoading<NotificationsState>().copyWithPrevious(state);
    state = await AsyncValue.guard(_load);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextItems = await ref.read(getNotificationsUseCaseProvider).call(
            limit: _notificationsPageSize,
            offset: current.items.length,
          );

      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...nextItems],
          hasMore: nextItems.length == _notificationsPageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      log.e(
        'Error loading more notifications: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final previous = state.valueOrNull;
    if (previous == null) {
      await ref.read(markNotificationReadUseCaseProvider).call(notificationId);
      await refresh();
      return;
    }

    state = AsyncData(previous.copyWith(items: [
      for (final notification in previous.items)
        if (notification.id == notificationId)
          notification.copyWith(isRead: true)
        else
          notification,
    ]));

    try {
      await ref.read(markNotificationReadUseCaseProvider).call(notificationId);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      log.e(
        'Error marking notification as read: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    final previous = state.valueOrNull;
    if (previous == null) {
      await ref.read(markAllNotificationsReadUseCaseProvider).call();
      await refresh();
      return;
    }

    state = AsyncData(
      previous.copyWith(
        items: [
          for (final notification in previous.items)
            notification.copyWith(isRead: true),
        ],
      ),
    );

    try {
      await ref.read(markAllNotificationsReadUseCaseProvider).call();
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      log.e(
        'Error marking all notifications as read: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
