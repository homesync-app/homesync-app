import 'package:homesync_client/core/services/logger_service.dart';
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
    log.e('Firebase initialization error: $e');
  }

  final auth = SupabaseAuthService();
  await auth.initialize();

  final adminRpc = AdminRpcService();

  // Dual error pipeline: Crashlytics (Android/iOS) + Supabase (admin logs)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 1. Only send to Crashlytics on mobile
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
    // 2. Log to our central service
    log.e('Uncaught Flutter Error: ${details.exception}', error: details.exception, stackTrace: details.stack);
    
    // 3. Send to Supabase for the admin panel logs page
    adminRpc.logApplicationError(
      message: details.exceptionAsString(),
      stackTrace: details.stack?.toString(),
      context: {'library': details.library, 'context': details.context?.toString()},
    );
  };

  // Catch async errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    log.f('Fatal Async Error: $error', error: error, stackTrace: stack);
    
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

    return _ThemeInit(
      prefs: prefs,
      child: MaterialApp(
        title: 'HomeSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: _RootScreen(prefs: prefs),
      ),
    );
  }
}

class _RootScreen extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  const _RootScreen({required this.prefs});

  @override
  ConsumerState<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<_RootScreen> {
  bool _splashFinished = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _splashFinished = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    Widget currentScreen;
    if (!_splashFinished || authState.isLoading) {
      currentScreen = const _SplashScreen(key: ValueKey('splash'));
    } else {
      currentScreen = authState.when(
        data: (state) {
          if (state.session != null) {
            return MainScreen(key: const ValueKey('main'), prefs: widget.prefs);
          }
          return LoginScreen(key: const ValueKey('login'), prefs: widget.prefs);
        },
        loading: () => const _SplashScreen(key: ValueKey('splash_fallback')),
        error: (e, stack) => LoginScreen(key: const ValueKey('login_error'), prefs: widget.prefs),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: currentScreen,
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen({super.key});

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏡', style: TextStyle(fontSize: 60)),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


