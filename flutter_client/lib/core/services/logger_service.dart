import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging service for the application.
/// Replaces print() and debugPrint() with structured logging.
/// Integrated with Firebase Crashlytics for production error reporting.
/// Sink remoto para errores (ej. Supabase `application_logs`). Se cablea desde
/// `main()` una vez que existe el RPC service, así los errores ATRAPADOS
/// (try/catch + `log.e`) llegan al mismo pipeline que los no atrapados. Sin
/// esto, un catch con snackbar era invisible en el backend.
typedef RemoteErrorSink = void Function(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  bool fatal,
});

class LoggerService {
  LoggerService._privateConstructor();
  static final LoggerService _instance = LoggerService._privateConstructor();
  static LoggerService get instance => _instance;

  /// Cableado desde `main()`. Fire-and-forget; nunca debe romper el logging.
  static RemoteErrorSink? remoteErrorSink;

  /// Evita recursión si el sink (o algo aguas abajo) vuelve a llamar a log.e.
  static bool _inSink = false;

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

  /// Log a warning message (something unexpected happened but not fatal).
  ///
  /// Does not report to Crashlytics. Warnings are recoverable or expected
  /// unhappy states: offline, missing IAP IDs, transient channel closes, or
  /// empty-state fallbacks. Treating them as crashes inflates noise and hides
  /// real failures.
  ///
  /// Use `log.e` for non-fatal bugs, and `log.f` only for fatal failures.
  void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message (something failed but the app keeps running).
  /// Reported to Crashlytics as NON-fatal. Only `log.f(...)` marks fatal.
  ///
  /// Errores de pura conectividad (sin red, DNS caído, timeout) se degradan
  /// a warning local: no son bugs de la app y eran el issue #2 de Crashlytics
  /// por volumen (SocketException en cada RPC con el teléfono offline),
  /// enterrando los errores reales.
  void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (_isConnectivityNoise(error) || _isConnectivityNoise(message)) {
      _logger.w(message, error: error, stackTrace: stackTrace);
      return;
    }
    _logger.e(message, error: error, stackTrace: stackTrace);
    _reportToCrashlytics(message, error, stackTrace, isFatal: false);
    _forwardToRemote(message, error, stackTrace, fatal: false);
  }

  /// Detecta fallos de red esperables por string (sin importar dart:io, que
  /// rompería web). Mantener patrones inequívocos: un error que solo "menciona"
  /// la red en otro contexto no debería matchear estos textos.
  static bool _isConnectivityNoise(Object? value) {
    if (value == null) return false;
    final s = value.toString();
    return s.contains('SocketException') ||
        s.contains('Failed host lookup') ||
        s.contains('Connection refused') ||
        s.contains('Connection reset by peer') ||
        s.contains('Connection closed before full header was received') ||
        s.contains('Network is unreachable') ||
        s.contains('Software caused connection abort') ||
        s.contains('HandshakeException');
  }

  /// Log a fatal error (the app is about to crash and we know it).
  /// Use only when the flow cannot continue.
  void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    _reportToCrashlytics(message, error, stackTrace, isFatal: true);
    _forwardToRemote(message, error, stackTrace, fatal: true);
  }

  /// Reenvía errores al sink remoto (Supabase admin logs) si está cableado.
  /// Fire-and-forget y con guard de reentrancia: un fallo del sink jamás debe
  /// tumbar el logging ni provocar recursión.
  void _forwardToRemote(
    dynamic message,
    Object? error,
    StackTrace? stackTrace, {
    required bool fatal,
  }) {
    final sink = remoteErrorSink;
    if (sink == null || _inSink) return;
    _inSink = true;
    try {
      sink(
        message.toString(),
        error: error,
        stackTrace: stackTrace,
        fatal: fatal,
      );
    } catch (_) {
      // Nunca propagar un fallo del sink al call site del log.
    } finally {
      _inSink = false;
    }
  }

  /// Reports errors to Crashlytics in production (mobile only).
  void _reportToCrashlytics(
    dynamic message,
    Object? error,
    StackTrace? stackTrace, {
    required bool isFatal,
  }) {
    if (kDebugMode || kIsWeb) return;

    try {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message.toString(),
        fatal: isFatal,
      );
    } catch (e, stack) {
      _logger.e(
        'Failed to report to Crashlytics: $e',
        error: e,
        stackTrace: stack,
      );
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
    } catch (e, stack) {
      _logger.e(
        'Failed to set Crashlytics key: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Set user ID for Crashlytics context
  void setUserId(String userId) {
    if (kDebugMode || kIsWeb) return;

    try {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e, stack) {
      _logger.e(
        'Failed to set Crashlytics userId: $e',
        error: e,
        stackTrace: stack,
      );
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
