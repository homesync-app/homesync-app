import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';

/// Centralized logging service for the application.
/// Replaces print() and debugPrint() with structured logging.
/// Integrated with Firebase Crashlytics for production error reporting.
class LoggerService {
  LoggerService._privateConstructor();
  static final LoggerService _instance = LoggerService._privateConstructor();
  static LoggerService get instance => _instance;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
    level: kDebugMode ? Level.trace : Level.info,
  );

  /// Log a trace message (very detailed, step-by-step)
  void t(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log a debug message (useful during development)
  void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an info message (e.g., successful API call, state change)
  void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message (something unexpected happened but not fatal)
  void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    _reportToCrashlytics(message, error, stackTrace, isFatal: false);
  }

  /// Log an error message (something failed)
  void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _reportToCrashlytics(message, error, stackTrace, isFatal: true);
  }

  /// Log a fatal error (app is about to crash)
  void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _reportToCrashlytics(message, error, stackTrace, isFatal: true);
  }

  /// Reports errors to Crashlytics in production (mobile only).
  void _reportToCrashlytics(
      dynamic message, Object? error, StackTrace? stackTrace,
      {required bool isFatal}) {
    if (kDebugMode || kIsWeb) return;

    try {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message.toString(),
        fatal: isFatal,
      );
    } catch (e) {
      _logger.e('Failed to report to Crashlytics: $e');
    }
  }

  /// Set custom keys for Crashlytics context
  void setCustomKey(String key, dynamic value) {
    if (kDebugMode || kIsWeb) return;

    try {
      if (value is int) {
        FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is String) {
        FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is bool) {
        FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is double) {
        FirebaseCrashlytics.instance.setCustomKey(key, value);
      }
    } catch (e) {
      _logger.e('Failed to set Crashlytics key: $e');
    }
  }

  /// Set user ID for Crashlytics context
  void setUserId(String userId) {
    if (kDebugMode || kIsWeb) return;

    try {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      _logger.e('Failed to set Crashlytics userId: $e');
    }
  }

  /// Set household ID for tracking context
  void setHouseholdId(String householdId) {
    setCustomKey('household_id', householdId);
  }

  /// Set current screen context
  void setScreen(String screenName) {
    setCustomKey('current_screen', screenName);
  }
}

/// Global convenience getter
final log = LoggerService.instance;
