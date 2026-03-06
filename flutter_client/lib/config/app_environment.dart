import 'package:firebase_core/firebase_core.dart';

class AppEnvironment {
  static const Environment current = Environment.staging;

  static String get supabaseUrl {
    return const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://tfavamqszdkoeabpyxms.supabase.co');
  }

  static String get supabaseAnonKey {
    return const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmYXZhbXFzemRrb2VhYnB5eG1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzMjU5MTYsImV4cCI6MjA4NjkwMTkxNn0.AifBdMFJH14E-JisRcdjWPNpjAOuj6z3J4aYYRxBCSI');
  }

  static String get apiUrl {
    switch (current) {
      case Environment.local:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://tfavamqszdkoeabpyxms.supabase.co';
      case Environment.production:
        return 'https://api.homesync.com';
    }
  }

  static bool get isLocal => current == Environment.local;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;

  // Firebase Options (proyecto homesync-prod-r7-123)
  static var firebaseOptions = const FirebaseOptions(
    apiKey: 'AIzaSyAOH6ZSuqIzI1qOUIynDbWGwOQRym_Wb1I',
    appId: '1:105041112830:web:da6228c6d202cdf567ffaf',
    messagingSenderId: '105041112830',
    projectId: 'homesync-prod-r7-123',
    authDomain: 'homesync-prod-r7-123.firebaseapp.com',
    storageBucket: 'homesync-prod-r7-123.firebasestorage.app',
  );
}

enum Environment {
  local,
  staging,
  production,
}
