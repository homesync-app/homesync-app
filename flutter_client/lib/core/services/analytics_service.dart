import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';
import 'posthog_sink.dart';

/// Punto único de instrumentación. Hace fan-out a Firebase Analytics (Play,
/// Crashlytics) y a PostHog (funnels, retención, cohortes, experimentos).
///
/// Las features NUNCA llaman a un SDK de analytics directo: agregan un método
/// `trackX` acá y lo invocan. Así sumar o sacar un destino es un solo cambio.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics, PostHogSink? postHog})
      : _analyticsOverride = analytics,
        _postHog = postHog ?? PostHogSink.instance;

  final FirebaseAnalytics? _analyticsOverride;
  final PostHogSink _postHog;

  FirebaseAnalytics get _analytics =>
      _analyticsOverride ?? FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> setUserId(String? userId) async {
    await _safeCall(
      'setUserId',
      () => _analytics.setUserId(id: userId),
    );
    // En PostHog identify y reset no son simétricos: un `identify(null)` no
    // existe, hay que cortar la sesión explícitamente al desloguear.
    if (userId == null) {
      await _postHog.reset();
    } else {
      await _postHog.identify(userId);
    }
  }

  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    await _safeCall(
      'setUserProperty:$name',
      () => _analytics.setUserProperty(name: name, value: value),
    );
    if (value != null) {
      // Super property: viaja en todos los eventos, que es lo que permite
      // segmentar retención y funnels por modo / premium sin joins.
      await _postHog.register(name, value);
    }
  }

  Future<void> trackAppOpened({
    required String environment,
    required String platform,
    required String appVersion,
  }) async {
    await logEvent(
      'app_opened',
      parameters: {
        'environment': environment,
        'platform': platform,
        'app_version': appVersion,
      },
    );
  }

  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _safeCall(
      'screenView:$screenName',
      () => _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      ),
    );
    await _postHog.screen(screenName, screenClass: screenClass ?? screenName);
  }

  Future<void> trackAuthStarted({
    required String method,
    bool isSignUp = false,
  }) async {
    await logEvent(
      isSignUp ? 'auth_sign_up_started' : 'auth_sign_in_started',
      parameters: {
        'method': method,
      },
    );
  }

  Future<void> trackAuthSucceeded({
    required String method,
    bool isSignUp = false,
  }) async {
    await logEvent(
      isSignUp ? 'auth_sign_up_succeeded' : 'auth_sign_in_succeeded',
      parameters: {
        'method': method,
      },
    );
  }

  Future<void> trackAuthFailed({
    required String method,
    required String reason,
    bool isSignUp = false,
  }) async {
    await logEvent(
      isSignUp ? 'auth_sign_up_failed' : 'auth_sign_in_failed',
      parameters: {
        'method': method,
        'reason': _normalizeParam(reason),
      },
    );
  }

  // --- Funnel de activación -------------------------------------------------
  // El orden es: auth_sign_up_succeeded → setup_step_viewed (x8) →
  // setup_completed → invite_sent → invite_accepted →
  // household_second_member_joined → first_expense_created.
  // `household_second_member_joined` es LA métrica del negocio: sin segundo
  // miembro, una app de hogar compartido no tiene producto.

  /// Un paso del wizard quedó a la vista. Emitir en cada avance permite ver en
  /// qué paso exacto se cae la gente antes de rediseñar nada.
  Future<void> trackSetupStepViewed({
    required String step,
    required String mode,
  }) async {
    await logEvent(
      'setup_step_viewed',
      parameters: {
        'step': step,
        'mode': mode,
      },
    );
  }

  /// El wizard terminó. [joined] distingue al que creó el hogar del que entró
  /// con código: son dos funnels con motivaciones distintas.
  Future<void> trackSetupCompleted({
    required String mode,
    required bool joined,
  }) async {
    await logEvent(
      'setup_completed',
      parameters: {
        'mode': mode,
        'path': joined ? 'joined' : 'created',
      },
    );
  }

  /// Se compartió el código de invitación. [channel]: whatsapp | share | copy.
  Future<void> trackInviteSent({
    required String mode,
    required String channel,
  }) async {
    await logEvent(
      'invite_sent',
      parameters: {
        'mode': mode,
        'channel': channel,
      },
    );
  }

  /// Alguien entró a un hogar con un código válido.
  Future<void> trackInviteAccepted({required String mode}) async {
    await logEvent(
      'invite_accepted',
      parameters: {
        'mode': mode,
      },
    );
  }

  /// El hogar dejó de estar solo. Se emite una única vez por dispositivo:
  /// mide el hito, no el tamaño del hogar.
  Future<void> trackHouseholdSecondMemberJoined({
    required String mode,
    required int memberCount,
  }) async {
    await _trackOnce(
      storageKey: 'analytics_household_second_member',
      eventName: 'household_second_member_joined',
      parameters: {
        'mode': mode,
        'member_count': memberCount,
      },
    );
  }

  Future<void> trackTaskCreated({
    required String category,
    required String difficulty,
  }) async {
    await logEvent(
      'task_created',
      parameters: {
        'category': category,
        'difficulty': difficulty,
      },
    );

    await _trackOnce(
      storageKey: 'analytics_first_task_created',
      eventName: 'first_task_created',
      parameters: {
        'category': category,
        'difficulty': difficulty,
      },
    );
  }

  Future<void> trackExpenseCreated({
    required String category,
    required String splitType,
    required String entryType,
  }) async {
    await logEvent(
      'expense_created',
      parameters: {
        'category': category,
        'split_type': splitType,
        'entry_type': entryType,
      },
    );

    await _trackOnce(
      storageKey: 'analytics_first_expense_created',
      eventName: 'first_expense_created',
      parameters: {
        'category': category,
        'split_type': splitType,
        'entry_type': entryType,
      },
    );
  }

  // --- Funnel de monetización -----------------------------------------------
  // paywall_opened → premium_purchase_started → premium_purchase_completed.
  // Cada paso tiene su salida (dismissed / cancelled / failed): sin ellas no se
  // puede distinguir "no le interesó" de "quiso pagar y no pudo".

  Future<void> trackPaywallOpened({
    required String source,
    required String variant,
  }) async {
    await logEvent(
      'paywall_opened',
      parameters: {
        'source': source,
        'variant': variant,
      },
    );
  }

  /// El paywall se cerró sin compra. Junto con `paywall_opened` da la tasa de
  /// rebote por `source`, que es lo que dice qué gate vale la pena empujar.
  Future<void> trackPaywallDismissed({
    required String source,
    required String variant,
  }) async {
    await logEvent(
      'paywall_dismissed',
      parameters: {
        'source': source,
        'variant': variant,
      },
    );
  }

  Future<void> trackPremiumPurchaseStarted({
    required String productId,
  }) async {
    await logEvent(
      'premium_purchase_started',
      parameters: {
        'product_id': productId,
      },
    );
  }

  /// Compra confirmada por la tienda. Sin este evento la conversión real es
  /// inobservable: `purchase_started` solo dice que abrió el diálogo de pago.
  Future<void> trackPremiumPurchaseCompleted({
    required String productId,
  }) async {
    await logEvent(
      'premium_purchase_completed',
      parameters: {
        'product_id': productId,
      },
    );
  }

  /// El usuario cerró el diálogo de pago. No es un error: es señal de precio,
  /// de momento o de confianza, y hay que poder separarla de `failed`.
  Future<void> trackPremiumPurchaseCancelled({
    required String productId,
  }) async {
    await logEvent(
      'premium_purchase_cancelled',
      parameters: {
        'product_id': productId,
      },
    );
  }

  Future<void> trackPremiumPurchaseFailed({
    required String productId,
    required String errorCode,
  }) async {
    await logEvent(
      'premium_purchase_failed',
      parameters: {
        'product_id': productId,
        'error_code': errorCode,
      },
    );
  }

  Future<void> trackPremiumRestoreStarted() async {
    await logEvent('premium_restore_started');
  }

  Future<void> trackPremiumRestoreCompleted({required bool restored}) async {
    await logEvent(
      'premium_restore_completed',
      parameters: {
        'restored': restored,
      },
    );
  }

  Future<void> trackMainTabOpened({
    required String tab,
    required String source,
  }) async {
    await logEvent(
      'main_tab_opened',
      parameters: {
        'tab': tab,
        'source': source,
      },
    );
  }

  Future<void> trackDashboardAction({
    required String action,
    String? source,
  }) async {
    await logEvent(
      'dashboard_action_tapped',
      parameters: {
        'action': action,
        if (source != null) 'source': source,
      },
    );
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    final sanitized = <String, Object>{};
    for (final entry in (parameters ?? const <String, Object?>{}).entries) {
      final value = entry.value;
      if (value == null) continue;
      final normalized = _normalizeValue(value);
      if (normalized != null) {
        sanitized[entry.key] = normalized;
      }
    }

    await _safeCall(
      'logEvent:$name',
      () => _analytics.logEvent(
        name: name,
        parameters: sanitized.isEmpty ? null : sanitized,
      ),
    );
    await _postHog.capture(name, sanitized);
  }

  Object? _normalizeValue(Object value) {
    if (value is String) return _normalizeParam(value);
    if (value is num || value is bool) return value;
    return _normalizeParam(value.toString());
  }

  String _normalizeParam(String value) {
    final cleaned =
        value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    if (cleaned.isEmpty) return 'unknown';
    return cleaned.length <= 100 ? cleaned : cleaned.substring(0, 100);
  }

  Future<void> _safeCall(
    String context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        log.w(
          'Analytics skipped in $context: $error',
          error: error,
          stackTrace: stackTrace,
        );
      } else {
        log.w(
          'Analytics skipped in $context',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _trackOnce({
    required String storageKey,
    required String eventName,
    Map<String, Object?>? parameters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyTracked = prefs.getBool(storageKey) ?? false;
      if (alreadyTracked) return;

      await logEvent(eventName, parameters: parameters);
      await prefs.setBool(storageKey, true);
    } catch (error, stackTrace) {
      log.w(
        'Analytics one-time event skipped: $eventName',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
