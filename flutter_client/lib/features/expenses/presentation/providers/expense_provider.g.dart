// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseRepository)
final expenseRepositoryProvider = ExpenseRepositoryProvider._();

final class ExpenseRepositoryProvider extends $FunctionalProvider<
    ExpenseRepository,
    ExpenseRepository,
    ExpenseRepository> with $Provider<ExpenseRepository> {
  ExpenseRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expenseRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expenseRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpenseRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExpenseRepository create(Ref ref) {
    return expenseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseRepository>(value),
    );
  }
}

String _$expenseRepositoryHash() => r'5da251b699e286e75db8e21ed09c45abf2b798b8';

@ProviderFor(getExpensesUseCase)
final getExpensesUseCaseProvider = GetExpensesUseCaseProvider._();

final class GetExpensesUseCaseProvider extends $FunctionalProvider<
    GetExpensesUseCase,
    GetExpensesUseCase,
    GetExpensesUseCase> with $Provider<GetExpensesUseCase> {
  GetExpensesUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getExpensesUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getExpensesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetExpensesUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetExpensesUseCase create(Ref ref) {
    return getExpensesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetExpensesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetExpensesUseCase>(value),
    );
  }
}

String _$getExpensesUseCaseHash() =>
    r'86d88aa315e8492d9165f61c53f257da9243bd80';

@ProviderFor(getCombinedFeedUseCase)
final getCombinedFeedUseCaseProvider = GetCombinedFeedUseCaseProvider._();

final class GetCombinedFeedUseCaseProvider extends $FunctionalProvider<
    GetCombinedFeedUseCase,
    GetCombinedFeedUseCase,
    GetCombinedFeedUseCase> with $Provider<GetCombinedFeedUseCase> {
  GetCombinedFeedUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getCombinedFeedUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCombinedFeedUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCombinedFeedUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetCombinedFeedUseCase create(Ref ref) {
    return getCombinedFeedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCombinedFeedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCombinedFeedUseCase>(value),
    );
  }
}

String _$getCombinedFeedUseCaseHash() =>
    r'a54fc1b0f959139edd930196ef054e367fe4c078';

@ProviderFor(getBalancesUseCase)
final getBalancesUseCaseProvider = GetBalancesUseCaseProvider._();

final class GetBalancesUseCaseProvider extends $FunctionalProvider<
    GetBalancesUseCase,
    GetBalancesUseCase,
    GetBalancesUseCase> with $Provider<GetBalancesUseCase> {
  GetBalancesUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getBalancesUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getBalancesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetBalancesUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetBalancesUseCase create(Ref ref) {
    return getBalancesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetBalancesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetBalancesUseCase>(value),
    );
  }
}

String _$getBalancesUseCaseHash() =>
    r'fb209ad2a37377c7893de03b18de3746018a85cf';

@ProviderFor(getPersonalFinanceSummaryUseCase)
final getPersonalFinanceSummaryUseCaseProvider =
    GetPersonalFinanceSummaryUseCaseProvider._();

final class GetPersonalFinanceSummaryUseCaseProvider
    extends $FunctionalProvider<GetPersonalFinanceSummaryUseCase,
        GetPersonalFinanceSummaryUseCase, GetPersonalFinanceSummaryUseCase>
    with $Provider<GetPersonalFinanceSummaryUseCase> {
  GetPersonalFinanceSummaryUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getPersonalFinanceSummaryUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getPersonalFinanceSummaryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPersonalFinanceSummaryUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetPersonalFinanceSummaryUseCase create(Ref ref) {
    return getPersonalFinanceSummaryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPersonalFinanceSummaryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<GetPersonalFinanceSummaryUseCase>(value),
    );
  }
}

String _$getPersonalFinanceSummaryUseCaseHash() =>
    r'2b227e71c7e60499dd67155c555caae3ebde027c';

@ProviderFor(PersonalFinanceSummary)
final personalFinanceSummaryProvider = PersonalFinanceSummaryProvider._();

final class PersonalFinanceSummaryProvider extends $AsyncNotifierProvider<
    PersonalFinanceSummary, Map<String, dynamic>> {
  PersonalFinanceSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'personalFinanceSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$personalFinanceSummaryHash();

  @$internal
  @override
  PersonalFinanceSummary create() => PersonalFinanceSummary();
}

String _$personalFinanceSummaryHash() =>
    r'0323d22f5eaaaf2c959ab5a09c5e291895a240f6';

abstract class _$PersonalFinanceSummary
    extends $AsyncNotifier<Map<String, dynamic>> {
  FutureOr<Map<String, dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Map<String, dynamic>>, Map<String, dynamic>>,
        AsyncValue<Map<String, dynamic>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpenseBalances)
final expenseBalancesProvider = ExpenseBalancesProvider._();

final class ExpenseBalancesProvider extends $AsyncNotifierProvider<
    ExpenseBalances, List<HouseholdBalanceModel>> {
  ExpenseBalancesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expenseBalancesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expenseBalancesHash();

  @$internal
  @override
  ExpenseBalances create() => ExpenseBalances();
}

String _$expenseBalancesHash() => r'ed9878a7b5b3e783c8a3a043b39aab15dd2753fa';

abstract class _$ExpenseBalances
    extends $AsyncNotifier<List<HouseholdBalanceModel>> {
  FutureOr<List<HouseholdBalanceModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<HouseholdBalanceModel>>,
        List<HouseholdBalanceModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<HouseholdBalanceModel>>,
            List<HouseholdBalanceModel>>,
        AsyncValue<List<HouseholdBalanceModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpenseController)
final expenseControllerProvider = ExpenseControllerProvider._();

final class ExpenseControllerProvider
    extends $AsyncNotifierProvider<ExpenseController, List<ExpenseModel>> {
  ExpenseControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expenseControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expenseControllerHash();

  @$internal
  @override
  ExpenseController create() => ExpenseController();
}

String _$expenseControllerHash() => r'8c021728e1c66ff1fb982548541db521b930eb23';

abstract class _$ExpenseController extends $AsyncNotifier<List<ExpenseModel>> {
  FutureOr<List<ExpenseModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ExpenseModel>>, List<ExpenseModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ExpenseModel>>, List<ExpenseModel>>,
        AsyncValue<List<ExpenseModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CombinedFeedController)
final combinedFeedControllerProvider = CombinedFeedControllerProvider._();

final class CombinedFeedControllerProvider extends $AsyncNotifierProvider<
    CombinedFeedController, List<FeedItemModel>> {
  CombinedFeedControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'combinedFeedControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$combinedFeedControllerHash();

  @$internal
  @override
  CombinedFeedController create() => CombinedFeedController();
}

String _$combinedFeedControllerHash() =>
    r'03e0e828d6c28b377f6f9fd16f18d6bc8fcce6a3';

abstract class _$CombinedFeedController
    extends $AsyncNotifier<List<FeedItemModel>> {
  FutureOr<List<FeedItemModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<FeedItemModel>>, List<FeedItemModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<FeedItemModel>>, List<FeedItemModel>>,
        AsyncValue<List<FeedItemModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ExpenseTemplateController)
final expenseTemplateControllerProvider = ExpenseTemplateControllerProvider._();

final class ExpenseTemplateControllerProvider extends $AsyncNotifierProvider<
    ExpenseTemplateController, List<ExpenseTemplateModel>> {
  ExpenseTemplateControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expenseTemplateControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expenseTemplateControllerHash();

  @$internal
  @override
  ExpenseTemplateController create() => ExpenseTemplateController();
}

String _$expenseTemplateControllerHash() =>
    r'4116020e7c8072eb9f3c61c54bf70c0a7a9c024c';

abstract class _$ExpenseTemplateController
    extends $AsyncNotifier<List<ExpenseTemplateModel>> {
  FutureOr<List<ExpenseTemplateModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ExpenseTemplateModel>>,
        List<ExpenseTemplateModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ExpenseTemplateModel>>,
            List<ExpenseTemplateModel>>,
        AsyncValue<List<ExpenseTemplateModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(monthlyPendingPlannedExpenses)
final monthlyPendingPlannedExpensesProvider =
    MonthlyPendingPlannedExpensesProvider._();

final class MonthlyPendingPlannedExpensesProvider extends $FunctionalProvider<
        AsyncValue<List<FeedItemModel>>,
        List<FeedItemModel>,
        FutureOr<List<FeedItemModel>>>
    with
        $FutureModifier<List<FeedItemModel>>,
        $FutureProvider<List<FeedItemModel>> {
  MonthlyPendingPlannedExpensesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'monthlyPendingPlannedExpensesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$monthlyPendingPlannedExpensesHash();

  @$internal
  @override
  $FutureProviderElement<List<FeedItemModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<FeedItemModel>> create(Ref ref) {
    return monthlyPendingPlannedExpenses(ref);
  }
}

String _$monthlyPendingPlannedExpensesHash() =>
    r'22a8a77ee75ce6d1bf65e6e8db41aa98dad6ba0a';

@ProviderFor(monthlyProjection)
final monthlyProjectionProvider = MonthlyProjectionProvider._();

final class MonthlyProjectionProvider extends $FunctionalProvider<
        AsyncValue<MonthlyProjectionData>,
        MonthlyProjectionData,
        FutureOr<MonthlyProjectionData>>
    with
        $FutureModifier<MonthlyProjectionData>,
        $FutureProvider<MonthlyProjectionData> {
  MonthlyProjectionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'monthlyProjectionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$monthlyProjectionHash();

  @$internal
  @override
  $FutureProviderElement<MonthlyProjectionData> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MonthlyProjectionData> create(Ref ref) {
    return monthlyProjection(ref);
  }
}

String _$monthlyProjectionHash() => r'29000c214d4de889017ec3241ddbedd2c4710da2';

@ProviderFor(ExpenseFiltersNotifier)
final expenseFiltersProvider = ExpenseFiltersNotifierProvider._();

final class ExpenseFiltersNotifierProvider
    extends $NotifierProvider<ExpenseFiltersNotifier, Map<String, dynamic>> {
  ExpenseFiltersNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'expenseFiltersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$expenseFiltersNotifierHash();

  @$internal
  @override
  ExpenseFiltersNotifier create() => ExpenseFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>>(value),
    );
  }
}

String _$expenseFiltersNotifierHash() =>
    r'668f4d76d09978368ddf7e1f5aac78c322f4982f';

abstract class _$ExpenseFiltersNotifier
    extends $Notifier<Map<String, dynamic>> {
  Map<String, dynamic> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, dynamic>, Map<String, dynamic>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, dynamic>, Map<String, dynamic>>,
        Map<String, dynamic>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MercadopagoMovements)
final mercadopagoMovementsProvider = MercadopagoMovementsProvider._();

final class MercadopagoMovementsProvider extends $AsyncNotifierProvider<
    MercadopagoMovements, List<Map<String, dynamic>>> {
  MercadopagoMovementsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mercadopagoMovementsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mercadopagoMovementsHash();

  @$internal
  @override
  MercadopagoMovements create() => MercadopagoMovements();
}

String _$mercadopagoMovementsHash() =>
    r'04581643c0618bcfa24e58ac6275b1e95178d3ef';

abstract class _$MercadopagoMovements
    extends $AsyncNotifier<List<Map<String, dynamic>>> {
  FutureOr<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Map<String, dynamic>>>,
            List<Map<String, dynamic>>>,
        AsyncValue<List<Map<String, dynamic>>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
