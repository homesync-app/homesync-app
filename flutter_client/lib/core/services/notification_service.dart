import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  NotificationCallback? _onNotification;
  bool _isEnabled = true;
  Future<void>? _firebaseSetupFuture;
  bool _firebaseConfigured = false;

  Future<void> initialize({NotificationCallback? onNotification}) async {
    _onNotification = onNotification;

    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('notifications_enabled') ?? true;

    await _setupRealtimeListener();
    if (!kIsWeb && _isEnabled) {
      await _setupFirebase();
    }
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
      await _deleteFcmToken();
    }
  }

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
            log.i('Nueva notificacion: $title - $body');
            _onNotification?.call(title, body);
          },
        )
        .subscribe();

    log.i('NotificationService: Realtime listener activo');
  }

  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<void> _setupFirebase() async {
    if (_firebaseConfigured) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }
      return;
    }
    if (_firebaseSetupFuture != null) {
      await _firebaseSetupFuture;
      return;
    }

    _firebaseSetupFuture = _configureFirebaseMessaging();
    try {
      await _firebaseSetupFuture;
    } finally {
      _firebaseSetupFuture = null;
    }
  }

  Future<void> _configureFirebaseMessaging() async {
    if (Firebase.apps.isEmpty) {
      log.w('NotificationService: Firebase no inicializado. Push bloqueado.');
      return;
    }

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    log.i('Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log.w('Usuario denego permiso de notificaciones');
      return;
    }

    final token = await messaging.getToken();
    if (token != null) {
      await _saveFcmToken(token);
    }

    messaging.onTokenRefresh.listen(_saveFcmToken);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.i('FCM foreground: ${message.notification?.title}');
      _onNotification?.call(
        message.notification?.title ?? 'HomeSync',
        message.notification?.body ?? '',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log.i('FCM tap from background: ${message.data}');
    });

    _firebaseConfigured = true;
    log.i('NotificationService: Firebase Messaging configurado');
  }

  Future<void> _saveFcmToken(String token) async {
    final appUserId = AppIdentityService.instance.currentUserId;
    if (appUserId == null || !_isEnabled) return;
    // In Firebase-auth mode, use AppIdentityService instead of supabase.auth
    // to avoid AuthException when accessToken mode is not configured.
    final authUserId = appUserId;
    if (AppEnvironment.enableAdminTesting && authUserId != appUserId) {
      log.i('QA admin mode activo: omitimos guardado de FCM token');
      return;
    }

    try {
      await _supabase.from('user_fcm_tokens').upsert(
        {
          'user_id': appUserId,
          'token': token,
          'platform': defaultTargetPlatform.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
      log.i('FCM token guardado');
    } catch (e, stack) {
      log.e('Error guardando FCM token: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> _deleteFcmToken() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId == null) return;

    try {
      await _supabase
          .from('user_fcm_tokens')
          .delete()
          .eq('user_id', appUserId)
          .eq('platform', defaultTargetPlatform.name);
      log.i('FCM tokens eliminados del servidor');
    } catch (e, stack) {
      log.e('Error eliminando FCM token: $e', error: e, stackTrace: stack);
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
    } catch (e, stack) {
      log.e('Error creando notificacion: $e', error: e, stackTrace: stack);
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
    } catch (e, stack) {
      log.e('Error enviando notificacion: $e', error: e, stackTrace: stack);
    }
  }
}

typedef NotificationCallback = void Function(String title, String body);
