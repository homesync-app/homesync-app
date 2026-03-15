import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_animations.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../household/presentation/screens/setup_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../rewards/presentation/screens/rewards_screen.dart';
import '../../../savings/presentation/providers/savings_provider.dart';
import '../../../shopping/presentation/screens/shopping_list_screen.dart';
import '../../../stats/presentation/screens/stats_screen.dart';
import '../../../stats/presentation/screens/weekly_winner_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/dashboard_provider.dart';
import '../screens/home_screen.dart';
import '../widgets/notification_bell.dart';
import '../widgets/in_app_notification_banner.dart';

class MainScreen extends ConsumerStatefulWidget {
  final SharedPreferences prefs;

  const MainScreen({
    super.key,
    required this.prefs,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isLoading = true;
  bool _needsSetup = false;
  bool _showWeeklyWinner = false;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // ── In-app notification banner state ──────────────────────────────────────
  final GlobalKey<InAppNotificationBannerState> _bannerKey = GlobalKey();
  final _notifService = NotificationService.instance;

  @override
  void initState() {
    super.initState();
    _checkSetup();
    _initNotifications();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _notifService.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Deep Link received: $uri');
      
      if (uri.scheme != 'homesync') return;

      // 1. Mercado Pago Auth callback
      if (uri.host == 'auth-complete' || uri.path.contains('auth-complete')) {
        final status = uri.queryParameters['status'];
        final message = uri.queryParameters['message'];
        
        if (status == 'success') {
          _showToast('✅ Mercado Pago conectado con éxito', AppColors.success);
        } else if (status == 'error') {
          _showToast('❌ Error al conectar: ${message ?? "Desconocido"}', AppColors.error);
        }
      }

      // 2. Mercado Pago Payment callbacks
      if (uri.host == 'payment-success' || uri.path.contains('payment-success')) {
        _showToast('🎉 ¡Acreditado! Se verá reflejado en unos segundos.', AppColors.success);
        
        // Refresh all relevant data
        ref.invalidate(savingsGoalsProvider);
        ref.invalidate(expenseBalancesProvider);
        ref.invalidate(userBalanceProvider);
        ref.invalidate(recentActivityProvider);
      }
      
      if (uri.host == 'payment-failure' || uri.path.contains('payment-failure')) {
        _showToast('❌ El pago fue rechazado. Reintentá luego.', AppColors.error);
      }

      if (uri.host == 'payment-pending' || uri.path.contains('payment-pending')) {
        _showToast('⏳ Pago en proceso. Te avisaremos al acreditarse.', Colors.orange);
      }
    });
  }

  void _showToast(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Notification initialization ────────────────────────────────────────────

  Future<void> _initNotifications() async {
    await _notifService.initialize(
      onNotification: (title, body) {
        // Only show the banner if the widget is still mounted
        if (mounted) {
          _bannerKey.currentState?.show(title: title, body: body);
          
          // Real-time refresh for dashboard data
          ref.invalidate(userBalanceProvider);
          ref.invalidate(expenseBalancesProvider);
          ref.invalidate(recentActivityProvider);
          ref.invalidate(expenseControllerProvider);
        }
      },
    );
  }

  // ── Setup checks ──────────────────────────────────────────────────────────

  Future<void> _checkSetup() async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _needsSetup = true;
          });
        }
        return;
      }

      // Add a timeout to the household check (5 seconds is plenty)
      final hasHousehold = await Supabase.instance.client
          .from('household_members')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      if (hasHousehold == null) {
        if (mounted) {
          setState(() {
            _needsSetup = true;
            _isLoading = false;
          });
        }
        return;
      }

      await widget.prefs.setBool('setup_completed', true);
      
      // ✅ Don't await non-essential checks (weekly winner popup)
      _checkWeeklyWinner();
    } catch (e) {
      debugPrint('Initialization error in MainScreen: $e');
      // If we failed after 5 seconds, let's just let the app continue 
      // Individual providers will handle errors gracefully with retry logic
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkWeeklyWinner() async {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentHour = now.hour;

    final isSundayEvening = currentDay == DateTime.sunday && currentHour >= 20;
    final isMondayMorning = currentDay == DateTime.monday && currentHour < 12;

    if (!isSundayEvening && !isMondayMorning) return;

    final lastWinnerKey = 'last_winner_shown_${_getWeekKey()}';
    final alreadyShown = widget.prefs.getBool(lastWinnerKey) ?? false;
    if (alreadyShown) return;

    try {
      final rpc = ref.read(rpcServiceProvider);
      final isProcessed = await rpc.isWeekProcessed();
      if (!isProcessed) {
        final ranking = await rpc.getWeeklyRanking();
        if (ranking.isNotEmpty && (ranking.first['xp_earned'] ?? 0) > 0) {
          setState(() => _showWeeklyWinner = true);
        }
      }
    } catch (e) {
      debugPrint('Error checking weekly winner: $e');
    }
  }

  String _getWeekKey() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}_${monday.month}_${monday.day}';
  }

  Future<void> _markWinnerShown() async {
    await widget.prefs.setBool('last_winner_shown_${_getWeekKey()}', true);
    setState(() => _showWeeklyWinner = false);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_needsSetup) {
      return SetupScreen(
        onComplete: () async {
          await widget.prefs.setBool('setup_completed', true);
          setState(() {
            _needsSetup = false;
            _isLoading = true; // Trigger re-check
          });
          _checkSetup();
        },
      );
    }

    if (_showWeeklyWinner) {
      return WeeklyWinnerScreen(
        onClose: _markWinnerShown,
      );
    }

    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      const HomeScreen(),
      const TasksScreen(),
      const ExpensesScreen(),
      const RewardsScreen(),
      const StatsScreen(),
      const ShoppingListScreen(),
    ];

    final titles = [
      'Inicio',
      'Tareas',
      'Finanzas',
      'Tienda',
      'Progreso',
      'Compras'
    ];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // If not on the first tab, go to it
        if (currentIndex != 0) {
          ref.read(bottomNavIndexProvider.notifier).setIndex(0);
        }
      },
      child: Scaffold(
        appBar: currentIndex == 3 ? null : AppBar(
          title: Text(titles[currentIndex]),
          toolbarHeight: 80,
          actions: [
            const NotificationBell(),
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () => _openSettings(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        // ✅ Stack puts the banner ABOVE everything else in the screen
        body: Stack(
          children: [
            FadeIndexedStack(
              index: currentIndex,
              children: screens,
            ),
            // In-app notification banner (slides from top)
            InAppNotificationBanner(
              key: _bannerKey,
              onTap: () => _goToNotifications(context),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      AppTransitions.slideUp(
        SettingsScreen(
          onLogout: () {
            _notifService.dispose();
            // Auth changes will be handled by authStateProvider
            ref.read(authServiceProvider).signOut();
          },
        ),
      ),
    );
  }

  void _goToNotifications(BuildContext context) {
    Navigator.push(
      context,
      AppTransitions.slideHorizontal(page: const NotificationsScreen()),
    );
  }

  Widget _buildBottomNav() {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Only 4 items in the navigation bar now
    final navItems = [
      (icon: Icons.home_rounded, label: 'Inicio', screenIndex: 0),
      (icon: Icons.task_alt_rounded, label: 'Tareas', screenIndex: 1),
      (icon: Icons.account_balance_wallet_rounded, label: 'Finanzas', screenIndex: 2),
      (icon: Icons.shopping_cart_rounded, label: 'Compras', screenIndex: 5),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems.map((item) {
            final isSelected = currentIndex == item.screenIndex || 
                             (item.screenIndex == 0 && (currentIndex == 3 || currentIndex == 4));
            return GestureDetector(
              onTap: () => ref.read(bottomNavIndexProvider.notifier).setIndex(item.screenIndex),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item.icon,
                      color:
                          isSelected ? AppColors.primary : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
