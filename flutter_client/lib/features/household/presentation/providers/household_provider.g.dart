// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$householdHash() => r'aa777f3da76f5e435388ac2a449f4ceefe40e064';

/// See also [household].
@ProviderFor(household)
final householdProvider = FutureProvider<HouseholdModel?>.internal(
  household,
  name: r'householdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$householdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HouseholdRef = FutureProviderRef<HouseholdModel?>;
String _$householdMembersNotifierHash() =>
    r'df65d92f4c8b34b8e30b2b299cddbff19b14b444';

/// See also [HouseholdMembersNotifier].
@ProviderFor(HouseholdMembersNotifier)
final householdMembersNotifierProvider =
    AsyncNotifierProvider<HouseholdMembersNotifier, List<MemberModel>>.internal(
  HouseholdMembersNotifier.new,
  name: r'householdMembersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$householdMembersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HouseholdMembersNotifier = AsyncNotifier<List<MemberModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
