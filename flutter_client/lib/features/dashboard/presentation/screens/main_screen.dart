import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/services/deep_link_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/services/logger_service.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
// import '../../../../core/widgets/animated_press.dart'; // should be in utils/app_animations or shared
import '../../../../core/services/notification_service.dart';

import '../../../household/presentation/screens/setup_screen.dart';
import '../../../dashboard/presentation/screens/home_screen.dart';
import '../../../tasks/presentation/screens/tasks_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../rewards/presentation/screens/rewards_screen.dart';
import '../../../stats/presentation/screens/stats_screen.dart';
import '../../../shopping/presentation/screens/shopping_list_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../stats/presentation/screens/weekly_winner_screen.dart';

import '../../../../core/providers/core_providers.dart';

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

  // ── In-app notification banner state ──────────────────────────────────────
  final GlobalKey<InAppNotificationBannerState> _bannerKey = GlobalKey();
  final _notifService = NotificationService.instance;

  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = ref.read(deepLinkServiceProvider);
    _checkSetup();
    _initNotifications();
    _deepLinkService.init(ref, _showToast);
  }

  @override
  void dispose() {
    _notifService.dispose();
    _deepLinkService.dispose();
    super.dispose();
  }

  void _showToast(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        }
      },
    );
  }

  // ── Setup checks ──────────────────────────────────────────────────────────

  Future<void> _checkSetup() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _needsSetup = true;
      });
      return;
    }

    log.i('MainScreen: Verificando hogar para usuario ${user.id}...');
    
    dynamic hasHousehold;
    int attempts = 0;
    while (hasHousehold == null && attempts < 10) {
      hasHousehold = await Supabase.instance.client
          .from('household_members')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();
      
      if (hasHousehold != null) break;
      
      log.i('MainScreen: Hogar no encontrado aún (intento ${attempts + 1}). Esperando...');
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    if (!mounted) return;

    if (hasHousehold == null) {
      log.w('MainScreen: Usuario no tiene hogar tras varios reintentos. Forzando SetupScreen.');
      setState(() {
        _needsSetup = true;
        _isLoading = false;
      });
      return;
    }
    
    log.i('MainScreen: Hogar confirmado. Procediendo al Dashboard.');
    await widget.prefs.setBool('setup_completed', true);
    if (!mounted) return;

    await _checkWeeklyWinner();
    if (!mounted) return;

    setState(() => _isLoading = false);
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
      final statsRpc = ref.read(statsRpcServiceProvider);
      final isProcessed = await statsRpc.isWeekProcessed();
      if (!mounted) return;

      if (!isProcessed) {
        final ranking = await statsRpc.getWeeklyRanking();
        if (!mounted) return;

        if (ranking.isNotEmpty && (ranking.first['xp_earned'] ?? 0) > 0) {
          setState(() => _showWeeklyWinner = true);
        }
      }
    } catch (e) {
      log.e('Error checking weekly winner: $e', error: e);
    }
  }

  String _getWeekKey() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}_${monday.month}_${monday.day}';
  }

  Future<void> _markWinnerShown() async {
    await widget.prefs.setBool('last_winner_shown_${_getWeekKey()}', true);
    if (!mounted) return;
    setState(() => _showWeeklyWinner = false);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Preparando tu hogar...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      ShoppingListScreen(),
    ];

    final titles = [
      'Inicio',
      'Tareas',
      'Finanzas',
      'Tienda',
      'Progreso',
      'Compras'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        toolbarHeight: 80,
        actions: [
          NotificationBell(),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () async {
              await _openSettings(context);
              _checkSetup();
            },
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
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await Navigator.push(
      context,
      AppTransitions.slideUp(
        SettingsScreen(
          onLogout: () {
            _notifService.dispose();
            // Cerrar la pantalla de ajustes inmediatamente para que AnimatedSwitcher 
            // en RootScreen (main.dart) muestre el Login sin "atrasos"
            Navigator.pop(context);
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
      (
        icon: Icons.account_balance_wallet_outlined,
        label: 'Finanzas',
        screenIndex: 2
      ),
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
                (item.screenIndex == 0 &&
                    (currentIndex == 3 || currentIndex == 4));
            return AnimatedPress(
              onTap: () => ref
                  .read(bottomNavIndexProvider.notifier)
                  .setIndex(item.screenIndex),
              scaleDown: 0.9,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 64),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
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
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        scale: isSelected ? 1.15 : 1.0,
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontFamily: 'Inter', // Assuming standard font
                        fontSize: isSelected ? 11 : 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
