// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentHouseholdHash() => r'92fb2ceb95c460ab9203465552cdcf9484310940';

/// See also [currentHousehold].
@ProviderFor(currentHousehold)
final currentHouseholdProvider =
    AutoDisposeFutureProvider<HouseholdModel?>.internal(
  currentHousehold,
  name: r'currentHouseholdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentHouseholdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentHouseholdRef = AutoDisposeFutureProviderRef<HouseholdModel?>;
String _$householdCapabilitiesHash() =>
    r'd4442a6f791432a6b81009bd4ce6e6b373a9dab7';

/// See also [householdCapabilities].
@ProviderFor(householdCapabilities)
final householdCapabilitiesProvider =
    AutoDisposeProvider<HouseholdCapabilities>.internal(
  householdCapabilities,
  name: r'householdCapabilitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$householdCapabilitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HouseholdCapabilitiesRef
    = AutoDisposeProviderRef<HouseholdCapabilities>;
String _$householdMembersHash() => r'1bc686b6717732ca71993b074cf18da4eae5585d';

/// See also [HouseholdMembers].
@ProviderFor(HouseholdMembers)
final householdMembersProvider =
    AsyncNotifierProvider<HouseholdMembers, List<MemberModel>>.internal(
  HouseholdMembers.new,
  name: r'householdMembersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$householdMembersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HouseholdMembers = AsyncNotifier<List<MemberModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
