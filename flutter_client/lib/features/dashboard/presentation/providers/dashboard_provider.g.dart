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

@ProviderFor(recentActivity)
final recentActivityProvider = RecentActivityProvider._();

final class RecentActivityProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        Stream<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
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
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return recentActivity(ref);
  }
}

String _$recentActivityHash() => r'513c077a769980d9c6b1df5b0195401f2f67a062';
