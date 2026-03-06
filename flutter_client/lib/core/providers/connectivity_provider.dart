import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:homesync_client/core/services/logger_service.dart';

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

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier() : super(const ConnectivityState()) {
    _init();
  }

  Future<void> _init() async {
    // Assume online by default - connectivity_plus has known issues
    // that cause false positives. Let Supabase handle actual connection errors.
    state = state.copyWith(
      status: ConnectivityStatus.online,
      isOnline: true,
      lastChecked: DateTime.now(),
    );
    
    // Start listening for changes but don't block on them
    try {
      _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isOnline;
});

final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityProvider).status;
});
