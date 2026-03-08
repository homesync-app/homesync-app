// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statsRepositoryHash() => r'3bee19c955ce7eaaa622acdd3502c5457b9f1ae1';

/// See also [statsRepository].
@ProviderFor(statsRepository)
final statsRepositoryProvider = Provider<StatsRepository>.internal(
  statsRepository,
  name: r'statsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatsRepositoryRef = ProviderRef<StatsRepository>;
String _$statsControllerHash() => r'87e271140a7e7e9cf75697b6ee8e7ab553e1e814';

/// See also [StatsController].
@ProviderFor(StatsController)
final statsControllerProvider =
    AsyncNotifierProvider<StatsController, StatsData>.internal(
  StatsController.new,
  name: r'statsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StatsController = AsyncNotifier<StatsData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
