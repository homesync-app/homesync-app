import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/offline/offline_queue_service.dart';
import 'package:homesync_client/core/offline/offline_action_processor.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';

class SyncResult {
  final int processed;
  final int successful;
  final int failed;
  final List<String> errors;

  const SyncResult({
    this.processed = 0,
    this.successful = 0,
    this.failed = 0,
    this.errors = const [],
  });
}

class SyncService {
  final OfflineQueueService _queueService = OfflineQueueService();
  bool _isSyncing = false;
  static const int _maxRetries = 3;

  bool get isSyncing => _isSyncing;

  Future<SyncResult> sync({
    Future<dynamic> Function(QueuedRequest request)? processRequest,
  }) async {
    if (_isSyncing) {
      return const SyncResult();
    }

    _isSyncing = true;
    int processed = 0;
    int successful = 0;
    int failed = 0;
    final List<String> errors = [];

    try {
      final pendingRequests = await _queueService.getPending();

      for (final request in pendingRequests) {
        if (request.id == null) continue;

        await _queueService.markProcessing(request.id!);
        processed++;

        try {
          if (processRequest != null) {
            await processRequest(request);
          } else {
            await _defaultProcessRequest(request);
          }

          await _queueService.markCompleted(request.id!);
          successful++;
        } catch (e) {
          final retryCount =
              await _queueService.incrementRetryAndGet(request.id!);
          if (retryCount >= _maxRetries) {
            await _queueService.markFailed(
              request.id!,
              e.toString(),
              retryCount: retryCount,
            );
          }
          failed++;
          errors.add('Request ${request.id} failed: $e');
        }
      }
    } finally {
      _isSyncing = false;
    }

    return SyncResult(
      processed: processed,
      successful: successful,
      failed: failed,
      errors: errors,
    );
  }

  Future<void> _defaultProcessRequest(QueuedRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> cleanup() async {
    await _queueService.clearCompleted();
    await _queueService.requeueFailed();
  }

  Future<int> getPendingCount() async {
    return _queueService.getQueueLength();
  }
}

class SyncState {
  final bool isSyncing;
  final DateTime? lastSync;
  final String? lastError;
  final int pendingCount;

  const SyncState({
    this.isSyncing = false,
    this.lastSync,
    this.lastError,
    this.pendingCount = 0,
  });

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSync,
    String? lastError,
    int? pendingCount,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      lastError: lastError ?? this.lastError,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  final SyncService _syncService = SyncService();

  @override
  SyncState build() {
    ref.listen<bool>(
      isOnlineProvider,
      (previous, isOnline) {
        if (isOnline && !_syncService.isSyncing) {
          sync();
        }
      },
    );

    return const SyncState();
  }

  Future<void> sync({
    Future<dynamic> Function(QueuedRequest request)? processRequest,
  }) async {
    state = state.copyWith(isSyncing: true, lastError: null);

    try {
      final processor =
          processRequest ?? ref.read(offlineActionProcessorProvider);
      final result = await _syncService.sync(processRequest: processor);
      state = state.copyWith(
        isSyncing: false,
        lastSync: DateTime.now(),
        lastError: result.errors.isNotEmpty ? result.errors.first : null,
        pendingCount: await _syncService.getPendingCount(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: e.toString(),
      );
    }
  }

  Future<void> cleanup() async {
    await _syncService.cleanup();
    state = state.copyWith(pendingCount: await _syncService.getPendingCount());
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(() {
  return SyncNotifier();
});

final pendingRequestsCountProvider = Provider<int>((ref) {
  return ref.watch(syncProvider).pendingCount;
});
