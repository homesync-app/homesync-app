// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_reward_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rewardRepository)
final rewardRepositoryProvider = RewardRepositoryProvider._();

final class RewardRepositoryProvider extends $FunctionalProvider<
    RewardRepository,
    RewardRepository,
    RewardRepository> with $Provider<RewardRepository> {
  RewardRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'rewardRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$rewardRepositoryHash();

  @$internal
  @override
  $ProviderElement<RewardRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RewardRepository create(Ref ref) {
    return rewardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RewardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RewardRepository>(value),
    );
  }
}

String _$rewardRepositoryHash() => r'04030f78a92a58f95fe8742fdafcae692c975a82';
