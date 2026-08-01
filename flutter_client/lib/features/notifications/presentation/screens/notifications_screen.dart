import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/notifications/domain/entities/app_notification.dart';
import 'package:homesync_client/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:homesync_client/features/notifications/presentation/utils/notification_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isMarkingAll = false;
  bool _isRequestingMore = false;

  Future<void> _markAllAsRead() async {
    if (_isMarkingAll) return;

    final t = AppLocalizations.of(context);
    setState(() => _isMarkingAll = true);
    try {
      await ref.read(notificationsControllerProvider.notifier).markAllAsRead();
    } catch (error, stackTrace) {
      log.e(
        'Error marking all notifications as read',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.notificationsMarkAllReadError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarkingAll = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isRequestingMore) return;

    final t = AppLocalizations.of(context);
    _isRequestingMore = true;
    try {
      final succeeded =
          await ref.read(notificationsControllerProvider.notifier).loadMore();
      if (!succeeded && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.notificationsLoadMoreError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (error, stackTrace) {
      log.e(
        'Unexpected error loading more notifications',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.notificationsLoadMoreError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      _isRequestingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notificationsTitle),
        actions: [
          IconButton(
            icon: _isMarkingAll
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.done_all),
            tooltip: t.notificationsMarkAllReadTooltip,
            onPressed: _isMarkingAll ? null : _markAllAsRead,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(notificationsControllerProvider.notifier).refresh(),
        color: AppColors.primary,
        child: notificationsAsync.when(
          skipLoadingOnReload: true,
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ShimmerLoading(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
              );
            },
          ),
          error: (error, stackTrace) {
            log.e(
              'Error loading notifications: $error',
              error: error,
              stackTrace: stackTrace,
            );
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: const _NotificationsErrorState(),
              ),
            );
          },
          data: (notificationsState) => notificationsState.items.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: const _NotificationsEmptyState(),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200) {
                      unawaited(_loadMore());
                    }
                    return false;
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: notificationsState.items.length +
                        (notificationsState.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= notificationsState.items.length) {
                        return const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      return _NotificationCard(
                        notification: notificationsState.items[index],
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final content = localizedNotificationContent(
      t,
      notification,
    );
    return InkWell(
      onTap: () async {
        if (notification.isRead) {
          return;
        }

        try {
          await ref
              .read(notificationsControllerProvider.notifier)
              .markAsRead(notification.id);
        } catch (e, stackTrace) {
          log.e(
            'Error marking notification as read: $e',
            error: e,
            stackTrace: stackTrace,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(t.notificationsMarkReadError),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.body,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w400,
                      color: notification.isRead
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeago.format(
                      notification.createdAt,
                      locale: Localizations.localeOf(context).languageCode,
                    ),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.notificationsEmptyTitle,
            style: AppTypography.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.notificationsEmptySubtitle,
            style: AppTypography.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsErrorState extends StatelessWidget {
  const _NotificationsErrorState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: theme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.notificationsErrorTitle,
            style: AppTypography.sectionTitle.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.notificationsErrorSubtitle,
            style: AppTypography.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: theme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _getIconForType(String type) {
  switch (type) {
    case 'task_assigned':
      return Icons.assignment_ind_rounded;
    case 'task_completed':
      return Icons.task_alt_rounded;
    case 'expense_added':
      return Icons.account_balance_wallet_rounded;
    case 'system':
      return Icons.info_outline_rounded;
    default:
      return Icons.notifications_rounded;
  }
}
