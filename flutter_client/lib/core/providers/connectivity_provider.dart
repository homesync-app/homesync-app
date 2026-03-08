import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

enum ConnectivityStatus { online, offline, checking }

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
class ConnectivityNotifier extends _$ConnectivityNotifier {
  final Connectivity _connectivity = Connectivity();
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
    // Start listening for changes but don't block on them
    try {
      _subscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e) {
      log.w('Failed to subscribe to connectivity changes: $e');
    }
  }

  Future<void> _checkConnection() async {
    // Always assume online - let Supabase handle actual connection errors
    state = state.copyWith(
      status: ConnectivityStatus.online,
      isOnline: true,
      lastChecked: DateTime.now(),
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Ignore connectivity_plus results - they are unreliable
    // Always stay online and let Supabase handle actual errors
    state = state.copyWith(
      status: ConnectivityStatus.online,
      isOnline: true,
      lastChecked: DateTime.now(),
    );
  }

  Future<void> refresh() async {
    await _checkConnection();
  }
}

@riverpod
bool isOnline(IsOnlineRef ref) {
  return ref.watch(connectivityNotifierProvider).isOnline;
}

@riverpod
ConnectivityStatus connectivityStatus(ConnectivityStatusRef ref) {
  return ref.watch(connectivityNotifierProvider).status;
}
