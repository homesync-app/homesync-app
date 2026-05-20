// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'f6248dcdae244fcabf566addf9e58d76e3338db0';

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
String _$recentActivityRemoteHash() =>
    r'd800edd89e43e7808020eff674e48ebed094dbc1';

/// See also [recentActivityRemote].
@ProviderFor(recentActivityRemote)
final recentActivityRemoteProvider =
    AutoDisposeStreamProvider<List<Map<String, dynamic>>>.internal(
  recentActivityRemote,
  name: r'recentActivityRemoteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentActivityRemoteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentActivityRemoteRef
    = AutoDisposeStreamProviderRef<List<Map<String, dynamic>>>;
String _$recentActivityHash() => r'6505c13ec68684340a769df8813d27ed243bc5da';

/// See also [recentActivity].
@ProviderFor(recentActivity)
final recentActivityProvider =
    AutoDisposeProvider<AsyncValue<List<Map<String, dynamic>>>>.internal(
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
    = AutoDisposeProviderRef<AsyncValue<List<Map<String, dynamic>>>>;
String _$hiddenRecentExpenseIdsHash() =>
    r'd65a823985b412bd466ef9be753589feb55dbfb5';

/// See also [HiddenRecentExpenseIds].
@ProviderFor(HiddenRecentExpenseIds)
final hiddenRecentExpenseIdsProvider =
    AutoDisposeNotifierProvider<HiddenRecentExpenseIds, Set<String>>.internal(
  HiddenRecentExpenseIds.new,
  name: r'hiddenRecentExpenseIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hiddenRecentExpenseIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HiddenRecentExpenseIds = AutoDisposeNotifier<Set<String>>;
String _$optimisticRecentActivityHash() =>
    r'45e9a502173014ddc4b82d06ff480dc06ecbcf62';

/// See also [OptimisticRecentActivity].
@ProviderFor(OptimisticRecentActivity)
final optimisticRecentActivityProvider = AutoDisposeNotifierProvider<
    OptimisticRecentActivity, List<Map<String, dynamic>>>.internal(
  OptimisticRecentActivity.new,
  name: r'optimisticRecentActivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$optimisticRecentActivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OptimisticRecentActivity
    = AutoDisposeNotifier<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
