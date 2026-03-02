import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
    await _checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnection() async {
    state = state.copyWith(status: ConnectivityStatus.checking);
    
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      state = state.copyWith(
        status: ConnectivityStatus.offline,
        isOnline: false,
        lastChecked: DateTime.now(),
      );
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isOnline = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);
    
    state = state.copyWith(
      status: isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline,
      isOnline: isOnline,
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

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isOnline;
});

final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityProvider).status;
});
