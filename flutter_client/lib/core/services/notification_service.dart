import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotificationService
//
// ESTADO ACTUAL: Notificaciones IN-APP via Supabase Realtime (sin Firebase).
// El realtime escucha inserciones en la tabla `notifications` y las muestra
// mientras la app está abierta.
//
// PARA ACTIVAR PUSH NOTIFICATIONS NATIVAS (app cerrada):
// 1. Crear proyecto en https://console.firebase.google.com
// 2. Registrar la app Android (com.example.homeSync) y/o iOS
// 3. Descargar google-services.json → android/app/google-services.json
// 4. Descargar GoogleService-Info.plist → ios/Runner/GoogleService-Info.plist
// 5. Ejecutar en la raíz del proyecto:
//    dart pub global activate flutterfire_cli
//    flutterfire configure
// 6. Descomentar el bloque "=== FIREBASE ===" de este archivo
// 7. Agregar a pubspec.yaml:
//    firebase_core: ^3.0.0
//    firebase_messaging: ^15.0.0
// 8. Agregar al android/build.gradle:
//    classpath 'com.google.gms:google-services:4.4.0'
// 9. Agregar al android/app/build.gradle:
//    apply plugin: 'com.google.gms.google-services'
// ─────────────────────────────────────────────────────────────────────────────

// === FIREBASE (descomentar después de configurar Firebase) ==================
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
// ============================================================================

typedef NotificationCallback = void Function(String title, String body);

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  NotificationCallback? _onNotification;
  bool _isEnabled = true; // Default

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize({NotificationCallback? onNotification}) async {
    _onNotification = onNotification;
    
    // Load preference
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('notifications_enabled') ?? true;

    await _setupRealtimeListener();
    // === FIREBASE (Mobile Only) =============================================
    if (!kIsWeb && _isEnabled) {
      await _setupFirebase();
    }
    // =======================================================================
  }

  bool get isEnabled => _isEnabled;

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      if (!kIsWeb) {
        await _setupFirebase();
      }
    } else {
      // If disabled, we might want to tell the server to remove this token
      await _deleteFcmToken();
    }
  }

  // ── Supabase Realtime (in-app notifications) ──────────────────────────────

  Future<void> _setupRealtimeListener() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _channel = _supabase
        .channel('notifications:${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            final title = record['title'] as String? ?? 'HomeSync';
            final body = record['body'] as String? ?? '';
            debugPrint('🔔 Nueva notificación: $title — $body');
            _onNotification?.call(title, body);
          },
        )
        .subscribe();

    debugPrint('✅ NotificationService: Realtime listener activo');
  }

  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
  }

  // FCM Token Management
  Future<void> _setupFirebase() async {
    // Check if Firebase is initialized to avoid [core/no-app] error
    if (Firebase.apps.isEmpty) {
      debugPrint('⚠️ NotificationService: Firebase no inicializado. Push bloqueado.');
      return;
    }
    
    final messaging = FirebaseMessaging.instance;

    // 1. Request permission (iOS requires explicit permission)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('⚠️ Usuario denegó permiso de notificaciones');
      return;
    }

    // 2. Get the FCM token and save it to Supabase
    final token = await messaging.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }

    // 3. Listen for token refresh
    messaging.onTokenRefresh.listen(_saveFcmToken);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 FCM Foreground: ${message.notification?.title}');
      _onNotification?.call(
        message.notification?.title ?? 'HomeSync',
        message.notification?.body ?? '',
      );
    });

    // 5. Handle background/terminated tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📲 FCM tap from background: ${message.data}');
    });

    debugPrint('✅ NotificationService: Firebase Messaging configurado');
  }

  Future<void> _saveFcmToken(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null || !_isEnabled) return;

    try {
      await _supabase.from('user_fcm_tokens').upsert({
        'user_id': user.id,
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');
      debugPrint('✅ FCM token guardado');
    } catch (e) {
      debugPrint('Error guardando FCM token: $e');
    }
  }

  Future<void> _deleteFcmToken() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // This will remove all tokens for this user on this platform.
      // A more precise way would be to get the current token and delete only that,
      // but this is a good first step to "mute" lahat devices.
      await _supabase
          .from('user_fcm_tokens')
          .delete()
          .eq('user_id', user.id)
          .eq('platform', defaultTargetPlatform.name);
      debugPrint('✅ FCM tokens eliminados del servidor');
    } catch (e) {
      debugPrint('Error eliminando FCM token: $e');
    }
  }
  // ==========================================================================

  // ── Helper: push a local notification to Supabase (server-side trigger) ───

  /// Insert a notification record manually (useful for testing).
  /// In production, notifications are created by Supabase Edge Functions
  /// or database triggers after TaskModel completion, expenses, etc.
  Future<void> createLocalNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'system',
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creando notificación: $e');
    }
  }

  // ── Send notification to a specific user (via Supabase Edge Function) ─────

  /// Calls the Supabase Edge Function `send-notification` to push a
  /// notification to another household member. Requires the Edge Function
  /// to be deployed (see supabase/functions/send-notification).
  Future<void> notifyMember({
    required String toUserId,
    required String title,
    required String body,
    String type = 'system',
  }) async {
    try {
      await _supabase.functions.invoke(
        'send-notification',
        body: {
          'to_user_id': toUserId,
          'title': title,
          'body': body,
          'type': type,
        },
      );
    } catch (e) {
      debugPrint('Error enviando notificación: $e');
    }
  }
}
