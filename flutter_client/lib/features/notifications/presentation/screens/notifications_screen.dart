import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/services/logger_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('notifications')
            .select('*')
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(50);
        setState(() => _notifications = data);
      }
    } catch (e) {
      log.e('Error loading notifications: $e', error: e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true}).eq('id', id);
      _loadNotifications();
    } catch (e) {
      log.e('Error marking notification as read: $e', error: e);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', user.id)
            .eq('is_read', false);
        _loadNotifications();
      }
    } catch (e) {
      log.e('Error marking all notifications as read: $e', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todas como leídas',
            onPressed: () {
              _markAllAsRead();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isRead = notification['is_read'] == true;

                    return InkWell(
                      onTap: () {
                        if (!isRead) {
                          _markAsRead(notification['id']);
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isRead
                              ? AppColors.surface
                              : AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isRead
                                ? AppColors.border
                                : AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForType(notification['type']),
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['title'] ?? 'Notificación',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isRead
                                          ? FontWeight.w500
                                          : FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification['body'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isRead
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    timeago.format(
                                        DateTime.parse(
                                            notification['created_at']),
                                        locale: 'es'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getIconForType(String? type) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes notificaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Al día con todas las novedades',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
