import 'dart:math';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RetryConfig {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final bool exponentialBackoff;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.exponentialBackoff = true,
  });
}

class NetworkClient {
  final RetryConfig config;
  final Ref _ref;
  
  NetworkClient({
    this.config = const RetryConfig(),
    required Ref ref,
  }) : _ref = ref;

  bool get _isOnline => _ref.read(isOnlineProvider);

  Future<T> get<T>(
    Future<T> Function() request, {
    String? operationName,
  }) async {
    return _executeWithRetry(request, operationName: operationName ?? 'GET');
  }

  Future<T> post<T>(
    Future<T> Function() request, {
    String? operationName,
  }) async {
    return _executeWithRetry(request, operationName: operationName ?? 'POST');
  }

  Future<T> put<T>(
    Future<T> Function() request, {
    String? operationName,
  }) async {
    return _executeWithRetry(request, operationName: operationName ?? 'PUT');
  }

  Future<T> delete<T>(
    Future<T> Function() request, {
    String? operationName,
  }) async {
    return _executeWithRetry(request, operationName: operationName ?? 'DELETE');
  }

  Future<T> _executeWithRetry<T>(
    Future<T> Function() request, {
    required String operationName,
  }) async {
    if (!_isOnline) {
      throw const OfflineException('No internet connection');
    }

    int retryCount = 0;
    Duration delay = config.initialDelay;

    while (true) {
      try {
        return await request();
      } on RateLimitException catch (e) {
        retryCount++;
        if (retryCount >= config.maxRetries) rethrow;

        Duration waitTime = e.timeUntilReset ?? delay;
        if (config.exponentialBackoff) {
          int multiplier = pow(2, retryCount - 1).toInt();
          delay = Duration(
            milliseconds: (waitTime.inMilliseconds * multiplier).clamp(
              0,
              config.maxDelay.inMilliseconds,
            ),
          );
        }
        
        await Future.delayed(delay);
      } on NetworkException catch (e) {
        retryCount++;
        if (retryCount >= config.maxRetries) rethrow;

        if (config.exponentialBackoff) {
          delay = Duration(
            milliseconds: (delay.inMilliseconds * 2).clamp(
              0,
              config.maxDelay.inMilliseconds,
            ),
          );
        } else {
          delay = delay + config.initialDelay;
        }
        
        await Future.delayed(delay);
      } catch (e) {
        if (e is OfflineException) rethrow;
        
        retryCount++;
        if (retryCount >= config.maxRetries) {
          throw NetworkException('Operation failed after $retryCount attempts: $e');
        }

        if (config.exponentialBackoff) {
          delay = Duration(
            milliseconds: (delay.inMilliseconds * 2).clamp(
              0,
              config.maxDelay.inMilliseconds,
            ),
          );
        }
        
        await Future.delayed(delay);
      }
    }
  }
}

final networkClientProvider = Provider<NetworkClient>((ref) {
  return NetworkClient(ref: ref);
});

final networkClientWithRetryProvider = Provider<NetworkClient>((ref) {
  return NetworkClient(
    config: const RetryConfig(
      maxRetries: 3,
      initialDelay: Duration(seconds: 1),
      maxDelay: Duration(seconds: 30),
      exponentialBackoff: true,
    ),
    ref: ref,
  );
});

extension NetworkClientExtension on NetworkClient {
  Future<T> execute<T>(Future<T> Function() request) => post(request);
}
