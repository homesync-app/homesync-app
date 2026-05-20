import 'package:flutter/foundation.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/services/logger_service.dart';

class PerformanceMonitor {
  PerformanceMonitor._();

  static final Stopwatch _appStopwatch = Stopwatch()..start();

  static bool get enabled =>
      AppEnvironment.enablePerformanceLogs || kDebugMode || kProfileMode;

  static Future<T> measureFuture<T>(
    String name,
    Future<T> Function() action, {
    Map<String, Object?> context = const {},
    int warnAfterMs = 800,
  }) async {
    if (!enabled) return action();

    final stopwatch = Stopwatch()..start();
    try {
      final result = await action();
      _log(name, stopwatch.elapsedMilliseconds, context, warnAfterMs);
      return result;
    } catch (error, stackTrace) {
      _log(
        name,
        stopwatch.elapsedMilliseconds,
        {...context, 'failed': true},
        warnAfterMs,
      );
      log.w(
        '[Perf] $name failed after ${stopwatch.elapsedMilliseconds}ms',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static T measureSync<T>(
    String name,
    T Function() action, {
    Map<String, Object?> context = const {},
    int warnAfterMs = 16,
  }) {
    if (!enabled) return action();

    final stopwatch = Stopwatch()..start();
    try {
      final result = action();
      _log(name, stopwatch.elapsedMilliseconds, context, warnAfterMs);
      return result;
    } catch (error, stackTrace) {
      _log(
        name,
        stopwatch.elapsedMilliseconds,
        {...context, 'failed': true},
        warnAfterMs,
      );
      log.w(
        '[Perf] $name failed after ${stopwatch.elapsedMilliseconds}ms',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static void mark(
    String name, {
    Map<String, Object?> context = const {},
  }) {
    if (!enabled) return;
    if (name == 'app.main.start') {
      _appStopwatch
        ..reset()
        ..start();
    }
    final suffix = _formatContext({
      'appElapsedMs': _appStopwatch.elapsedMilliseconds,
      ...context,
    });
    _emit('[Perf] $name$suffix');
  }

  static void _log(
    String name,
    int elapsedMs,
    Map<String, Object?> context,
    int warnAfterMs,
  ) {
    final suffix = _formatContext(context);
    final message = '[Perf] $name ${elapsedMs}ms$suffix';
    _emit(message);
    if (elapsedMs >= warnAfterMs) {
      log.w(message);
    } else {
      log.i(message);
    }
  }

  static void _emit(String message) {
    debugPrint(message);
  }

  static String _formatContext(Map<String, Object?> context) {
    if (context.isEmpty) return '';
    final details = context.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join(' ');
    if (details.isEmpty) return '';
    return ' ($details)';
  }
}
