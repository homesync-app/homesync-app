import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/locale_provider.dart';
import 'package:homesync_client/core/providers/riverpod_retry.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/breadcrumb_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/performance_monitor.dart';
import 'package:homesync_client/core/services/premium_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/theme/app_system_ui.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/features/auth/presentation/screens/login_screen.dart';
import 'package:homesync_client/features/auth/presentation/screens/splash_screen.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/main_screen.dart';
// Prefetching Providers
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/shopping/data/shopping_icons_remote.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PerformanceMonitor.mark('app.main.start');

  // Edge-to-edge: draw behind the status and gesture bars from frame one.
  unawaited(AppSystemUi.init());

  // Nada de este grupo depende de Firebase/Supabase: las futures arrancan
  // ya y se esperan recién donde se usan, solapadas con la cadena de red
  // de abajo (Firebase → Supabase → RPC).
  final packageInfoFuture = PerformanceMonitor.measureFuture(
    'startup.package_info',
    PackageInfo.fromPlatform,
    warnAfterMs: 200,
  );
  final deviceContextFuture = _collectDeviceContext();
  final dateFormattingFuture = PerformanceMonitor.measureFuture(
    'startup.date_formatting',
    () async {
      await initializeDateFormatting('es', null);
      await initializeDateFormatting('en_US', null);
    },
    warnAfterMs: 300,
  );
  final prefsFuture = PerformanceMonitor.measureFuture(
    'startup.shared_preferences',
    SharedPreferences.getInstance,
    warnAfterMs: 300,
  );
  // Warm up GoogleSignIn so the first sign-in is fast. Auth itself is
  // handled by FirebaseAuthService (Firebase Third-Party Auth bridge); we
  // never touch supabase.auth because the client runs in accessToken mode.
  // El timeout de 5s queda fuera del camino crítico: corre en paralelo y
  // solo se espera justo antes de runApp.
  final googleSignInWarmupFuture = () async {
    try {
      await PerformanceMonitor.measureFuture(
        'startup.google_sign_in_initialize',
        () => GoogleSignIn.instance
            .initialize(
              clientId: kIsWeb ? AppEnvironment.googleWebClientId : null,
              serverClientId: kIsWeb ? null : AppEnvironment.googleWebClientId,
            )
            .timeout(const Duration(seconds: 5)),
        warnAfterMs: 500,
      );
    } catch (e, stack) {
      log.w(
        'GoogleSignIn warm-up failed (offline?)',
        error: e,
        stackTrace: stack,
      );
    }
  }();

  final packageInfo = await packageInfoFuture;
  breadcrumb.setAppVersion(packageInfo.version, packageInfo.buildNumber);
  final deviceContext = await deviceContextFuture;

  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final appContext = <String, dynamic>{
    'environment': AppEnvironment.current.name,
    'app_version': packageInfo.version,
    'build_number': packageInfo.buildNumber,
    'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    'locale': '${locale.languageCode}_${locale.countryCode ?? ''}',
    'timezone': DateTime.now().timeZoneName,
  };
  final richContext = <String, dynamic>{
    ...appContext,
    ...deviceContext,
  };

  log.setCustomKey('environment', appContext['environment']);
  log.setCustomKey('app_version', appContext['app_version']);
  log.setCustomKey('build_number', appContext['build_number']);
  log.setCustomKey('platform', appContext['platform']);
  log.setCustomKey('locale', appContext['locale']);
  log.setCustomKey('timezone', appContext['timezone']);
  if (deviceContext['model'] != null) {
    log.setCustomKey('device_model', deviceContext['model']);
  }
  if (deviceContext['device'] != null) {
    log.setCustomKey('device_type', deviceContext['device']);
  }

  AppEnvironment.validateRuntimeConfig(isWeb: kIsWeb);

  // 1. Initialize Firebase
  try {
    await PerformanceMonitor.measureFuture(
      'startup.firebase_initialize',
      () => Firebase.initializeApp(
        // Android MUST use the native google-services.json (correct API key,
        // same one shipped in +81). Do NOT force AppEnvironment.firebaseOptions
        // here — its Dart API key differs from native and breaks prod Auth.
        options: kIsWeb ? AppEnvironment.firebaseOptions : null,
      ),
      warnAfterMs: 700,
    );
    // Blindaje: Solo proceder si Firebase se inicializó correctamente
    if (Firebase.apps.isNotEmpty && !kIsWeb) {
      FirebaseCrashlytics.instance
          .setCustomKey('environment', appContext['environment'] as String);
      FirebaseCrashlytics.instance
          .setCustomKey('app_version', appContext['app_version'] as String);
      FirebaseCrashlytics.instance
          .setCustomKey('build_number', appContext['build_number'] as String);
      FirebaseCrashlytics.instance
          .setCustomKey('platform', appContext['platform'] as String);
      FirebaseCrashlytics.instance
          .setCustomKey('locale', appContext['locale'] as String);
      FirebaseCrashlytics.instance
          .setCustomKey('timezone', appContext['timezone'] as String);
      if (deviceContext['model'] != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('device_model', deviceContext['model'] as String);
      }
      if (deviceContext['device'] != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('device_type', deviceContext['device'] as String);
      }
    }
  } catch (e) {
    log.e('Firebase initialization failed', error: e);
  }

  // Inicialización de Supabase + auth/rpc. Si no hay red la SDK reintenta
  // internamente; este try/catch protege el arranque para que un fallo de
  // DNS o handshake no mate la app antes de runApp. La sesión se reanudará
  // sola cuando vuelva la conectividad.
  try {
    await PerformanceMonitor.measureFuture(
      'startup.supabase_initialize',
      () => Supabase.initialize(
        url: AppEnvironment.supabaseUrl,
        anonKey: AppEnvironment.supabaseAnonKey,
        // Firebase Third-Party Auth: each Supabase request carries the Firebase JWT.
        // Supabase validates it against Firebase's JWKS endpoint automatically.
        // This replaces the manual session sync (_syncSupabaseSession).
        accessToken: () async {
          try {
            // Check if Firebase is actually initialized before accessing Auth
            if (Firebase.apps.isEmpty) return null;
            final user = fa.FirebaseAuth.instance.currentUser;
            if (user == null) return null;
            return await user.getIdToken(false);
          } catch (e) {
            log.w(
              'Firebase Auth token retrieval failed during Supabase init',
              error: e,
            );
            return null;
          }
        },
      ),
      warnAfterMs: 700,
    );
  } catch (e, stack) {
    log.w(
      'Supabase.initialize failed (offline?). App seguirá arrancando.',
      error: e,
      stackTrace: stack,
    );
  }

  final supabaseClient = Supabase.instance.client;
  AppIdentityService.instance.configure(client: supabaseClient);

  final rpc = SupabaseRpcService(clientOverride: supabaseClient);
  try {
    await PerformanceMonitor.measureFuture(
      'startup.rpc_service_initialize',
      rpc.initialize,
      warnAfterMs: 200,
    );
  } catch (e, stack) {
    log.w(
      'RPC service init failed (offline?)',
      error: e,
      stackTrace: stack,
    );
  }

  // Dual error pipeline: Crashlytics (Android/iOS) + Supabase (admin logs).
  // OJO: usamos recordFlutterError (NO recordFlutterFatalError) — los errores
  // capturados por el framework de Flutter no son crashes reales; el árbol
  // sigue ejecutándose. Marcarlos como fatal contamina los "crash-free users".
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (!kIsWeb && Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
    final diagnosticLines = <String>[
      details.exceptionAsString(),
    ];
    for (final node
        in details.informationCollector?.call() ?? <DiagnosticsNode>[]) {
      diagnosticLines.add(node.toString());
    }
    final fullContext = <String, dynamic>{
      ...richContext,
      'library': details.library,
      'context': details.context?.toString(),
      'summary': details.summary.toString(),
      'full_diagnostics': diagnosticLines.join('\n'),
    };
    if (details.stack != null) {
      fullContext['stack_frames_head'] =
          details.stack.toString().split('\n').take(20).join('\n');
    }
    rpc.logApplicationError(
      message: details.exceptionAsString(),
      stackTrace: details.stack?.toString(),
      context: fullContext,
    );
  };

  // Catch async errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    // 1. Crashlytics — marks as fatal (mobile only)
    if (!kIsWeb && Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    // 2. Supabase admin logs (all platforms)
    rpc.logApplicationError(
      message: error.toString(),
      stackTrace: stack.toString(),
      level: 'critical',
      context: {
        ...richContext,
        'source': 'platform_dispatcher',
      },
    );
    return true;
  };

  await Future.wait([dateFormattingFuture, googleSignInWarmupFuture]);
  final prefs = await prefsFuture;

  runApp(
    ProviderScope(
      retry: appRiverpodRetry,
      overrides: [
        rpcServiceProvider.overrideWithValue(rpc),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MyApp(
        appVersion: packageInfo.version,
        prefs: prefs,
      ),
    ),
  );
}

/// Contexto del dispositivo para logs/Crashlytics. Falla suave: si un
/// plugin no responde se devuelve lo que se haya juntado hasta ahí.
Future<Map<String, dynamic>> _collectDeviceContext() async {
  final deviceInfo = DeviceInfoPlugin();
  final deviceContext = <String, dynamic>{};
  try {
    if (kIsWeb) {
      final web = await deviceInfo.webBrowserInfo;
      deviceContext.addAll({
        'device': 'web',
        'browser': web.browserName.name,
        'user_agent': web.userAgent,
        'platform': web.platform,
      });
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await deviceInfo.androidInfo;
          deviceContext.addAll({
            'device': 'android',
            'model': info.model,
            'brand': info.brand,
            'manufacturer': info.manufacturer,
            'os_version': info.version.release,
            'sdk_int': info.version.sdkInt,
          });
          break;
        case TargetPlatform.iOS:
          final info = await deviceInfo.iosInfo;
          deviceContext.addAll({
            'device': 'ios',
            'model': info.utsname.machine,
            'name': info.name,
            'system_version': info.systemVersion,
          });
          break;
        case TargetPlatform.macOS:
          final info = await deviceInfo.macOsInfo;
          deviceContext.addAll({
            'device': 'macos',
            'model': info.model,
            'os_version': info.osRelease,
            'kernel_version': info.kernelVersion,
          });
          break;
        case TargetPlatform.windows:
          final info = await deviceInfo.windowsInfo;
          deviceContext.addAll({
            'device': 'windows',
            'computer_name': info.computerName,
            'os_version': info.displayVersion,
          });
          break;
        case TargetPlatform.linux:
          final info = await deviceInfo.linuxInfo;
          deviceContext.addAll({
            'device': 'linux',
            'name': info.name,
            'version': info.version,
          });
          break;
        case TargetPlatform.fuchsia:
          deviceContext.addAll({'device': 'fuchsia'});
          break;
      }
    }
  } catch (e) {
    log.w('Device info initialization failed', error: e);
  }
  return deviceContext;
}

class MyApp extends ConsumerStatefulWidget {
  final String appVersion;
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.appVersion,
    required this.prefs,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static const _minimumSplashDuration = Duration(milliseconds: 800);
  static const _criticalBootstrapTimeout = Duration(milliseconds: 2500);
  bool _startupReady = false;
  String? _pendingAuthNavigation;
  late final FirebaseAnalyticsObserver _analyticsObserver;
  final RouteObserver<ModalRoute<void>> _breadcrumbObserver =
      BreadcrumbRouteObserver();

  // GlobalKey so we can imperatively navigate from outside the build() method.
  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Blindaje: Solo usar Analytics si Firebase está listo
    if (Firebase.apps.isNotEmpty) {
      _analyticsObserver = FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      );
    }
    ref.read(authBootstrapProvider);
    unawaited(_configureAnalytics());

    if (AppEnvironment.adminTestingAutoLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ref.read(adminProvider).isAdminUser) return;
        final scenarioId = AppEnvironment.adminTestingAutoScenarioId;
        final viewerUserId = AppEnvironment.adminTestingAutoViewerUserId;
        final scenario = AdminTestingConfig.scenarioById(scenarioId);
        final qaUser = AdminTestingConfig.qaUserById(viewerUserId);

        if (AppEnvironment.adminTestingAutoAdminSessionEnabled) {
          ref.read(qaSessionServiceProvider).signInAsAdminPreviewSession(
                email: AppEnvironment.adminTestingBaseEmail,
                password: AppEnvironment.adminTestingBasePassword,
                scenarioId: scenarioId,
                viewerUserId: viewerUserId,
              );
          return;
        }

        if (AppEnvironment.adminTestingAutoRealQaLogin &&
            scenario != null &&
            qaUser != null) {
          ref.read(qaSessionServiceProvider).signInAsQaUser(scenario, qaUser);
          return;
        }

        ref.read(adminProvider.notifier).activateAutoQaSession(
              scenarioId: scenarioId,
              viewerUserId: viewerUserId,
            );
      });
    }
    // Initialize premium service on app start
    ref.read(premiumServiceProvider);
    _completeStartupGate();
  }

  Future<void> _configureAnalytics() async {
    // Blindaje: Solo configurar si Firebase está listo
    if (Firebase.apps.isEmpty) return;

    final analytics = ref.read(analyticsServiceProvider);
    await PerformanceMonitor.measureFuture(
      'startup.analytics_configure',
      () async {
        await analytics.setUserProperty(
          name: 'environment',
          value: AppEnvironment.current.name,
        );
        await analytics.setUserProperty(
          name: 'platform',
          value: kIsWeb ? 'web' : defaultTargetPlatform.name,
        );
        await analytics.trackAppOpened(
          environment: AppEnvironment.current.name,
          platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
          appVersion: widget.appVersion,
        );
      },
      warnAfterMs: 800,
    );
  }

  Future<void> _completeStartupGate() async {
    // El splash mínimo de branding corre EN PARALELO con el bootstrap (no en
    // serie): garantiza que el splash se vea al menos ese tiempo sin sumarle
    // ~800ms al arranque cuando la carga ya tardó más que eso.
    final minimumSplash = Future<void>.delayed(_minimumSplashDuration);
    // Precarga de íconos de compras en background apenas abre la app: corre en
    // paralelo al login/onboarding, así para cuando el usuario llega a la lista
    // de compras ya están cacheados en disco y nunca ve placeholders ni íconos
    // viejos. Fire-and-forget — no bloquea el arranque.
    unawaited(
      ref.read(shoppingIconManifestProvider.notifier).precacheAllIcons(),
    );
    log.i('🚀 StartupGate: waiting for authBootstrap...');
    await PerformanceMonitor.measureFuture(
      'startup.auth_bootstrap_provider',
      () => ref.read(authBootstrapProvider.future).catchError((_) {}),
      warnAfterMs: 1200,
    );
    log.i('🚀 StartupGate: authBootstrap done');

    log.i('🚀 StartupGate: reading authStateProvider...');
    final authState = await PerformanceMonitor.measureFuture(
      'startup.auth_state_provider',
      () => ref.read(authStateProvider.future).catchError(
            (_) => const AppAuthState(
              isAuthenticated: false,
              source: 'bootstrap_error',
            ),
          ),
      warnAfterMs: 500,
    );
    log.i(
      '🚀 StartupGate: authState resolved isAuthenticated=${authState.isAuthenticated} source=${authState.source}',
    );

    if (!mounted) return;

    if (authState.isAuthenticated && authState.source != 'admin_testing') {
      log.i('StartupGate: preloading home data before entering...');
      await PerformanceMonitor.measureFuture(
        'startup.warm_critical_providers',
        _warmCriticalProviders,
        warnAfterMs: 1800,
      );
    }

    await minimumSplash;

    if (!mounted) return;

    log.i('🚀 StartupGate: READY — setting _startupReady = true');
    setState(() {
      _startupReady = true;
    });
  }

  Future<void> _warmCriticalProviders() async {
    await PerformanceMonitor.measureFuture(
      'startup.home_bootstrap_provider',
      () => ref.read(homeBootstrapProvider.future).then((_) {}),
      warnAfterMs: 900,
    );

    // Blocking set: strictly needed to render the home above the fold without
    // skeletons. Everything else is kicked off fire-and-forget so it streams in
    // once the user is already past the splash.
    final blocking = <String, Future<void>>{
      'householdIdProvider':
          ref.read(householdIdProvider.future).then((_) {}).catchError((_) {}),
      'userProfileProvider':
          ref.read(userProfileProvider.future).then((_) {}).catchError((_) {}),
      'householdMembersProvider': ref
          .read(householdMembersProvider.future)
          .then((_) {})
          .catchError((_) {}),
      'recentActivityRemoteProvider': ref
          .read(recentActivityRemoteProvider.future)
          .timeout(const Duration(milliseconds: 900), onTimeout: () => const [])
          .then((_) {})
          .catchError((_) {}),
      'expenseBalancesProvider': ref
          .read(expenseBalancesProvider.future)
          .then((_) {})
          .catchError((_) {}),
      'tasksProvider':
          ref.read(tasksProvider.future).then((_) {}).catchError((_) {}),
    };

    // Non-blocking: kick them off so the warm cache is ready by the time the
    // user scrolls, but don't hold the splash for them.
    // - recentActivityProvider and combinedFeedController are seeded by
    //   homeBootstrapProvider, so we avoid starting duplicate remote work here.
    // - statsController / shopping / householdMembers (legacy) / userBalance:
    //   secondary views.
    // Kicked off, but not awaited — we only use the side effect of populating
    // the provider cache so subsequent watchers resolve synchronously.
    // ignore: unused_local_variable
    final nonBlocking = <Future<void>>[
      ref.read(statsControllerProvider.future).then((_) {}).catchError((_) {}),
      ref.read(shoppingItemsProvider.future).then((_) {}).catchError((_) {}),
      ref.read(userBalanceProvider.future).then((_) {}).catchError((_) {}),
    ];

    await Future.wait(
      blocking.entries.map((entry) async {
        try {
          await PerformanceMonitor.measureFuture(
            'startup.blocking_provider.${entry.key}',
            () => entry.value.timeout(_criticalBootstrapTimeout),
            warnAfterMs: 700,
          );
        } on TimeoutException {
          log.w('StartupGate: blocking preload timed out for ${entry.key}');
        }
      }),
    );

    await PerformanceMonitor.measureFuture(
      'startup.precache_images',
      _precacheStartupImages,
      warnAfterMs: 700,
    );
  }

  Future<void> _precacheStartupImages() async {
    if (!mounted) return;

    final profile = ref.read(userProfileProvider).value;
    final members = ref.read(householdMembersProvider).value ?? const [];

    final avatarUrls = <String>{
      if (profile?['avatar_url'] is String) profile!['avatar_url'] as String,
      ...members
          .map((member) => member.avatarUrl)
          .whereType<String>()
          .where((url) => url.trim().isNotEmpty),
    };

    await Future.wait(
      avatarUrls.map((url) async {
        try {
          if (url.startsWith('http')) {
            // CachedNetworkImageProvider y no NetworkImage: persiste en disco
            // entre sesiones, así este precache cuesta red solo la primera vez
            // (medido: ~750ms del gate de arranque re-bajando avatares).
            await precacheImage(CachedNetworkImageProvider(url), context);
          } else if (url.startsWith('assets/')) {
            await precacheImage(AssetImage(url), context);
          }
        } catch (error, stackTrace) {
          log.w(
            'StartupGate: avatar precache failed for $url',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }),
    );
  }

  void _navigateAfterAuthTransition(String target) {
    if (_pendingAuthNavigation == target) return;
    _pendingAuthNavigation = target;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _pendingAuthNavigation = null;
        return;
      }

      final navigator = _navigatorKey.currentState;
      if (navigator == null) {
        log.e('Auth navigation failed: _navigatorKey.currentState is NULL');
        _pendingAuthNavigation = null;
        return;
      }

      if (target == 'login') {
        navigator.pushNamedAndRemoveUntil('/__login__', (route) => false);
      } else if (target == 'home') {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainScreen(prefs: widget.prefs),
          ),
          (route) => false,
        );
      }

      _pendingAuthNavigation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final customPrimary = ref.watch(primaryColorProvider);
    final locale = ref.watch(localeProvider);
    if (locale != null) {
      Intl.defaultLocale = locale.toLanguageTag();
    } else {
      // If null, it will follow the platform locale which Flutter handles via MaterialApp,
      // but we help Intl a bit by using the first supported locale if no default is set.
      Intl.defaultLocale =
          WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
    }
    final authState = ref.watch(authStateProvider);

    // ── Reactive sign-out: imperatively navigate when auth state changes to
    // isAuthenticated=false, regardless of any route stack sitting on top.
    ref.listen<AsyncValue<AppAuthState>>(authStateProvider, (previous, next) {
      final prev = previous?.value;
      final curr = next.value;

      if (curr != null) {
        log.i(
          'Auth transition: prev=${prev?.isAuthenticated}, curr=${curr.isAuthenticated}, startupReady=$_startupReady',
        );
      }

      if (!_startupReady) return;
      if (curr == null) return;

      if ((prev?.isAuthenticated ?? true) && !curr.isAuthenticated) {
        log.i('Imperative sign-out: Navigating to Login');
        _navigateAfterAuthTransition('login');
        return;
      }

      if (!(prev?.isAuthenticated ?? false) && curr.isAuthenticated) {
        log.i('Imperative sign-in: Navigating to Home');
        _navigateAfterAuthTransition('home');
      }
    });

    return MaterialApp(
      title: 'HomeSync',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      navigatorObservers: [
        if (Firebase.apps.isNotEmpty) _analyticsObserver,
        _breadcrumbObserver,
      ],
      theme: AppTheme.lightTheme(customPrimary: customPrimary),
      darkTheme: AppTheme.darkTheme(customPrimary: customPrimary),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Status/nav bar icons follow the active theme on every screen,
      // including the ones without an AppBar (home tab, splash, login).
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemUi.styleFor(Theme.of(context).brightness),
        child: child ?? const SizedBox.shrink(),
      ),
      routes: {
        '/__login__': (_) => LoginScreen(prefs: widget.prefs),
      },
      home: !_startupReady
          ? const SplashScreen()
          : authState.when(
              data: (state) {
                if (state.isAuthenticated) {
                  return MainScreen(prefs: widget.prefs);
                }
                return LoginScreen(prefs: widget.prefs);
              },
              loading: () => const SplashScreen(),
              error: (e, stack) {
                log.e('Auth bootstrap failed', error: e, stackTrace: stack);
                return LoginScreen(prefs: widget.prefs);
              },
            ),
    );
  }
}
