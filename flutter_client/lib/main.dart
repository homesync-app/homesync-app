import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/features/auth/presentation/screens/splash_screen.dart';
import 'package:homesync_client/features/auth/presentation/screens/login_screen.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/main_screen.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/premium_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force use of bundled assets for fonts to prevent network errors
  GoogleFonts.config.allowRuntimeFetching = false;

  final packageInfo = await PackageInfo.fromPlatform();
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
    debugPrint('Device info error: $e');
  }

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

  // 1. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: kIsWeb ? AppEnvironment.firebaseOptions : null,
    );
    // Pass ALL uncaught Flutter errors to Crashlytics (Android/iOS only)
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
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
    debugPrint('Firebase initialization error: $e');
  }

  final auth = SupabaseAuthService();
  await auth.initialize();
  await AppIdentityService.instance.initialize();

  if (!kIsWeb) {
    final userId = AppIdentityService.instance.currentUserId;
    if (userId != null && userId.isNotEmpty) {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
      FirebaseCrashlytics.instance.setCustomKey('user_id', userId);
    }
  }
  final initialUserId = AppIdentityService.instance.currentUserId;
  if (initialUserId != null && initialUserId.isNotEmpty) {
    log.setUserId(initialUserId);
    log.setCustomKey('user_id', initialUserId);
  }

  final authStateStream = AppEnvironment.usesFirebaseJwtForSupabase
      ? fa.FirebaseAuth.instance.idTokenChanges().map((_) => null)
      : Supabase.instance.client.auth.onAuthStateChange.map((_) => null);

  authStateStream.listen((_) async {
    final nextUserId = await AppIdentityService.instance.refresh();
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.setUserIdentifier(nextUserId ?? '');
      FirebaseCrashlytics.instance.setCustomKey('user_id', nextUserId ?? '');
    }
    if (nextUserId != null && nextUserId.isNotEmpty) {
      log.setUserId(nextUserId);
      log.setCustomKey('user_id', nextUserId);
    } else {
      log.setUserId('');
      log.setCustomKey('user_id', '');
    }
  });

  final rpc = SupabaseRpcService();
  await rpc.initialize();

  // Dual error pipeline: Crashlytics (Android/iOS) + Supabase (admin logs)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 1. Only send to Crashlytics on mobile (not supported on web)
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    // 2. Send to Supabase for the admin panel logs page (all platforms)
    rpc.logApplicationError(
      message: details.exceptionAsString(),
      stackTrace: details.stack?.toString(),
      context: {
        ...richContext,
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
  };

  // Catch async errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    // 1. Crashlytics — marks as fatal (mobile only)
    if (!kIsWeb) {
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

  await initializeDateFormatting('es', null);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        rpcServiceProvider.overrideWithValue(rpc),
      ],
      child: MyApp(
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(themeModeProvider.notifier).init(prefs);
      await ref.read(primaryColorProvider.notifier).init(prefs);
    });
    return child;
  }
}

class MyApp extends ConsumerStatefulWidget {
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.prefs,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static const _minimumSplashDuration = Duration(milliseconds: 2800);
  bool _startupReady = false;

  @override
  void initState() {
    super.initState();
    // Initialize premium service on app start
    ref.read(premiumServiceProvider);
    _completeStartupGate();
  }

  Future<void> _completeStartupGate() async {
    final authState = await ref.read(authStateProvider.future).catchError(
          (_) => const AppAuthState(
            isAuthenticated: false,
            source: 'bootstrap_error',
          ),
        );

    final bootstrapTasks = <Future<void>>[
      Future<void>.delayed(_minimumSplashDuration),
    ];

    if (authState.isAuthenticated) {
      bootstrapTasks.add(
        ref.read(householdIdProvider.future).then((_) {}).catchError((_) {}),
      );
    }

    await Future.wait(bootstrapTasks);

    if (!mounted) return;

    setState(() {
      _startupReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final customPrimary = ref.watch(primaryColorProvider);
    final authState = ref.watch(authStateProvider);

    return _ThemeInit(
      prefs: widget.prefs,
      child: MaterialApp(
        title: 'HomeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(customPrimary: customPrimary),
        darkTheme: AppTheme.darkTheme(customPrimary: customPrimary),
        themeMode: themeMode,
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
                  debugPrint('Auth error: $e');
                  return LoginScreen(prefs: widget.prefs);
                },
              ),
      ),
    );
  }
}
