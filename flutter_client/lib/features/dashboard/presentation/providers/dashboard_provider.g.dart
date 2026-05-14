// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider = DashboardRepositoryProvider._();

final class DashboardRepositoryProvider extends $FunctionalProvider<
    DashboardRepository,
    DashboardRepository,
    DashboardRepository> with $Provider<DashboardRepository> {
  DashboardRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<DashboardRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DashboardRepository create(Ref ref) {
    return dashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardRepository>(value),
    );
  }
}

String _$dashboardRepositoryHash() =>
    r'66954bc9f173839741c4d056059dd1d720911921';

@ProviderFor(getRecentActivityUseCase)
final getRecentActivityUseCaseProvider = GetRecentActivityUseCaseProvider._();

final class GetRecentActivityUseCaseProvider extends $FunctionalProvider<
    GetRecentActivityUseCase,
    GetRecentActivityUseCase,
    GetRecentActivityUseCase> with $Provider<GetRecentActivityUseCase> {
  GetRecentActivityUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getRecentActivityUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getRecentActivityUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRecentActivityUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetRecentActivityUseCase create(Ref ref) {
    return getRecentActivityUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRecentActivityUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRecentActivityUseCase>(value),
    );
  }
}

String _$getRecentActivityUseCaseHash() =>
    r'2bc9d83d36eb5d15caff6b692f09620b7f3f0687';

@ProviderFor(recentActivityRemote)
final recentActivityRemoteProvider = RecentActivityRemoteProvider._();

final class RecentActivityRemoteProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        Stream<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  RecentActivityRemoteProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentActivityRemoteProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentActivityRemoteHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return recentActivityRemote(ref);
  }
}

String _$recentActivityRemoteHash() =>
    r'd800edd89e43e7808020eff674e48ebed094dbc1';

@ProviderFor(recentActivity)
final recentActivityProvider = RecentActivityProvider._();

final class RecentActivityProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        AsyncValue<List<Map<String, dynamic>>>,
        AsyncValue<List<Map<String, dynamic>>>>
    with $Provider<AsyncValue<List<Map<String, dynamic>>>> {
  RecentActivityProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentActivityProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentActivityHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Map<String, dynamic>>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<List<Map<String, dynamic>>> create(Ref ref) {
    return recentActivity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Map<String, dynamic>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<Map<String, dynamic>>>>(value),
    );
  }
}

String _$recentActivityHash() => r'6505c13ec68684340a769df8813d27ed243bc5da';

@ProviderFor(HiddenRecentExpenseIds)
final hiddenRecentExpenseIdsProvider = HiddenRecentExpenseIdsProvider._();

final class HiddenRecentExpenseIdsProvider
    extends $NotifierProvider<HiddenRecentExpenseIds, Set<String>> {
  HiddenRecentExpenseIdsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hiddenRecentExpenseIdsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hiddenRecentExpenseIdsHash();

  @$internal
  @override
  HiddenRecentExpenseIds create() => HiddenRecentExpenseIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$hiddenRecentExpenseIdsHash() =>
    r'd65a823985b412bd466ef9be753589feb55dbfb5';

abstract class _$HiddenRecentExpenseIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(OptimisticRecentActivity)
final optimisticRecentActivityProvider = OptimisticRecentActivityProvider._();

final class OptimisticRecentActivityProvider extends $NotifierProvider<
    OptimisticRecentActivity, List<Map<String, dynamic>>> {
  OptimisticRecentActivityProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'optimisticRecentActivityProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$optimisticRecentActivityHash();

  @$internal
  @override
  OptimisticRecentActivity create() => OptimisticRecentActivity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Map<String, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Map<String, dynamic>>>(value),
    );
  }
}

String _$optimisticRecentActivityHash() =>
    r'45e9a502173014ddc4b82d06ff480dc06ecbcf62';

abstract class _$OptimisticRecentActivity
    extends $Notifier<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<List<Map<String, dynamic>>, List<Map<String, dynamic>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Map<String, dynamic>>, List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
