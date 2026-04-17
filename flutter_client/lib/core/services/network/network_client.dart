import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';
import 'package:homesync_client/core/services/retry/retry_service.dart';

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
    final retryService = RetryService();
    return retryService.executeWithRetry(
      request: request,
      policy: RetryPolicy(
        maxRetries: config.maxRetries,
        initialDelay: config.initialDelay,
        maxDelay: config.maxDelay,
        exponentialBackoff: config.exponentialBackoff,
        jitterRatio: 0.3,
      ),
      shouldRetry: (e) => e is RateLimitException || e is NetworkException,
    );
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
