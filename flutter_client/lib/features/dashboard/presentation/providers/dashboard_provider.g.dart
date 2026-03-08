// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'cb23c0b2d0630a1b073c1cb3d8654e1908b56287';

/// See also [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<DashboardRepository>.internal(
  dashboardRepository,
  name: r'dashboardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRepositoryRef = AutoDisposeProviderRef<DashboardRepository>;
String _$getRecentActivityUseCaseHash() =>
    r'ef09facd05b3e67ceb73f30f30df053b5d5cde89';

/// See also [getRecentActivityUseCase].
@ProviderFor(getRecentActivityUseCase)
final getRecentActivityUseCaseProvider =
    AutoDisposeProvider<GetRecentActivityUseCase>.internal(
  getRecentActivityUseCase,
  name: r'getRecentActivityUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getRecentActivityUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetRecentActivityUseCaseRef
    = AutoDisposeProviderRef<GetRecentActivityUseCase>;
String _$recentActivityHash() => r'9834acfe6884cc153289fba47c377946e46ae8d5';

/// See also [recentActivity].
@ProviderFor(recentActivity)
final recentActivityProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
  recentActivity,
  name: r'recentActivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentActivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentActivityRef
    = AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
