import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> setUserId(String? userId) async {
    await _safeCall(
      'setUserId',
      () => _analytics.setUserId(id: userId),
    );
  }

  Future<void> setUserProperty({
    required String name,
    String? value,
  }) async {
    await _safeCall(
      'setUserProperty:$name',
      () => _analytics.setUserProperty(name: name, value: value),
    );
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

  Future<void> trackPremiumRestoreStarted() async {
    await logEvent('premium_restore_started');
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
        log.w('Analytics skipped in $context',
            error: error, stackTrace: stackTrace,);
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
