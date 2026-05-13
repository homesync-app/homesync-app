import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

enum ConnectivityStatus { online, offline, checking }

abstract class ConnectivityClient {
  Future<List<ConnectivityResult>> checkConnectivity();
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class ConnectivityPlusClient implements ConnectivityClient {
  final Connectivity _connectivity;

  ConnectivityPlusClient([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() {
    return _connectivity.checkConnectivity();
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}

class ConnectivityState {
  final ConnectivityStatus status;
  final bool isOnline;
  final DateTime? lastChecked;

  const ConnectivityState({
    this.status = ConnectivityStatus.checking,
    this.isOnline = false,
    this.lastChecked,
  });

  ConnectivityState copyWith({
    ConnectivityStatus? status,
    bool? isOnline,
    DateTime? lastChecked,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

@Riverpod(keepAlive: true)
ConnectivityClient connectivityClient(Ref ref) {
  return ConnectivityPlusClient();
}

@Riverpod(keepAlive: true)
class ConnectivityNotifier extends _$ConnectivityNotifier {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  ConnectivityState build() {
    // Setup listener after build completes
    Future.microtask(() => _init());

    ref.onDispose(() {
      _subscription?.cancel();
    });

    // Assume online by default to avoid blocking startup
    return ConnectivityState(
      status: ConnectivityStatus.online,
      isOnline: true,
      lastChecked: DateTime.now(),
    );
  }

  Future<void> _init() async {
    try {
      _subscription =
          ref.read(connectivityClientProvider).onConnectivityChanged.listen(
                _updateConnectionStatus,
              );
      await _checkConnection();
    } catch (e, stack) {
      log.w(
        'Failed to subscribe to connectivity changes: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _checkConnection() async {
    try {
      final results =
          await ref.read(connectivityClientProvider).checkConnectivity();
      _applyConnectivityResult(results);
    } catch (e, stack) {
      log.w('Connectivity check failed: $e', error: e, stackTrace: stack);
      state = state.copyWith(
        status: ConnectivityStatus.online,
        isOnline: true,
        lastChecked: DateTime.now(),
      );
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _applyConnectivityResult(results);
  }

  void _applyConnectivityResult(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    state = state.copyWith(
      status: hasConnection
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline,
      isOnline: hasConnection,
      lastChecked: DateTime.now(),
    );
  }

  Future<void> refresh() async {
    await _checkConnection();
  }
}

@riverpod
bool isOnline(Ref ref) {
  return ref.watch(connectivityProvider).isOnline;
}

@riverpod
ConnectivityStatus connectivityStatus(Ref ref) {
  return ref.watch(connectivityProvider).status;
}
