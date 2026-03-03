import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/rpc/admin_rpc_service.dart';
import 'package:homesync_client/theme/app_colors.dart';
import 'package:homesync_client/theme/app_theme.dart';
import 'package:homesync_client/features/auth/presentation/screens/login_screen.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/auth/presentation/providers/auth_providers.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

  final adminRpc = AdminRpcService();

  // Dual error pipeline: Crashlytics (Android/iOS) + Supabase (admin logs)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 1. Only send to Crashlytics on mobile (not supported on web)
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    // 2. Send to Supabase for the admin panel logs page (all platforms)
    adminRpc.logApplicationError(
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
    adminRpc.logApplicationError(
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeModeProvider.notifier).init(prefs);
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
    final authState = ref.watch(authStateProvider);

    return _ThemeInit(
      prefs: prefs,
      child: MaterialApp(
        title: 'HomeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: authState.when(
          data: (state) {
            if (state.session != null) {
              return MainScreen(prefs: prefs);
            }
            return LoginScreen(prefs: prefs);
          },
          loading: () => const _SplashScreen(),
          error: (e, stack) {
            debugPrint('Auth error: $e');
            return LoginScreen(prefs: prefs);
          },
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🏡', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

