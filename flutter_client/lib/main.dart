import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/supabase_auth_service.dart';
import 'services/supabase_rpc_service.dart';
import 'services/expense_service.dart';
import 'services/notification_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'utils/app_animations.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/login_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/weekly_winner_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'providers/core_providers.dart';
import 'providers/theme_provider.dart';
import 'providers/savings_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  try {
    await Firebase.initializeApp();
    // Pass ALL uncaught Flutter errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  final auth = SupabaseAuthService();
  await auth.initialize();

  final rpc = SupabaseRpcService();
  await rpc.initialize();

  // Dual error pipeline: Crashlytics (crash grouping) + Supabase (admin logs)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 1. Send to Crashlytics for crash tracking & grouping in Firebase Console
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    // 2. Send to Supabase for the admin panel logs page
    rpc.logApplicationError(
      message: details.exceptionAsString(),
      stackTrace: details.stack?.toString(),
      context: {'library': details.library, 'context': details.context?.toString()},
    );
  };

  // Catch async errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    // 1. Crashlytics — marks as fatal
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    // 2. Supabase admin logs
    rpc.logApplicationError(
      message: error.toString(),
      stackTrace: stack.toString(),
      level: 'critical',
    );
    return true;
  };

  await initializeDateFormatting('es', null);
  final prefs = await SharedPreferences.getInstance();
  final isAuthenticated = await auth.isAuthenticated();

  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        rpcServiceProvider.overrideWithValue(rpc),
      ],
      child: MyApp(
        isAuthenticated: isAuthenticated,
        auth: auth,
        rpc: rpc,
        prefs: prefs,
      ),
    ),
  );
}

// Helper to init theme after ProviderScope is ready
class _ThemeInit extends ConsumerWidget {
  final Widget child;
  final SharedPreferences prefs;
  const _ThemeInit({required this.child, required this.prefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Init once on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeModeProvider.notifier).init(prefs);
    });
    return child;
  }
}

class MyApp extends ConsumerWidget {
  final bool isAuthenticated;
  final SupabaseAuthService auth;
  final SupabaseRpcService rpc;
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.isAuthenticated,
    required this.auth,
    required this.rpc,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return _ThemeInit(
      prefs: prefs,
      child: MaterialApp(
        title: 'HomeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: isAuthenticated
            ? MainScreen(auth: auth, rpc: rpc, prefs: prefs)
            : LoginScreen(auth: auth, rpc: rpc, prefs: prefs),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MainScreen
// ─────────────────────────────────────────────────────────────────────────────

class MainScreen extends ConsumerStatefulWidget {
  final SupabaseAuthService auth;
  final SupabaseRpcService rpc;
  final SharedPreferences prefs;

  const MainScreen({
    super.key,
    required this.auth,
    required this.rpc,
    required this.prefs,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isLoading = true;
  bool _needsSetup = false;
  bool _showWeeklyWinner = false;
  late ExpenseService _expenseService;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // ── In-app notification banner state ──────────────────────────────────────
  final GlobalKey<_InAppNotificationBannerState> _bannerKey = GlobalKey();
  final _notifService = NotificationService.instance;

  @override
  void initState() {
    super.initState();
    _expenseService = ExpenseService();
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
        }
      },
    );
  }

  // ── Setup checks ──────────────────────────────────────────────────────────

  Future<void> _checkSetup() async {
    final user = widget.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _needsSetup = true;
      });
      return;
    }

    final hasHousehold = await Supabase.instance.client
        .from('household_members')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (hasHousehold == null) {
      setState(() {
        _needsSetup = true;
        _isLoading = false;
      });
      return;
    }

    await widget.prefs.setBool('setup_completed', true);
    await _checkWeeklyWinner();
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
      final isProcessed = await widget.rpc.isWeekProcessed();
      if (!isProcessed) {
        final ranking = await widget.rpc.getWeeklyRanking();
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
          setState(() => _needsSetup = false);
          // Re-init notifications after joining/creating household
          _initNotifications();
        },
      );
    }

    if (_showWeeklyWinner) {
      return WeeklyWinnerScreen(
        rpc: widget.rpc,
        onClose: _markWinnerShown,
      );
    }

    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      HomeScreen(auth: widget.auth, rpc: widget.rpc, prefs: widget.prefs),
      TasksScreen(auth: widget.auth, rpc: widget.rpc),
      const ExpensesScreen(),
      const RewardsScreen(),
      StatsScreen(rpc: widget.rpc),
      ShoppingListScreen(auth: widget.auth),
    ];

    final titles = [
      'Inicio',
      'Tareas',
      'Gastos',
      'Tienda',
      'Progreso',
      'Compras'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        toolbarHeight: 80,
        actions: [
          _NotificationBell(auth: widget.auth),
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
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          // In-app notification banner (slides from top)
          _InAppNotificationBanner(
            key: _bannerKey,
            onTap: () => _goToNotifications(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      AppTransitions.slideUp(
        SettingsScreen(
          auth: widget.auth,
          rpc: widget.rpc,
          onLogout: () {
            _notifService.dispose();
            Navigator.of(context).pushReplacement(
              AppTransitions.fadeScale(
                LoginScreen(
                  auth: widget.auth,
                  rpc: widget.rpc,
                  prefs: widget.prefs,
                ),
              ),
            );
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
      (icon: Icons.account_balance_wallet_rounded, label: 'Gastos', screenIndex: 2),
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
                          ? AppColors.primary.withOpacity(0.12)
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

// ─────────────────────────────────────────────────────────────────────────────
// Notification Bell with unread badge
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationBell extends StatefulWidget {
  final SupabaseAuthService auth;
  const _NotificationBell({required this.auth});

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell>
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
      final user = widget.auth.currentUser;
      if (user == null) return;
      final data = await Supabase.instance.client
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
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

// ─────────────────────────────────────────────────────────────────────────────
// In-App Notification Banner
// Slides in from the top when a Supabase Realtime notification arrives.
// Auto-dismisses after 4 seconds. Tappable to go to the notifications screen.
// ─────────────────────────────────────────────────────────────────────────────

class _InAppNotificationBanner extends StatefulWidget {
  final VoidCallback onTap;

  const _InAppNotificationBanner({super.key, required this.onTap});

  @override
  _InAppNotificationBannerState createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  String _title = '';
  String _body = '';
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Called by MainScreen when a new notification arrives
  void show({required String title, required String body}) {
    if (!mounted) return;
    setState(() {
      _title = title;
      _body = body;
      _visible = true;
    });
    _controller.forward(from: 0);

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _visible) _dismiss();
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: GestureDetector(
                onTap: () {
                  _dismiss();
                  widget.onTap();
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < 0) {
                    _dismiss(); // Swipe up to dismiss
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Pulsing icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🔔', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_body.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _body,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dismiss button
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
