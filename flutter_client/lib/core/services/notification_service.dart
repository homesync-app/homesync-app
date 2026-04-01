import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:homesync_client/config/app_environment.dart';

class NotificationService {
  NotificationService({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  final SupabaseClient _supabase;
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
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId == null) return;

    _channel = _supabase
        .channel('notifications:$appUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: appUserId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            final title = record['title'] as String? ?? 'HomeSync';
            final body = record['body'] as String? ?? '';
            log.i('🔔 Nueva notificación: $title — $body');
            _onNotification?.call(title, body);
          },
        )
        .subscribe();

    log.i('✅ NotificationService: Realtime listener activo');
  }

  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
  }

  // FCM Token Management
  Future<void> _setupFirebase() async {
    // Check if Firebase is initialized to avoid [core/no-app] error
    if (Firebase.apps.isEmpty) {
      log.w(
          '⚠️ NotificationService: Firebase no inicializado. Push bloqueado.');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    // 1. Request permission (iOS requires explicit permission)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log.i('Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log.w('⚠️ Usuario denegó permiso de notificaciones');
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
      log.i('🔔 FCM Foreground: ${message.notification?.title}');
      _onNotification?.call(
        message.notification?.title ?? 'HomeSync',
        message.notification?.body ?? '',
      );
    });

    // 5. Handle background/terminated tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log.i('📲 FCM tap from background: ${message.data}');
    });

    log.i('✅ NotificationService: Firebase Messaging configurado');
  }

  Future<void> _saveFcmToken(String token) async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId == null || !_isEnabled) return;
    final authUserId = _supabase.auth.currentUser?.id;
    if (AppEnvironment.enableAdminTesting &&
        authUserId != null &&
        authUserId != appUserId) {
      log.i('QA admin mode activo: omitimos guardado de FCM token');
      return;
    }

    try {
      await _supabase.from('user_fcm_tokens').upsert({
        'user_id': appUserId,
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');
      log.i('✅ FCM token guardado');
    } catch (e) {
      log.e('Error guardando FCM token: $e', error: e);
    }
  }

  Future<void> _deleteFcmToken() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId == null) return;
    final authUserId = _supabase.auth.currentUser?.id;
    if (AppEnvironment.enableAdminTesting &&
        authUserId != null &&
        authUserId != appUserId) {
      return;
    }

    try {
      await _supabase
          .from('user_fcm_tokens')
          .delete()
          .eq('user_id', appUserId)
          .eq('platform', defaultTargetPlatform.name);
      log.i('✅ FCM tokens eliminados del servidor');
    } catch (e) {
      log.e('Error eliminando FCM token: $e', error: e);
    }
  }

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
      log.e('Error creando notificación: $e', error: e);
    }
  }

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
      log.e('Error enviando notificación: $e', error: e);
    }
  }
}

typedef NotificationCallback = void Function(String title, String body);
