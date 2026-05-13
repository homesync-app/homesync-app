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
    r'df65d92f4c8b34b8e30b2b299cddbff19b14b444';

abstract class _$HouseholdMembersNotifier
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

String _$householdHash() => r'aa777f3da76f5e435388ac2a449f4ceefe40e064';
