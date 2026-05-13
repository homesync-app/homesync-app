// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Rewards)
final rewardsProvider = RewardsProvider._();

final class RewardsProvider
    extends $AsyncNotifierProvider<Rewards, List<RewardModel>> {
  RewardsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rewardsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rewardsHash();

  @$internal
  @override
  Rewards create() => Rewards();
}

String _$rewardsHash() => r'e3f615c89e51bc7b2ae003efffcaa88d7b7c7e3e';

abstract class _$Rewards extends $AsyncNotifier<List<RewardModel>> {
  FutureOr<List<RewardModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<RewardModel>>, List<RewardModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<RewardModel>>, List<RewardModel>>,
        AsyncValue<List<RewardModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredRewards)
final filteredRewardsProvider = FilteredRewardsProvider._();

final class FilteredRewardsProvider extends $FunctionalProvider<
        AsyncValue<List<RewardModel>>,
        List<RewardModel>,
        FutureOr<List<RewardModel>>>
    with
        $FutureModifier<List<RewardModel>>,
        $FutureProvider<List<RewardModel>> {
  FilteredRewardsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredRewardsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredRewardsHash();

  @$internal
  @override
  $FutureProviderElement<List<RewardModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<RewardModel>> create(Ref ref) {
    return filteredRewards(ref);
  }
}

String _$filteredRewardsHash() => r'6ef50a30c559fba4b49b08d771ae446828820f7d';
