// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityClient)
final connectivityClientProvider = ConnectivityClientProvider._();

final class ConnectivityClientProvider extends $FunctionalProvider<
    ConnectivityClient,
    ConnectivityClient,
    ConnectivityClient> with $Provider<ConnectivityClient> {
  ConnectivityClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityClientProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityClientHash();

  @$internal
  @override
  $ProviderElement<ConnectivityClient> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectivityClient create(Ref ref) {
    return connectivityClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityClient>(value),
    );
  }
}

String _$connectivityClientHash() =>
    r'd7693cc3801a05a007ebd9d42abfdf5bcabacdda';

@ProviderFor(ConnectivityNotifier)
final connectivityProvider = ConnectivityNotifierProvider._();

final class ConnectivityNotifierProvider
    extends $NotifierProvider<ConnectivityNotifier, ConnectivityState> {
  ConnectivityNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityNotifierHash();

  @$internal
  @override
  ConnectivityNotifier create() => ConnectivityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityState>(value),
    );
  }
}

String _$connectivityNotifierHash() =>
    r'a8545c3466f6c696bd2ccdf9ec9d77f277b8af76';

abstract class _$ConnectivityNotifier extends $Notifier<ConnectivityState> {
  ConnectivityState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConnectivityState, ConnectivityState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ConnectivityState, ConnectivityState>,
        ConnectivityState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

final class IsOnlineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsOnlineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isOnlineProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOnlineHash() => r'3d2ac554928b736fbda0d82997a79f9c93f05be9';

@ProviderFor(connectivityStatus)
final connectivityStatusProvider = ConnectivityStatusProvider._();

final class ConnectivityStatusProvider extends $FunctionalProvider<
    ConnectivityStatus,
    ConnectivityStatus,
    ConnectivityStatus> with $Provider<ConnectivityStatus> {
  ConnectivityStatusProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'connectivityStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$connectivityStatusHash();

  @$internal
  @override
  $ProviderElement<ConnectivityStatus> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConnectivityStatus create(Ref ref) {
    return connectivityStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityStatus>(value),
    );
  }
}

String _$connectivityStatusHash() =>
    r'174e70db1b8b627546c9d2a75cb6485dfcd35731';
