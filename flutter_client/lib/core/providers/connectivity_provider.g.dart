// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityClientHash() =>
    r'bed594ed64879e16572909372e8ff7e82e5b1448';

/// See also [connectivityClient].
@ProviderFor(connectivityClient)
final connectivityClientProvider = Provider<ConnectivityClient>.internal(
  connectivityClient,
  name: r'connectivityClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityClientRef = ProviderRef<ConnectivityClient>;
String _$isOnlineHash() => r'3d820b85138d26a6af8be902c7c7a39ff58aa744';

/// See also [isOnline].
@ProviderFor(isOnline)
final isOnlineProvider = AutoDisposeProvider<bool>.internal(
  isOnline,
  name: r'isOnlineProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isOnlineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOnlineRef = AutoDisposeProviderRef<bool>;
String _$connectivityStatusHash() =>
    r'6824b3ceb8e44f09505b13f53ad9f32fa6ac02e3';

/// See also [connectivityStatus].
@ProviderFor(connectivityStatus)
final connectivityStatusProvider =
    AutoDisposeProvider<ConnectivityStatus>.internal(
  connectivityStatus,
  name: r'connectivityStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityStatusRef = AutoDisposeProviderRef<ConnectivityStatus>;
String _$connectivityNotifierHash() =>
    r'a8545c3466f6c696bd2ccdf9ec9d77f277b8af76';

/// See also [ConnectivityNotifier].
@ProviderFor(ConnectivityNotifier)
final connectivityNotifierProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityState>.internal(
  ConnectivityNotifier.new,
  name: r'connectivityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectivityNotifier = Notifier<ConnectivityState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
