import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/app_animations.dart';
import '../../../../core/widgets/app_background.dart';
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
import '../widgets/in_app_notification_banner.dart';
import 'package:intl/intl.dart';

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
          _showToast('✅ Mercado Pago conectado con éxito', Colors.green);
        } else if (status == 'error') {
          _showToast(
              '❌ Error al conectar: ${message ?? "Desconocido"}', Colors.red);
        }
      }

      // 2. Mercado Pago Payment callbacks
      if (uri.host == 'payment-success' ||
          uri.path.contains('payment-success')) {
        _showToast('🎉 ¡Acreditado! Se verá reflejado en unos segundos.',
            Colors.green);

        // Refresh all relevant data
        ref.invalidate(savingsGoalsProvider);
        ref.invalidate(expenseBalancesProvider);
        ref.invalidate(userBalanceProvider);
        ref.invalidate(recentActivityProvider);
      }

      if (uri.host == 'payment-failure' ||
          uri.path.contains('payment-failure')) {
        _showToast('❌ El pago fue rechazado. Reintentá luego.', Colors.red);
      }

      if (uri.host == 'payment-pending' ||
          uri.path.contains('payment-pending')) {
        _showToast(
            '⏳ Pago en proceso. Te avisaremos al acreditarse.', Colors.orange);
      }
    });
  }

  void _showToast(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
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
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: context.theme.primary),
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

    final theme = context.theme;
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      HomeScreen(onAvatarTap: () => _openSettings(context)),
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
      'Pareja',
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
        appBar: currentIndex == 0
            ? null
            : AppBar(
                title: _buildAppBarTitle(
                  title: titles[currentIndex],
                  currentIndex: currentIndex,
                  theme: theme,
                ),
                toolbarHeight: 86,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: theme.textSecondary,
                    ),
                    onPressed: () => _openSettings(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        // ✅ Stack puts the banner ABOVE everything else in the screen
        body: Stack(
          children: [
            Positioned.fill(
              child: AppBackground(isDarkMode: theme.isDarkMode),
            ),
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

  Widget _buildAppBarTitle({
    required String title,
    required int currentIndex,
    required AppThemeColors theme,
  }) {
    if (currentIndex != 0) {
      return Text(title);
    }

    final dateStr = DateFormat('EEEE, d MMM', 'es').format(DateTime.now());
    final capitalizedDate =
        dateStr.isEmpty ? '' : dateStr[0].toUpperCase() + dateStr.substring(1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        const SizedBox(width: 10),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: theme.textMuted.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            capitalizedDate,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
    final theme = context.theme;

    final navItems = [
      (icon: Icons.home_rounded, label: 'Inicio', screenIndex: 0),
      (icon: Icons.task_alt_rounded, label: 'Tareas', screenIndex: 1),
      (
        icon: Icons.account_balance_wallet_rounded,
        label: 'Finanzas',
        screenIndex: 2
      ),
      (icon: Icons.favorite_rounded, label: 'Pareja', screenIndex: 3),
      (icon: Icons.shopping_cart_rounded, label: 'Compras', screenIndex: 5),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: theme.navigationSurface
              .withValues(alpha: theme.isDarkMode ? 0.94 : 0.98),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.border.withValues(alpha: theme.isDarkMode ? 0.5 : 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadow
                  .withValues(alpha: theme.isDarkMode ? 0.34 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: navItems.map((item) {
            final isSelected = currentIndex == item.screenIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => ref
                    .read(bottomNavIndexProvider.notifier)
                    .setIndex(item.screenIndex),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primary
                            .withValues(alpha: theme.isDarkMode ? 0.22 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected ? theme.primary : theme.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? theme.primary : theme.textMuted,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
