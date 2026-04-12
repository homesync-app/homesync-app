import 'package:firebase_core/firebase_core.dart';

class AppEnvironment {
  static const String _environmentName =
      String.fromEnvironment('APP_ENV', defaultValue: 'staging');
  static const String _authModeName =
      String.fromEnvironment('AUTH_MODE', defaultValue: 'firebase_third_party');

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
      defaultValue: 'https://tfavamqszdkoeabpyxms.supabase.co',
    );
  }

  static String get supabaseAnonKey {
    return const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmYXZhbXFzemRrb2VhYnB5eG1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMjU5MTYsImV4cCI6MjA4NjkwMTkxNn0.AifBdMFJH14E-JisRcdjWPNpjAOuj6z3J4aYYRxBCSI',
    );
  }

  static String get apiUrl {
    // apiUrl can be overridden via environment variable, otherwise falls back to defaults per environment
    const overriddenApiUrl = String.fromEnvironment('API_URL');
    if (overriddenApiUrl.isNotEmpty) return overriddenApiUrl;

    switch (current) {
      case Environment.local:
        return 'http://localhost:3000';
      case Environment.staging:
        return supabaseUrl;
      case Environment.production:
        return const String.fromEnvironment('API_URL_PROD',
            defaultValue: 'https://api.homesync.com');
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
      defaultValue: '1:105041112830:web:da6228c6d202cdf567ffaf',
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
