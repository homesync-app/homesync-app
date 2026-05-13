// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statsRepository)
final statsRepositoryProvider = StatsRepositoryProvider._();

final class StatsRepositoryProvider extends $FunctionalProvider<StatsRepository,
    StatsRepository, StatsRepository> with $Provider<StatsRepository> {
  StatsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statsRepositoryHash();

  @$internal
  @override
  $ProviderElement<StatsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StatsRepository create(Ref ref) {
    return statsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StatsRepository>(value),
    );
  }
}

String _$statsRepositoryHash() => r'673ccf19eb0453c2f116eed95212f2dff25c44ea';

@ProviderFor(taskStatsByCategoryUseCase)
final taskStatsByCategoryUseCaseProvider =
    TaskStatsByCategoryUseCaseProvider._();

final class TaskStatsByCategoryUseCaseProvider extends $FunctionalProvider<
        GetTaskStatsByCategoryUseCase,
        GetTaskStatsByCategoryUseCase,
        GetTaskStatsByCategoryUseCase>
    with $Provider<GetTaskStatsByCategoryUseCase> {
  TaskStatsByCategoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskStatsByCategoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskStatsByCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetTaskStatsByCategoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetTaskStatsByCategoryUseCase create(Ref ref) {
    return taskStatsByCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetTaskStatsByCategoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<GetTaskStatsByCategoryUseCase>(value),
    );
  }
}

String _$taskStatsByCategoryUseCaseHash() =>
    r'5878609b52130b0d306a9ddf53ddda85226e2382';

@ProviderFor(xpHistoryUseCase)
final xpHistoryUseCaseProvider = XpHistoryUseCaseProvider._();

final class XpHistoryUseCaseProvider extends $FunctionalProvider<
    GetXpHistoryUseCase,
    GetXpHistoryUseCase,
    GetXpHistoryUseCase> with $Provider<GetXpHistoryUseCase> {
  XpHistoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'xpHistoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$xpHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetXpHistoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetXpHistoryUseCase create(Ref ref) {
    return xpHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetXpHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetXpHistoryUseCase>(value),
    );
  }
}

String _$xpHistoryUseCaseHash() => r'2aed77b65547a535e595923b22825090a18c558a';

@ProviderFor(coinHistoryUseCase)
final coinHistoryUseCaseProvider = CoinHistoryUseCaseProvider._();

final class CoinHistoryUseCaseProvider extends $FunctionalProvider<
    GetCoinHistoryUseCase,
    GetCoinHistoryUseCase,
    GetCoinHistoryUseCase> with $Provider<GetCoinHistoryUseCase> {
  CoinHistoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'coinHistoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$coinHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCoinHistoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCoinHistoryUseCase create(Ref ref) {
    return coinHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCoinHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCoinHistoryUseCase>(value),
    );
  }
}

String _$coinHistoryUseCaseHash() =>
    r'119f95671b38754be4f2a7a8bc0e1947b3e3da6a';

@ProviderFor(expenseStatsByCategoryUseCase)
final expenseStatsByCategoryUseCaseProvider =
    ExpenseStatsByCategoryUseCaseProvider._();

final class ExpenseStatsByCategoryUseCaseProvider extends $FunctionalProvider<
        GetExpenseStatsByCategoryUseCase,
        GetExpenseStatsByCategoryUseCase,
        GetExpenseStatsByCategoryUseCase>
    with $Provider<GetExpenseStatsByCategoryUseCase> {
  ExpenseStatsByCategoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expenseStatsByCategoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expenseStatsByCategoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetExpenseStatsByCategoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetExpenseStatsByCategoryUseCase create(Ref ref) {
    return expenseStatsByCategoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetExpenseStatsByCategoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<GetExpenseStatsByCategoryUseCase>(value),
    );
  }
}

String _$expenseStatsByCategoryUseCaseHash() =>
    r'73fd72eb7ccbfd5f61daff312fc158ba029b9404';

@ProviderFor(memberActivityStatsUseCase)
final memberActivityStatsUseCaseProvider =
    MemberActivityStatsUseCaseProvider._();

final class MemberActivityStatsUseCaseProvider extends $FunctionalProvider<
        GetMemberActivityStatsUseCase,
        GetMemberActivityStatsUseCase,
        GetMemberActivityStatsUseCase>
    with $Provider<GetMemberActivityStatsUseCase> {
  MemberActivityStatsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'memberActivityStatsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$memberActivityStatsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMemberActivityStatsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetMemberActivityStatsUseCase create(Ref ref) {
    return memberActivityStatsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMemberActivityStatsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<GetMemberActivityStatsUseCase>(value),
    );
  }
}

String _$memberActivityStatsUseCaseHash() =>
    r'31f9f0bf48e49f0cab669e17d12139fb439224e3';

@ProviderFor(weeklyRankingUseCase)
final weeklyRankingUseCaseProvider = WeeklyRankingUseCaseProvider._();

final class WeeklyRankingUseCaseProvider extends $FunctionalProvider<
    GetWeeklyRankingUseCase,
    GetWeeklyRankingUseCase,
    GetWeeklyRankingUseCase> with $Provider<GetWeeklyRankingUseCase> {
  WeeklyRankingUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weeklyRankingUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyRankingUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetWeeklyRankingUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetWeeklyRankingUseCase create(Ref ref) {
    return weeklyRankingUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWeeklyRankingUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWeeklyRankingUseCase>(value),
    );
  }
}

String _$weeklyRankingUseCaseHash() =>
    r'27d59d2e4eec7a64d63b378e914019c2591d3272';

@ProviderFor(weeklyDuelHistoryUseCase)
final weeklyDuelHistoryUseCaseProvider = WeeklyDuelHistoryUseCaseProvider._();

final class WeeklyDuelHistoryUseCaseProvider extends $FunctionalProvider<
    GetWeeklyDuelHistoryUseCase,
    GetWeeklyDuelHistoryUseCase,
    GetWeeklyDuelHistoryUseCase> with $Provider<GetWeeklyDuelHistoryUseCase> {
  WeeklyDuelHistoryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weeklyDuelHistoryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyDuelHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetWeeklyDuelHistoryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetWeeklyDuelHistoryUseCase create(Ref ref) {
    return weeklyDuelHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetWeeklyDuelHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetWeeklyDuelHistoryUseCase>(value),
    );
  }
}

String _$weeklyDuelHistoryUseCaseHash() =>
    r'de821aac9175fdcc22103fc0977211b28f848abb';

@ProviderFor(weeklyWinnerAwardUseCase)
final weeklyWinnerAwardUseCaseProvider = WeeklyWinnerAwardUseCaseProvider._();

final class WeeklyWinnerAwardUseCaseProvider extends $FunctionalProvider<
    AwardWeeklyWinnerUseCase,
    AwardWeeklyWinnerUseCase,
    AwardWeeklyWinnerUseCase> with $Provider<AwardWeeklyWinnerUseCase> {
  WeeklyWinnerAwardUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weeklyWinnerAwardUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyWinnerAwardUseCaseHash();

  @$internal
  @override
  $ProviderElement<AwardWeeklyWinnerUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AwardWeeklyWinnerUseCase create(Ref ref) {
    return weeklyWinnerAwardUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AwardWeeklyWinnerUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AwardWeeklyWinnerUseCase>(value),
    );
  }
}

String _$weeklyWinnerAwardUseCaseHash() =>
    r'b1a662d6876961d47e1db2cc74352e3764473118';

@ProviderFor(weeklyDuelResultSaveUseCase)
final weeklyDuelResultSaveUseCaseProvider =
    WeeklyDuelResultSaveUseCaseProvider._();

final class WeeklyDuelResultSaveUseCaseProvider extends $FunctionalProvider<
    SaveWeeklyDuelResultUseCase,
    SaveWeeklyDuelResultUseCase,
    SaveWeeklyDuelResultUseCase> with $Provider<SaveWeeklyDuelResultUseCase> {
  WeeklyDuelResultSaveUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weeklyDuelResultSaveUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyDuelResultSaveUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveWeeklyDuelResultUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveWeeklyDuelResultUseCase create(Ref ref) {
    return weeklyDuelResultSaveUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveWeeklyDuelResultUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveWeeklyDuelResultUseCase>(value),
    );
  }
}

String _$weeklyDuelResultSaveUseCaseHash() =>
    r'decf9a68d69a9dcbaf923f513917e7f0f9cc7e0c';

@ProviderFor(StatsController)
final statsControllerProvider = StatsControllerProvider._();

final class StatsControllerProvider
    extends $AsyncNotifierProvider<StatsController, StatsData> {
  StatsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statsControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statsControllerHash();

  @$internal
  @override
  StatsController create() => StatsController();
}

String _$statsControllerHash() => r'48fd28b923624165f04257bb9bb342675bcf3d60';

abstract class _$StatsController extends $AsyncNotifier<StatsData> {
  FutureOr<StatsData> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StatsData>, StatsData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<StatsData>, StatsData>,
        AsyncValue<StatsData>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
