import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell>
    with SingleTickerProviderStateMixin {
  int _unreadCount = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.15), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 20),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final userId = await AppIdentityService.instance.refresh();
      if (userId == null || userId.isEmpty) return;

      final data = await ref
          .read(supabaseClientProvider)
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      final count = (data as List).length;
      if (mounted && count != _unreadCount) {
        setState(() => _unreadCount = count);
        if (count > 0) {
          _shakeController.forward(from: 0);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) => Transform.rotate(
            angle: _shakeAnimation.value,
            child: child,
          ),
          child: IconButton(
            icon: Icon(
              _unreadCount > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              color: _unreadCount > 0
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
              _loadUnreadCount();
            },
          ),
        ),
        if (_unreadCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.accentRed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
