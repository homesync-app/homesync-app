// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HouseholdMembersNotifier)
final householdMembersProvider = HouseholdMembersNotifierProvider._();

final class HouseholdMembersNotifierProvider extends $AsyncNotifierProvider<
    HouseholdMembersNotifier, List<MemberModel>> {
  HouseholdMembersNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'householdMembersProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$householdMembersNotifierHash();

  @$internal
  @override
  HouseholdMembersNotifier create() => HouseholdMembersNotifier();
}

String _$householdMembersNotifierHash() =>
    r'abc11bb2edf9a7bf61ed9b44c3e3f7d1bc9edce4';

abstract class _$HouseholdMembersNotifier
    extends $AsyncNotifier<List<MemberModel>> {
  FutureOr<List<MemberModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<MemberModel>>, List<MemberModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<MemberModel>>, List<MemberModel>>,
        AsyncValue<List<MemberModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(household)
final householdProvider = HouseholdProvider._();

final class HouseholdProvider extends $FunctionalProvider<
        AsyncValue<HouseholdModel?>, HouseholdModel?, FutureOr<HouseholdModel?>>
    with $FutureModifier<HouseholdModel?>, $FutureProvider<HouseholdModel?> {
  HouseholdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'householdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$householdHash();

  @$internal
  @override
  $FutureProviderElement<HouseholdModel?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HouseholdModel?> create(Ref ref) {
    return household(ref);
  }
}

String _$householdHash() => r'f4735ad5bd56442dd9dab96f15709fca8ed09c9f';
