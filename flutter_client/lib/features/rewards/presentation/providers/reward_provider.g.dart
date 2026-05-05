// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredRewardsHash() => r'94ca8435b3d86205a52981efc3b6a02023d72666';

/// See also [filteredRewards].
@ProviderFor(filteredRewards)
final filteredRewardsProvider =
    AutoDisposeFutureProvider<List<RewardModel>>.internal(
  filteredRewards,
  name: r'filteredRewardsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredRewardsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredRewardsRef = AutoDisposeFutureProviderRef<List<RewardModel>>;
String _$rewardsHash() => r'9c3d6f7edb4b745ba2047019c40533e2c6e2b3b8';

/// See also [Rewards].
@ProviderFor(Rewards)
final rewardsProvider =
    AutoDisposeAsyncNotifierProvider<Rewards, List<RewardModel>>.internal(
  Rewards.new,
  name: r'rewardsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$rewardsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Rewards = AutoDisposeAsyncNotifier<List<RewardModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
