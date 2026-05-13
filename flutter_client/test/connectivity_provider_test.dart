import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';

class FakeConnectivityClient implements ConnectivityClient {
  FakeConnectivityClient(List<ConnectivityResult> initialResults)
      : _currentResults = initialResults;

  final _controller = StreamController<List<ConnectivityResult>>.broadcast();
  List<ConnectivityResult> _currentResults;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _currentResults;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void emit(List<ConnectivityResult> results) {
    _currentResults = results;
    _controller.add(results);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  group('connectivityProvider', () {
    test('transitions to offline after initial connectivity check returns none',
        () async {
      final fakeClient =
          FakeConnectivityClient(const [ConnectivityResult.none]);
      final container = ProviderContainer(
        overrides: [
          connectivityClientProvider.overrideWithValue(fakeClient),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await fakeClient.dispose();
      });

      container.read(connectivityProvider);
      expect(container.read(isOnlineProvider), isTrue);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(connectivityProvider);
      expect(state.isOnline, isFalse);
      expect(state.status, ConnectivityStatus.offline);
    });

    test('updates back to online when connectivity stream emits a valid result',
        () async {
      final fakeClient =
          FakeConnectivityClient(const [ConnectivityResult.none]);
      final container = ProviderContainer(
        overrides: [
          connectivityClientProvider.overrideWithValue(fakeClient),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await fakeClient.dispose();
      });

      container.read(connectivityProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(isOnlineProvider), isFalse);

      fakeClient.emit(const [ConnectivityResult.wifi]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(connectivityProvider);
      expect(state.isOnline, isTrue);
      expect(state.status, ConnectivityStatus.online);
    });
  });
}
