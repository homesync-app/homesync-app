// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HouseholdMembersSnapshot)
final householdMembersSnapshotProvider = HouseholdMembersSnapshotProvider._();

final class HouseholdMembersSnapshotProvider extends $AsyncNotifierProvider<
    HouseholdMembersSnapshot, List<MemberModel>> {
  HouseholdMembersSnapshotProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'householdMembersSnapshotProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$householdMembersSnapshotHash();

  @$internal
  @override
  HouseholdMembersSnapshot create() => HouseholdMembersSnapshot();
}

String _$householdMembersSnapshotHash() =>
    r'4fa4e51b5e5417dea935fce44ff02494baaf2908';

abstract class _$HouseholdMembersSnapshot
    extends $AsyncNotifier<List<MemberModel>> {
  FutureOr<List<MemberModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<MemberModel>>, List<MemberModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MemberModel>>, List<MemberModel>>,
        AsyncValue<List<MemberModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(currentHousehold)
final currentHouseholdProvider = CurrentHouseholdProvider._();

final class CurrentHouseholdProvider extends $FunctionalProvider<
        AsyncValue<HouseholdModel?>, HouseholdModel?, FutureOr<HouseholdModel?>>
    with $FutureModifier<HouseholdModel?>, $FutureProvider<HouseholdModel?> {
  CurrentHouseholdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentHouseholdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentHouseholdHash();

  @$internal
  @override
  $FutureProviderElement<HouseholdModel?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HouseholdModel?> create(Ref ref) {
    return currentHousehold(ref);
  }
}

String _$currentHouseholdHash() => r'92fb2ceb95c460ab9203465552cdcf9484310940';

@ProviderFor(householdCapabilities)
final householdCapabilitiesProvider = HouseholdCapabilitiesProvider._();

final class HouseholdCapabilitiesProvider extends $FunctionalProvider<
    HouseholdCapabilities,
    HouseholdCapabilities,
    HouseholdCapabilities> with $Provider<HouseholdCapabilities> {
  HouseholdCapabilitiesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'householdCapabilitiesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$householdCapabilitiesHash();

  @$internal
  @override
  $ProviderElement<HouseholdCapabilities> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HouseholdCapabilities create(Ref ref) {
    return householdCapabilities(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HouseholdCapabilities value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HouseholdCapabilities>(value),
    );
  }
}

String _$householdCapabilitiesHash() =>
    r'b0da343dc313fb7d4808d4fdfcf72fe0cea5062f';
