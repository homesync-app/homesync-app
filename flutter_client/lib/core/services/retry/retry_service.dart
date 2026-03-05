import 'dart:math';
import 'package:homesync_client/core/errors/failures.dart';

class RetryService {
  static final RetryService _instance = RetryService._internal();
  factory RetryService() => _instance;
  RetryService._internal();

  Future<T> executeWithRetry<T>({
    required Future<T> Function() request,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool Function(Exception)? shouldRetry,
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;

    while (retryCount < maxRetries) {
      try {
        return await request();
      } on RateLimitException catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) rethrow;

        Duration waitTime = e.timeUntilReset ?? delay;
        int multiplier = pow(2, retryCount - 1).toInt();
        delay = Duration(milliseconds: waitTime.inMilliseconds * multiplier);

        await Future.delayed(delay);
      } on NetworkException {
        retryCount++;
        if (retryCount >= maxRetries) rethrow;

        await Future.delayed(delay * retryCount);
      } catch (e) {
        if (shouldRetry != null && shouldRetry(e as Exception)) {
          retryCount++;
          if (retryCount >= maxRetries) rethrow;
          await Future.delayed(delay * retryCount);
        } else {
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
      maxRetries: maxRetries,
      shouldRetry: (e) => _retryService.isRetryable(e),
    );
  }
}
