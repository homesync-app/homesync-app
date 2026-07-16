import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/notification_service.dart';
import 'package:homesync_client/core/services/performance_monitor.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/core/widgets/app_background.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_controller.dart';
import 'package:homesync_client/features/auth/presentation/screens/splash_screen.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/admin_workspace_screen.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/couple_space_screen.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/home_screen.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/household_social_hub_screen.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/solo_space_screen.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/screens/member_onboarding_screen.dart';
import 'package:homesync_client/features/household/presentation/screens/setup_screen.dart';
import 'package:homesync_client/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:homesync_client/features/onboarding/domain/coachmark_step.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/tour_target_keys.dart';
import 'package:homesync_client/features/onboarding/presentation/widgets/coachmark_overlay.dart';
import 'package:homesync_client/features/rewards/presentation/providers/couple_duel_stats_provider.dart';
import 'package:homesync_client/features/rewards/presentation/providers/reward_provider.dart';
import 'package:homesync_client/features/rewards/presentation/screens/family_rewards_screen.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/features/settings/presentation/screens/settings_screen.dart';
import 'package:homesync_client/features/shopping/presentation/screens/shopping_list_screen.dart';
import 'package:homesync_client/features/stats/domain/utils/weekly_duel_period.dart';
import 'package:homesync_client/features/stats/presentation/screens/stats_screen.dart';
import 'package:homesync_client/features/stats/presentation/screens/weekly_winner_screen.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/custom_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../household/presentation/providers/household_providers.dart';
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

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  bool _showWeeklyWinner = false;
  DateTime? _weeklyWinnerWeekStart;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  ProviderSubscription<TaskRealtimeNotice?>? _taskRealtimeNoticeSubscription;
  int? _lastTrackedTabIndex;
  MemberModel? _currentMember;
  bool _reportedFirstMainFrame = false;

  // ── Prefetch ocioso de pestañas secundarias ───────────────────────────────
  // Mientras el usuario está en el Home, calentamos en segundo plano los
  // providers de las otras pestañas (hoy se construyen recién al visitarlas por
  // el montaje perezoso del FadeIndexedStack). Mantenemos un listener vivo: como
  // son autoDispose, un read fire-and-forget se computaría y se descartaría al
  // instante; el listener los deja cacheados hasta que MainScreen se destruye,
  // así Finanzas abre su widget de "gastos del mes" de forma instantánea.
  bool _idlePrefetchScheduled = false;
  final List<ProviderSubscription> _idlePrefetchSubs = [];

  // Anchor keys for the onboarding coachmark tour. Live for the lifetime of
  // MainScreen so the registry stays consistent across rebuilds.
  final GlobalKey _rewardsTabKey = GlobalKey(debugLabel: 'tour_rewards_tab');
  final GlobalKey _expensesTabKey = GlobalKey(debugLabel: 'tour_expenses_tab');
  TourTargetKeysNotifier? _tourTargetKeys;

  // ── In-app notification banner state ──────────────────────────────────────
  final GlobalKey<InAppNotificationBannerState> _bannerKey = GlobalKey();
  late final NotificationService _notifService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifService = ref.read(notificationServiceProvider);
    _checkSetup();
    _initNotifications();
    _initDeepLinks();
    _taskRealtimeNoticeSubscription = ref.listenManual<TaskRealtimeNotice?>(
      taskRealtimeNoticeProvider,
      (previous, next) {
        if (next == null || previous?.nonce == next.nonce) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showTaskRealtimeNotice(next);
        });
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_reportedFirstMainFrame) {
        _reportedFirstMainFrame = true;
        PerformanceMonitor.mark('startup.main_screen.first_frame');
      }
      // bottomNavIndexProvider es un NotifierProvider plano (sin autoDispose),
      // asi que su estado persiste entre sesiones. Sin este reset, al loguearse
      // un usuario nuevo MainScreen abre en la tab donde quedo el anterior.
      ref.read(bottomNavIndexProvider.notifier).setIndex(0);
      _trackMainTabIfNeeded(
        index: 0,
        source: 'initial_load',
      );
      _tourTargetKeys = ref.read(tourTargetKeysProvider.notifier);
      _tourTargetKeys!.register(TourTarget.rewardsTab, _rewardsTabKey);
      _tourTargetKeys!.register(TourTarget.expensesTab, _expensesTabKey);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifService.dispose();
    for (final controller in _tabScrollControllers.values) {
      controller.dispose();
    }
    _linkSubscription?.cancel();
    _taskRealtimeNoticeSubscription?.close();
    for (final sub in _idlePrefetchSubs) {
      sub.close();
    }
    _idlePrefetchSubs.clear();
    // Diferido a microtask: modificar un provider durante dispose() tira
    // "Tried to modify a provider while the widget tree was building".
    // El unregister es idempotente (no-op si el key cambio) asi que es
    // seguro correr fuera del ciclo de vida del widget.
    final keys = _tourTargetKeys;
    if (keys != null) {
      final rewardsKey = _rewardsTabKey;
      final expensesKey = _expensesTabKey;
      Future.microtask(() {
        keys.unregister(TourTarget.rewardsTab, rewardsKey);
        keys.unregister(TourTarget.expensesTab, expensesKey);
      });
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRealtimeBackedData();
    }
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      log.d('Deep link received: $uri');

      if (uri.scheme != 'homesync') return;

      // 1. Mercado Pago Auth callback
      if (uri.host == 'auth-complete' || uri.path.contains('auth-complete')) {
        final status = uri.queryParameters['status'];
        final message = uri.queryParameters['message'];

        if (status == 'success') {
          _showToast('✅ Mercado Pago conectado con éxito', Colors.green);
        } else if (status == 'error') {
          _showToast(
            '❌ Error al conectar: ${message ?? "Desconocido"}',
            Colors.red,
          );
        }
      }

      // 2. Mercado Pago Payment callbacks
      if (uri.host == 'payment-success' ||
          uri.path.contains('payment-success')) {
        _showToast(
          '🎉 ¡Acreditado! Se verá reflejado en unos segundos.',
          Colors.green,
        );

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
          '⏳ Pago en proceso. Te avisaremos al acreditarse.',
          Colors.orange,
        );
      }
    });
  }

  void _showToast(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
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
      _checkWeeklyWinner();
    } catch (e) {
      log.e('MainScreen initialization failed', error: e);
    }
  }

  Future<void> _checkWeeklyWinner() async {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentHour = now.hour;

    final isSundayEvening = currentDay == DateTime.sunday && currentHour >= 20;
    final isMondayMorning = currentDay == DateTime.monday && currentHour < 12;

    if (!isSundayEvening && !isMondayMorning) return;

    final targetWeekStart = weeklyDuelTargetWeekStart(now);
    final lastWinnerKey =
        'last_winner_shown_${weeklyDuelWeekKey(targetWeekStart)}';
    final alreadyShown = widget.prefs.getBool(lastWinnerKey) ?? false;
    if (alreadyShown) return;

    try {
      final rpc = ref.read(rpcServiceProvider);
      final isProcessed = await rpc.isWeekProcessedForWeek(targetWeekStart);
      if (!isProcessed) {
        final ranking = await rpc.getWeeklyRankingForWeek(targetWeekStart);
        final top = ranking.isNotEmpty
            ? Map<String, dynamic>.from(ranking.first as Map)
            : null;
        if (top != null && (top['xp_earned'] as num? ?? 0) > 0) {
          setState(() {
            _weeklyWinnerWeekStart = targetWeekStart;
            _showWeeklyWinner = true;
          });
        }
      }
    } catch (e) {
      log.w('Weekly winner check failed', error: e);
    }
  }

  Future<void> _markWinnerShown() async {
    final weekStart = _weeklyWinnerWeekStart ?? weeklyDuelTargetWeekStart();
    await widget.prefs.setBool(
      'last_winner_shown_${weeklyDuelWeekKey(weekStart)}',
      true,
    );
    setState(() => _showWeeklyWinner = false);
  }

  void _refreshRealtimeBackedData() {
    ref.read(tasksProvider.notifier).silentRefresh();
    ref.invalidate(recentActivityProvider);
  }

  /// Calienta en segundo plano los providers de la pestaña Finanzas que no
  /// quedan cacheados por el arranque del Home. Se llama una sola vez, recién
  /// cuando el scaffold principal ya está en pantalla, y difiere el trabajo
  /// para no competir con la carga inicial ni con las animaciones de entrada
  /// del Home.
  void _scheduleSecondaryTabPrefetch() {
    if (_idlePrefetchScheduled) return;
    _idlePrefetchScheduled = true;
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted || _idlePrefetchSubs.isNotEmpty) return;
      // Solo tiene sentido si hay red; offline se resolvería con caché/errores
      // igual al entrar a la pestaña, sin ganancia por adelantarlo.
      if (!ref.read(isOnlineProvider)) return;
      // Finanzas (tab "Movimientos"). monthlyProjectionProvider ya lo calienta
      // el Home en modo pareja, pero no en solo/familia; estos tres lo cubren en
      // todos los modos. combinedFeed y expenseBalances ya vienen del arranque.
      _idlePrefetchSubs
        ..add(ref.listenManual(personalFinanceSummaryProvider, (_, __) {}))
        ..add(ref.listenManual(expenseControllerProvider, (_, __) {}))
        ..add(ref.listenManual(monthlyProjectionProvider, (_, __) {}));

      // Pareja (solo en modo couple, que usa CoupleRewardsScreen). Los premios
      // viven en un provider autoDispose (hay que sostener un listener); las
      // stats del duelo en uno keepAlive (basta gatillar el build con un read).
      final caps = ref.read(householdCapabilitiesProvider);
      if (caps.usesCoupleRewardsExperience) {
        _idlePrefetchSubs.add(ref.listenManual(rewardsProvider, (_, __) {}));
        ref.read(coupleDuelStatsProvider.future).catchError(
              (_) => CoupleDuelStats.empty,
            );
      }
      log.d('MainScreen: prefetch ocioso de pestañas secundarias iniciado');
    });
  }

  void _showTaskRealtimeNotice(TaskRealtimeNotice notice) {
    final t = AppLocalizations.of(context);
    final taskTitle = localizedTaskTitle(t, notice.task);
    _bannerKey.currentState?.show(
      title: t.homeTaskAddedNoticeTitle,
      body: t.homeTaskAddedNoticeBody(taskTitle),
      onTap: () => _setBottomNavIndex(0, source: 'task_realtime_banner'),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  // Stable key so the wizard keeps the same State across provider refreshes
  // (e.g. when creating the household invalidates householdIdProvider).
  static const _setupScreenKey = ValueKey('onboarding_setup_screen');

  Widget _buildSetupScreen() {
    return SetupScreen(
      key: _setupScreenKey,
      onComplete: () async {
        await widget.prefs.setBool('setup_completed', true);
        ref.invalidate(householdIdProvider);
        ref.invalidate(memberOnboardingProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final householdAsync = ref.watch(householdIdProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final authControllerState = ref.watch(authControllerProvider);
    final isAuthTransitioning = authControllerState.isLoading;

    // While the onboarding wizard is mid-flow, keep it mounted unconditionally.
    // Creating the household invalidates householdIdProvider, which flips this
    // FutureProvider into a `loading` state; if we let `.when(loading:)` render
    // a spinner it would unmount the wizard and lose its step state, kicking the
    // user back to the first screen. Rendering SetupScreen here (before .when)
    // with a stable key keeps the same State alive across those refreshes.
    if (ref.watch(setupInProgressProvider) && !isAuthTransitioning) {
      return _buildSetupScreen();
    }

    return householdAsync.when(
      // Mantiene el splash del gato (video compartido via cache) en vez de
      // cortar a un spinner entre el splash de arranque y el Home.
      loading: () => const SplashScreen(),
      error: (e, st) => Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AppBackground(isDarkMode: context.theme.isDarkMode),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Error de carga de identidad. Intenta salir de la app y volver a entrar: $e',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      data: (householdId) {
        if (isAuthTransitioning) {
          return const SplashScreen();
        }

        if ((householdId == null || householdId.isEmpty) &&
            currentUserId == null) {
          return const SplashScreen();
        }

        // Tras un cambio de usuario, householdIdProvider hace refresh manteniendo
        // el valor previo (AsyncData stale + isRefreshing). Si todavia esta en
        // vuelo el query y el valor stale es null/vacio, evitamos el flash de
        // SetupScreen mostrando splash hasta que resuelva.
        if (householdAsync.isLoading &&
            (householdId == null || householdId.isEmpty) &&
            currentUserId != null) {
          return const SplashScreen();
        }

        final admin = ref.watch(adminProvider);
        if (admin.isAdminUser && (householdId == null || householdId.isEmpty)) {
          return const AdminWorkspaceScreen();
        }

        if (admin.isAdminUser &&
            admin.showOnboardingPreview &&
            householdId != null &&
            householdId.isNotEmpty) {
          return SetupScreen(
            isAdminPreview: true,
            onComplete: () {
              ref.read(adminProvider.notifier).closeOnboardingPreview();
              ref.invalidate(householdIdProvider);
              ref.invalidate(userProfileProvider);
              ref.invalidate(currentHouseholdProvider);
              ref.invalidate(householdMembersProvider);
            },
          );
        }

        // Show the onboarding wizard when the user has no household yet, OR
        // while the wizard is still mid-flow. The wizard creates the household
        // partway through (when the user taps "Create"), which makes householdId
        // non-null before the profile/finance/task steps are done. Without the
        // in-progress guard, the router would swap the wizard out for
        // Home/MemberOnboarding mid-flow, skipping steps and losing the chosen
        // name/avatar (persisted only on the final step).
        final setupInProgress = ref.watch(setupInProgressProvider);
        if (householdId == null || householdId.isEmpty || setupInProgress) {
          return _buildSetupScreen();
        }

        final onboardingDone = ref.watch(memberOnboardingProvider);
        if (onboardingDone.isLoading) {
          return const SplashScreen();
        }
        if (onboardingDone.value == false) {
          return MemberOnboardingScreen(
            onComplete: () {
              ref.invalidate(memberOnboardingProvider);
              ref.invalidate(householdIdProvider);
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
        final caps = ref.watch(householdCapabilitiesProvider);
        final membersAsync = ref.watch(householdMembersProvider);
        final currentMember = membersAsync.whenOrNull<MemberModel?>(
          data: (members) =>
              members.where((m) => m.userId == currentUserId).firstOrNull,
        );
        _currentMember = currentMember;
        final navConfigs = visibleMainTabs(caps, currentMember: currentMember)
            .map((tab) => _navConfigForTab(tab, context))
            .toList(growable: false);

        // Ensure currentIndex is within bounds
        final safeIndex = currentIndex >= navConfigs.length ? 0 : currentIndex;
        final currentConfig = navConfigs[safeIndex];
        _trackMainTabIfNeeded(index: safeIndex, source: 'state_sync');

        // Ya pasamos todos los gates (setup/onboarding): estamos en la app real.
        // Aprovechamos el tiempo ocioso en el Home para calentar Finanzas.
        _scheduleSecondaryTabPrefetch();

        // Wrap with a Stack so the coachmark overlay can sit on top of the
        // Scaffold AND its bottomNavigationBar (otherwise an overlay mounted
        // inside Scaffold.body would not cover the nav bar — and we need to
        // spotlight tabs there).
        return Stack(
          children: [
            _buildMainScaffold(
              context: context,
              theme: theme,
              currentIndex: currentIndex,
              safeIndex: safeIndex,
              currentConfig: currentConfig,
              navConfigs: navConfigs,
            ),
            const CoachmarkOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildMainScaffold({
    required BuildContext context,
    required AppThemeColors theme,
    required int currentIndex,
    required int safeIndex,
    required NavItemConfig currentConfig,
    required List<NavItemConfig> navConfigs,
  }) {
    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If not on the first tab, go to it
        if (safeIndex != 0) {
          _setBottomNavIndex(0, source: 'system_back');
        }
      },
      child: Scaffold(
        // Let page content scroll underneath the floating blurred nav pill.
        extendBody: true,
        appBar: safeIndex == 0
            ? null
            : AppBar(
                title: _buildAppBarTitle(
                  title: currentConfig.title,
                  currentIndex: safeIndex,
                  theme: theme,
                ),
                toolbarHeight: 86,
                actionsPadding: const EdgeInsets.only(right: AppSpacing.sm),
                actions: [
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: AnimatedPress(
                        scale: 0.92,
                        onTap: () => _openSettings(context),
                        // Padding interno al GestureDetector: el área táctil
                        // queda en 48x48 sin agrandar el botón visible.
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.surface.withValues(
                              alpha: theme.isDarkMode ? 0.72 : 0.9,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: Border.all(
                              color: theme.border.withValues(
                                alpha: theme.isDarkMode ? 0.46 : 0.72,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            color: theme.textSecondary,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        body: Stack(
          children: [
            Positioned.fill(
              child: AppBackground(isDarkMode: theme.isDarkMode),
            ),
            NavClearance(
              child: FadeIndexedStack(
                index: safeIndex,
                // Cada tab recibe su PrimaryScrollController: el scrollable
                // principal de cada pantalla marca `primary: true` y así el
                // re-tap en el nav puede subir la lista al tope.
                children: [
                  for (final c in navConfigs)
                    PrimaryScrollController(
                      controller: _tabScrollControllerFor(c.tab),
                      child: c.screen,
                    ),
                ],
              ),
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

    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat('EEEE, d MMM', locale).format(DateTime.now());
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
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _openSettings(BuildContext context) {
    unawaited(
      ref.read(analyticsServiceProvider).trackDashboardAction(
            action: 'open_settings',
            source: 'main_screen',
          ),
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          onLogout: () {
            _notifService.dispose();
          },
        ),
      ),
    );
  }

  void _goToNotifications(BuildContext context) {
    unawaited(
      ref.read(analyticsServiceProvider).trackDashboardAction(
            action: 'open_notifications',
            source: 'main_screen',
          ),
    );
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
    );
  }

  Widget _buildBottomNav() {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final t = AppLocalizations.of(context);
    final navItems = visibleMainTabs(caps, currentMember: _currentMember)
        .where((tab) => tab != MainTab.stats)
        .map(
          (tab) => CustomBottomNavItem(
            label: _labelForTab(tab, caps, t),
            index: indexForMainTab(caps, tab, currentMember: _currentMember),
            icon: _iconForTab(tab, caps, isSelected: false),
            selectedIcon: _iconForTab(tab, caps, isSelected: true),
            anchorKey: switch (tab) {
              MainTab.social => _rewardsTabKey,
              MainTab.expenses => _expensesTabKey,
              _ => null,
            },
          ),
        )
        .toList(growable: false);

    return CustomBottomNav(
      currentIndex: currentIndex,
      items: navItems,
      onTap: (index) => _setBottomNavIndex(index, source: 'bottom_nav'),
    );
  }

  NavItemConfig _navConfigForTab(MainTab tab, BuildContext context) {
    final caps = ref.read(householdCapabilitiesProvider);
    final t = AppLocalizations.of(context);

    return switch (tab) {
      MainTab.home => NavItemConfig(
          tab: tab,
          title: t.mainTabHome,
          icon: Icons.home_rounded,
          screen: HomeScreen(
            key: const ValueKey(MainTab.home),
            onAvatarTap: () => _openSettings(context),
          ),
        ),
      MainTab.tasks => NavItemConfig(
          tab: tab,
          title: t.mainTabTasks,
          icon: Icons.task_alt_rounded,
          screen: const TasksScreen(key: ValueKey(MainTab.tasks)),
        ),
      MainTab.expenses => NavItemConfig(
          tab: tab,
          title: t.mainTabExpenses,
          icon: Icons.account_balance_wallet_rounded,
          screen: const ExpensesScreen(key: ValueKey(MainTab.expenses)),
        ),
      MainTab.social => NavItemConfig(
          tab: tab,
          title: caps.socialTabLabel(t),
          icon: caps.partnerIcon,
          screen: caps.type == HouseholdType.solo
              ? const SoloSpaceScreen(key: ValueKey(MainTab.social))
              : caps.usesCoupleRewardsExperience
                  ? const CoupleSpaceScreen(key: ValueKey(MainTab.social))
                  : const HouseholdSocialHubScreen(
                      key: ValueKey(MainTab.social),
                    ),
        ),
      MainTab.stats => NavItemConfig(
          tab: tab,
          title: t.mainTabProgress,
          icon: Icons.bar_chart_rounded,
          screen: const StatsScreen(key: ValueKey(MainTab.stats)),
        ),
      MainTab.shopping => NavItemConfig(
          tab: tab,
          title: _currentMember?.isChild == true
              ? t.mainTabShoppingChild
              : t.mainTabShopping,
          icon: _currentMember?.isChild == true
              ? Icons.storefront_rounded
              : Icons.shopping_cart_rounded,
          screen: _currentMember?.isChild == true
              ? const FamilyRewardsScreen(key: ValueKey(MainTab.shopping))
              : const ShoppingListScreen(key: ValueKey(MainTab.shopping)),
        ),
    };
  }

  IconData _iconForTab(
    MainTab tab,
    HouseholdCapabilities caps, {
    required bool isSelected,
  }) {
    if (isSelected) {
      return switch (tab) {
        MainTab.home => Icons.home_rounded,
        MainTab.tasks => Icons.task_alt_rounded,
        MainTab.expenses => Icons.account_balance_wallet_rounded,
        MainTab.social => caps.socialTabSelectedIcon,
        MainTab.stats => Icons.bar_chart_rounded,
        MainTab.shopping => _currentMember?.isChild == true
            ? Icons.storefront_rounded
            : Icons.shopping_cart_rounded,
      };
    }

    return switch (tab) {
      MainTab.home => Icons.home_outlined,
      MainTab.tasks => Icons.task_alt_outlined,
      MainTab.expenses => Icons.account_balance_wallet_outlined,
      MainTab.social => caps.socialTabIcon,
      MainTab.stats => Icons.bar_chart_outlined,
      MainTab.shopping => _currentMember?.isChild == true
          ? Icons.storefront_outlined
          : Icons.shopping_cart_outlined,
    };
  }

  String _labelForTab(
    MainTab tab,
    HouseholdCapabilities caps,
    AppLocalizations t,
  ) {
    return switch (tab) {
      MainTab.home => t.mainTabHome,
      MainTab.tasks => t.mainTabTasks,
      MainTab.expenses => t.mainTabExpenses,
      MainTab.social => caps.socialTabLabel(t),
      MainTab.stats => t.mainTabProgress,
      MainTab.shopping => _currentMember?.isChild == true
          ? t.mainTabShoppingChild
          : t.mainTabShopping,
    };
  }

  /// Un ScrollController por tab, inyectado como PrimaryScrollController
  /// alrededor de cada pantalla del stack para poder subir al tope en re-tap.
  final Map<MainTab, ScrollController> _tabScrollControllers = {};

  ScrollController _tabScrollControllerFor(MainTab tab) =>
      _tabScrollControllers.putIfAbsent(tab, ScrollController.new);

  /// Re-tap en el tab activo: sube al tope todas las posiciones adjuntas
  /// (el gesto estándar de bottom nav). Háptica solo si había scroll.
  void _scrollActiveTabToTop(MainTab tab) {
    final controller = _tabScrollControllers[tab];
    if (controller == null || !controller.hasClients) return;
    var scrolled = false;
    for (final position in controller.positions) {
      if (position.pixels > 0) {
        scrolled = true;
        position.animateTo(
          0,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
    }
    if (scrolled) AppHaptics.selection();
  }

  void _setBottomNavIndex(int index, {required String source}) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    final caps = ref.read(householdCapabilitiesProvider);
    final visibleTabs = visibleMainTabs(caps, currentMember: _currentMember);
    final targetTab =
        index >= 0 && index < visibleTabs.length ? visibleTabs[index] : null;

    if (currentIndex == index) {
      _trackMainTabIfNeeded(index: index, source: '${source}_repeat');
      if (targetTab != null) _scrollActiveTabToTop(targetTab);
      if (targetTab == MainTab.home || targetTab == MainTab.tasks) {
        _refreshRealtimeBackedData();
      }
      return;
    }

    AppHaptics.selection();
    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
    if (targetTab == MainTab.home || targetTab == MainTab.tasks) {
      _refreshRealtimeBackedData();
    }
    _trackMainTabIfNeeded(index: index, source: source, force: true);
  }

  void _trackMainTabIfNeeded({
    required int index,
    required String source,
    bool force = false,
  }) {
    if (!mounted) return;
    if (!force && _lastTrackedTabIndex == index) return;

    final caps = ref.read(householdCapabilitiesProvider);
    final visibleTabs = visibleMainTabs(caps, currentMember: _currentMember);
    if (index < 0 || index >= visibleTabs.length) return;

    _lastTrackedTabIndex = index;
    unawaited(
      ref.read(analyticsServiceProvider).trackMainTabOpened(
            tab: visibleTabs[index].name,
            source: source,
          ),
    );
  }
}

class NavItemConfig {
  final MainTab tab;
  final String title;
  final IconData icon;
  final Widget screen;

  NavItemConfig({
    required this.tab,
    required this.title,
    required this.icon,
    required this.screen,
  });
}
