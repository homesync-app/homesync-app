import 'package:firebase_core/firebase_core.dart';

class AppEnvironment {
  static const String _environmentName =
      String.fromEnvironment('APP_ENV', defaultValue: 'staging');
  static const String _authModeName =
      String.fromEnvironment('AUTH_MODE', defaultValue: 'firebase_third_party');

  static const String _kDefaultSupabaseUrl =
      'https://tfavamqszdkoeabpyxms.supabase.co';
  // Publishable key (formato nuevo, reemplaza al anon key legacy JWT).
  // Es pública por diseño; la seguridad real la dan RLS y los guards de RPC.
  static const String _kDefaultSupabasePublishableKey =
      'sb_publishable_iPBxxteTzC_jHtDQCi5TOg_Hm4qb-m8';

  static Environment get current {
    switch (_environmentName) {
      case 'local':
        return Environment.local;
      case 'production':
        return Environment.production;
      case 'staging':
      default:
        return Environment.staging;
    }
  }

  static AuthMode get authMode {
    switch (_authModeName) {
      case 'firebase_third_party':
        return AuthMode.firebaseThirdParty;
      case 'supabase_native':
      default:
        return AuthMode.supabaseNative;
    }
  }

  // --- Supabase Config ---
  static String get supabaseUrl {
    return const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: _kDefaultSupabaseUrl,
    );
  }

  static String get supabasePublishableKey {
    // Override nuevo primero; SUPABASE_ANON_KEY se respeta como legacy para
    // scripts/.env existentes (la SDK acepta ambos formatos de key).
    const overridden = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (overridden.isNotEmpty) return overridden;
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: _kDefaultSupabasePublishableKey,
    );
  }

  static String get apiUrl {
    const overriddenApiUrl = String.fromEnvironment('API_URL');
    if (overriddenApiUrl.isNotEmpty) return overriddenApiUrl;

    switch (current) {
      case Environment.local:
        return 'http://localhost:3000';
      case Environment.staging:
        return supabaseUrl;
      case Environment.production:
        return const String.fromEnvironment(
          'API_URL_PROD',
          defaultValue: 'https://tfavamqszdkoeabpyxms.supabase.co',
        );
    }
  }

  static bool get isLocal => current == Environment.local;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;
  static bool get usesFirebaseJwtForSupabase =>
      authMode == AuthMode.firebaseThirdParty;

  static bool get enableAdminTesting {
    const override = String.fromEnvironment('ENABLE_ADMIN_TESTING');
    return !isProduction && override.toLowerCase() == 'true';
  }

  static bool get enablePerformanceLogs {
    const override = String.fromEnvironment('ENABLE_PERF_LOGS');
    return !isProduction && _isTruthy(override);
  }

  static String get revenueCatAndroidPublicApiKey {
    return const String.fromEnvironment(
      'REVENUECAT_ANDROID_PUBLIC_API_KEY',
      defaultValue: 'goog_cgdhCLspPBDqYRLmUKsWiNeSHse',
    );
  }

  static String get revenueCatIosPublicApiKey {
    return const String.fromEnvironment(
      'REVENUECAT_IOS_PUBLIC_API_KEY',
      defaultValue: '',
    );
  }

  // --- PostHog (product analytics) ---
  // El project token es público por diseño, igual que la publishable key de
  // Supabase: solo habilita ingestión de eventos, nunca lectura. Se deja como
  // default para que staging y los builds locales reporten sin configurar nada.
  static const String _kDefaultPostHogApiKey =
      'phc_rYKLrdPcVWEgs7Q69boQ46kS5afqYkwUKPLJWDJepauU';

  static String get postHogApiKey {
    return const String.fromEnvironment(
      'POSTHOG_API_KEY',
      defaultValue: _kDefaultPostHogApiKey,
    );
  }

  static String get postHogHost {
    return const String.fromEnvironment(
      'POSTHOG_HOST',
      defaultValue: 'https://us.i.posthog.com',
    );
  }

  /// PostHog se apaga entero poniendo `POSTHOG_API_KEY=""` en el build.
  /// En tests el sink queda inerte porque nunca se llama a `setup()`.
  static bool get postHogEnabled => postHogApiKey.isNotEmpty;

  static String _readWebQueryParam(String key) {
    final value = Uri.base.queryParameters[key];
    return value?.trim() ?? '';
  }

  static bool _isTruthy(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  static String get adminTestingUsername {
    return const String.fromEnvironment(
      'ADMIN_TESTING_USERNAME',
      defaultValue: '',
    );
  }

  static String get adminTestingPassword {
    return const String.fromEnvironment(
      'ADMIN_TESTING_PASSWORD',
      defaultValue: '',
    );
  }

  static bool get adminTestingPasswordLoginEnabled =>
      enableAdminTesting &&
      adminTestingUsername.trim().isNotEmpty &&
      adminTestingPassword.isNotEmpty;

  static bool get adminTestingAutoLogin {
    const override = String.fromEnvironment('ADMIN_TESTING_AUTO_LOGIN');
    final queryOverride = _readWebQueryParam('qaAutoLogin');
    return enableAdminTesting &&
        (_isTruthy(override) || _isTruthy(queryOverride));
  }

  static String get adminTestingAutoScenarioId {
    const override = String.fromEnvironment(
      'ADMIN_TESTING_AUTO_SCENARIO_ID',
      defaultValue: '',
    );
    if (override.isNotEmpty) return override;
    return _readWebQueryParam('qaScenario');
  }

  static String get adminTestingAutoViewerUserId {
    const override = String.fromEnvironment(
      'ADMIN_TESTING_AUTO_VIEWER_USER_ID',
      defaultValue: '',
    );
    if (override.isNotEmpty) return override;
    return _readWebQueryParam('qaViewer');
  }

  static bool get adminTestingAutoRealQaLogin {
    const override = String.fromEnvironment('ADMIN_TESTING_AUTO_REAL_QA_LOGIN');
    final queryOverride = _readWebQueryParam('qaRealSession');
    return enableAdminTesting &&
        (_isTruthy(override) || _isTruthy(queryOverride));
  }

  static String get adminTestingBaseEmail {
    return const String.fromEnvironment(
      'ADMIN_TESTING_BASE_EMAIL',
      defaultValue: '',
    );
  }

  static String get adminTestingBasePassword {
    return const String.fromEnvironment(
      'ADMIN_TESTING_BASE_PASSWORD',
      defaultValue: '',
    );
  }

  static bool get adminTestingAutoAdminSessionEnabled =>
      enableAdminTesting &&
      adminTestingBaseEmail.trim().isNotEmpty &&
      adminTestingBasePassword.isNotEmpty;

  // Validates that required runtime config is present
  static void validateRuntimeConfig({required bool isWeb}) {
    if (!isProduction) return;

    final violations = <String>[];
    // NOTE: the default Supabase constants ARE the production project values,
    // so we validate that the resolved config is a real, well-formed Supabase
    // URL/key — NOT that it differs from the defaults (which would always fail
    // in production and crash the app at startup).
    if (!supabaseUrl.startsWith('https://') || !supabaseUrl.contains('.supabase.co')) {
      violations.add('SUPABASE_URL');
    }
    if (supabasePublishableKey.length < 40) {
      violations.add('SUPABASE_PUBLISHABLE_KEY');
    }
    if (violations.isNotEmpty) {
      throw StateError(
        'Production build has invalid Supabase config for: ${violations.join(", ")}. '
        'Provide --dart-define-from-file=.env.production or valid '
        '--dart-define=SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY values.',
      );
    }
  }

  // --- Firebase Config ---
  static String get firebaseProjectId {
    return const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'homesync-prod-r7-123',
    );
  }

  static String get firebaseApiKey {
    return const String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: 'AIzaSyAOH6ZSuqIzI1qOUIynDbWGwOQRym_Wb1I',
    );
  }

  static String get firebaseAppId {
    return const String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: '1:105041112830:android:581bf3abf4b65e9167ffaf',
    );
  }

  static String get firebaseMessagingSenderId {
    return const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '105041112830',
    );
  }

  static String get firebaseAuthDomain {
    return const String.fromEnvironment(
      'FIREBASE_AUTH_DOMAIN',
      defaultValue: 'homesync-prod-r7-123.firebaseapp.com',
    );
  }

  static String get firebaseStorageBucket {
    return const String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: 'homesync-prod-r7-123.firebasestorage.app',
    );
  }

  static String get googleWebClientId {
    return const String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue:
          '105041112830-75q9ubotcf7i51cu8u9v9l9j1m6sdcga.apps.googleusercontent.com',
    );
  }

  static FirebaseOptions get firebaseOptions => FirebaseOptions(
        apiKey: firebaseApiKey,
        appId: firebaseAppId,
        messagingSenderId: firebaseMessagingSenderId,
        projectId: firebaseProjectId,
        authDomain: firebaseAuthDomain,
        storageBucket: firebaseStorageBucket,
      );
}

enum Environment {
  local,
  staging,
  production,
}

enum AuthMode {
  supabaseNative,
  firebaseThirdParty,
}
