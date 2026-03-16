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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force use of bundled assets for fonts to prevent network errors
  GoogleFonts.config.allowRuntimeFetching = false;
  
  // 1. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: kIsWeb ? AppEnvironment.firebaseOptions : null,
    );
    // Pass ALL uncaught Flutter errors to Crashlytics (Android/iOS only)
    if (!kIsWeb) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  final auth = SupabaseAuthService();
  await auth.initialize();

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
      context: {'library': details.library, 'context': details.context?.toString()},
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

class MyApp extends ConsumerWidget {
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final customPrimary = ref.watch(primaryColorProvider);
    final authState = ref.watch(authStateProvider);

    return _ThemeInit(
      prefs: prefs,
      child: MaterialApp(
        key: ValueKey(authState.asData?.value.session != null),
        title: 'HomeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(customPrimary: customPrimary),
        darkTheme: AppTheme.darkTheme(customPrimary: customPrimary),
        themeMode: themeMode,
        home: authState.when(
          data: (state) {
            if (state.session != null) {
              return MainScreen(prefs: prefs);
            }
            return LoginScreen(prefs: prefs);
          },
          loading: () => const SplashScreen(),
          error: (e, stack) {
            debugPrint('Auth error: $e');
            return LoginScreen(prefs: prefs);
          },
        ),
      ),
    );
  }
}


