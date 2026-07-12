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

String _$rewardsHash() => r'91131f423e519b230fa48960e05278558f9a41d7';

abstract class _$Rewards extends $AsyncNotifier<List<RewardModel>> {
  FutureOr<List<RewardModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<RewardModel>>, List<RewardModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<RewardModel>>, List<RewardModel>>,
        AsyncValue<List<RewardModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Canjes pendientes de entrega del hogar (bandeja "por entregar").
///
/// Vive aparte de [Rewards] porque cambia con otra cadencia (cada canje /
/// cumplimiento) y así marcar un canje no recarga toda la boutique.

@ProviderFor(PendingRedemptions)
final pendingRedemptionsProvider = PendingRedemptionsProvider._();

/// Canjes pendientes de entrega del hogar (bandeja "por entregar").
///
/// Vive aparte de [Rewards] porque cambia con otra cadencia (cada canje /
/// cumplimiento) y así marcar un canje no recarga toda la boutique.
final class PendingRedemptionsProvider
    extends $AsyncNotifierProvider<PendingRedemptions, List<RedemptionModel>> {
  /// Canjes pendientes de entrega del hogar (bandeja "por entregar").
  ///
  /// Vive aparte de [Rewards] porque cambia con otra cadencia (cada canje /
  /// cumplimiento) y así marcar un canje no recarga toda la boutique.
  PendingRedemptionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingRedemptionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingRedemptionsHash();

  @$internal
  @override
  PendingRedemptions create() => PendingRedemptions();
}

String _$pendingRedemptionsHash() =>
    r'0c7bdd7c187af72faa0b2ac73b5068021729bd93';

/// Canjes pendientes de entrega del hogar (bandeja "por entregar").
///
/// Vive aparte de [Rewards] porque cambia con otra cadencia (cada canje /
/// cumplimiento) y así marcar un canje no recarga toda la boutique.

abstract class _$PendingRedemptions
    extends $AsyncNotifier<List<RedemptionModel>> {
  FutureOr<List<RedemptionModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<RedemptionModel>>, List<RedemptionModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<RedemptionModel>>, List<RedemptionModel>>,
        AsyncValue<List<RedemptionModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
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
