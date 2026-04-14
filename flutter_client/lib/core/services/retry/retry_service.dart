import 'dart:math';

import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/services/logger_service.dart';

class RetryPolicy {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final bool exponentialBackoff;
  final double jitterRatio;

  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.exponentialBackoff = true,
    this.jitterRatio = 0.3,
  });
}

class RetryService {
  static final RetryService _instance = RetryService._internal();
  factory RetryService() => _instance;
  RetryService._internal();

  Future<T> executeWithRetry<T>({
    required Future<T> Function() request,
    RetryPolicy policy = const RetryPolicy(),
    bool Function(Exception)? shouldRetry,
  }) async {
    int retryCount = 0;
    Duration delay = policy.initialDelay;

    while (retryCount < policy.maxRetries) {
      try {
        return await request();
      } on RateLimitException catch (e) {
        retryCount++;
        if (retryCount >= policy.maxRetries) rethrow;

        Duration waitTime = e.timeUntilReset ?? delay;
        delay = _nextDelay(
          waitTime,
          retryCount: retryCount,
          policy: policy,
        );

        await Future.delayed(delay);
      } on NetworkException {
        retryCount++;
        if (retryCount >= policy.maxRetries) rethrow;

        delay = _nextDelay(
          delay,
          retryCount: retryCount,
          policy: policy,
        );
        await Future.delayed(delay);
      } catch (e, stack) {
        if (shouldRetry != null && shouldRetry(e as Exception)) {
          retryCount++;
          if (retryCount >= policy.maxRetries) rethrow;
          log.w(
            'RetryService retrying request after unexpected exception',
            error: e,
            stackTrace: stack,
          );
          delay = _nextDelay(
            delay,
            retryCount: retryCount,
            policy: policy,
          );
          await Future.delayed(delay);
        } else {
          log.e(
            'RetryService aborting request after unexpected exception',
            error: e,
            stackTrace: stack,
          );
          rethrow;
        }
      }
    }

    throw const NetworkException('Max retries exceeded');
  }

  bool isRetryable(Exception e) {
    return e is RateLimitException ||
        e is NetworkException ||
        e is OfflineException;
  }

  Duration _nextDelay(
    Duration baseDelay, {
    required int retryCount,
    required RetryPolicy policy,
  }) {
    final multiplier =
        policy.exponentialBackoff ? pow(2, retryCount - 1).toInt() : retryCount;
    final rawDelay = Duration(
      milliseconds: (baseDelay.inMilliseconds * multiplier).clamp(
        0,
        policy.maxDelay.inMilliseconds,
      ),
    );
    return _applyJitter(rawDelay, policy.jitterRatio);
  }

  Duration _applyJitter(Duration delay, double jitterRatio) {
    if (jitterRatio <= 0) return delay;
    final jitter = (Random().nextDouble() * 2 - 1) * jitterRatio;
    final adjusted =
        (delay.inMilliseconds * (1 + jitter)).clamp(0, delay.inMilliseconds * 2);
    return Duration(milliseconds: adjusted.toInt());
  }
}

class OfflineRetryService {
  final RetryService _retryService = RetryService();

  Future<T> executeOnline<T>({
    required Future<T> Function() request,
    required bool isOnline,
    int maxRetries = 3,
  }) async {
    if (!isOnline) {
      throw const OfflineException('No internet connection');
    }

    return _retryService.executeWithRetry(
      request: request,
      policy: RetryPolicy(maxRetries: maxRetries),
      shouldRetry: (e) => _retryService.isRetryable(e),
    );
  }
}
