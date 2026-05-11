// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseRepositoryHash() => r'6d92aaef781ff86e8e47d1be96a701ed3e446f26';

/// See also [expenseRepository].
@ProviderFor(expenseRepository)
final expenseRepositoryProvider =
    AutoDisposeProvider<ExpenseRepository>.internal(
  expenseRepository,
  name: r'expenseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseRepositoryRef = AutoDisposeProviderRef<ExpenseRepository>;
String _$getExpensesUseCaseHash() =>
    r'864fdc75d0cbce04736a7903af97835895dabef5';

/// See also [getExpensesUseCase].
@ProviderFor(getExpensesUseCase)
final getExpensesUseCaseProvider =
    AutoDisposeProvider<GetExpensesUseCase>.internal(
  getExpensesUseCase,
  name: r'getExpensesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getExpensesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetExpensesUseCaseRef = AutoDisposeProviderRef<GetExpensesUseCase>;
String _$getCombinedFeedUseCaseHash() =>
    r'776c80d0c32014624001d544abea6cb6ded9e42f';

/// See also [getCombinedFeedUseCase].
@ProviderFor(getCombinedFeedUseCase)
final getCombinedFeedUseCaseProvider =
    AutoDisposeProvider<GetCombinedFeedUseCase>.internal(
  getCombinedFeedUseCase,
  name: r'getCombinedFeedUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getCombinedFeedUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetCombinedFeedUseCaseRef
    = AutoDisposeProviderRef<GetCombinedFeedUseCase>;
String _$getBalancesUseCaseHash() =>
    r'2986fd5ba6e460ac4c7e16b76d572d70f9924cee';

/// See also [getBalancesUseCase].
@ProviderFor(getBalancesUseCase)
final getBalancesUseCaseProvider =
    AutoDisposeProvider<GetBalancesUseCase>.internal(
  getBalancesUseCase,
  name: r'getBalancesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getBalancesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetBalancesUseCaseRef = AutoDisposeProviderRef<GetBalancesUseCase>;
String _$getPersonalFinanceSummaryUseCaseHash() =>
    r'3a26bd4131d499ed6860cfd13e7343874ccc40b0';

/// See also [getPersonalFinanceSummaryUseCase].
@ProviderFor(getPersonalFinanceSummaryUseCase)
final getPersonalFinanceSummaryUseCaseProvider =
    AutoDisposeProvider<GetPersonalFinanceSummaryUseCase>.internal(
  getPersonalFinanceSummaryUseCase,
  name: r'getPersonalFinanceSummaryUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getPersonalFinanceSummaryUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPersonalFinanceSummaryUseCaseRef
    = AutoDisposeProviderRef<GetPersonalFinanceSummaryUseCase>;
String _$monthlyPendingPlannedExpensesHash() =>
    r'a4367c7121abac4b51ffa9e74d8eb463cf61bab1';

/// See also [monthlyPendingPlannedExpenses].
@ProviderFor(monthlyPendingPlannedExpenses)
final monthlyPendingPlannedExpensesProvider =
    AutoDisposeFutureProvider<List<FeedItemModel>>.internal(
  monthlyPendingPlannedExpenses,
  name: r'monthlyPendingPlannedExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyPendingPlannedExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyPendingPlannedExpensesRef
    = AutoDisposeFutureProviderRef<List<FeedItemModel>>;
String _$monthlyProjectionHash() => r'f721034d7d36bf970e87a712b5a0529466782161';

/// See also [monthlyProjection].
@ProviderFor(monthlyProjection)
final monthlyProjectionProvider =
    AutoDisposeFutureProvider<MonthlyProjectionData>.internal(
  monthlyProjection,
  name: r'monthlyProjectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyProjectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyProjectionRef
    = AutoDisposeFutureProviderRef<MonthlyProjectionData>;
String _$personalFinanceSummaryHash() =>
    r'0323d22f5eaaaf2c959ab5a09c5e291895a240f6';

/// See also [PersonalFinanceSummary].
@ProviderFor(PersonalFinanceSummary)
final personalFinanceSummaryProvider = AutoDisposeAsyncNotifierProvider<
    PersonalFinanceSummary, Map<String, dynamic>>.internal(
  PersonalFinanceSummary.new,
  name: r'personalFinanceSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personalFinanceSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PersonalFinanceSummary
    = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
String _$expenseBalancesHash() => r'ed9878a7b5b3e783c8a3a043b39aab15dd2753fa';

/// See also [ExpenseBalances].
@ProviderFor(ExpenseBalances)
final expenseBalancesProvider = AsyncNotifierProvider<ExpenseBalances,
    List<HouseholdBalanceModel>>.internal(
  ExpenseBalances.new,
  name: r'expenseBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseBalances = AsyncNotifier<List<HouseholdBalanceModel>>;
String _$expenseControllerHash() => r'7eed4017b89ce763df5c3a3250b3c63a27f4f0c4';

/// See also [ExpenseController].
@ProviderFor(ExpenseController)
final expenseControllerProvider = AutoDisposeAsyncNotifierProvider<
    ExpenseController, List<ExpenseModel>>.internal(
  ExpenseController.new,
  name: r'expenseControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseController = AutoDisposeAsyncNotifier<List<ExpenseModel>>;
String _$combinedFeedControllerHash() =>
    r'3934382215ed808135dc59952798baffa6b0bad5';

/// See also [CombinedFeedController].
@ProviderFor(CombinedFeedController)
final combinedFeedControllerProvider = AutoDisposeAsyncNotifierProvider<
    CombinedFeedController, List<FeedItemModel>>.internal(
  CombinedFeedController.new,
  name: r'combinedFeedControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$combinedFeedControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CombinedFeedController
    = AutoDisposeAsyncNotifier<List<FeedItemModel>>;
String _$expenseTemplateControllerHash() =>
    r'4116020e7c8072eb9f3c61c54bf70c0a7a9c024c';

/// See also [ExpenseTemplateController].
@ProviderFor(ExpenseTemplateController)
final expenseTemplateControllerProvider = AutoDisposeAsyncNotifierProvider<
    ExpenseTemplateController, List<ExpenseTemplateModel>>.internal(
  ExpenseTemplateController.new,
  name: r'expenseTemplateControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseTemplateControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseTemplateController
    = AutoDisposeAsyncNotifier<List<ExpenseTemplateModel>>;
String _$expenseFiltersNotifierHash() =>
    r'668f4d76d09978368ddf7e1f5aac78c322f4982f';

/// See also [ExpenseFiltersNotifier].
@ProviderFor(ExpenseFiltersNotifier)
final expenseFiltersNotifierProvider = AutoDisposeNotifierProvider<
    ExpenseFiltersNotifier, Map<String, dynamic>>.internal(
  ExpenseFiltersNotifier.new,
  name: r'expenseFiltersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseFiltersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseFiltersNotifier = AutoDisposeNotifier<Map<String, dynamic>>;
String _$mercadopagoMovementsHash() =>
    r'04581643c0618bcfa24e58ac6275b1e95178d3ef';

/// See also [MercadopagoMovements].
@ProviderFor(MercadopagoMovements)
final mercadopagoMovementsProvider = AutoDisposeAsyncNotifierProvider<
    MercadopagoMovements, List<Map<String, dynamic>>>.internal(
  MercadopagoMovements.new,
  name: r'mercadopagoMovementsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mercadopagoMovementsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MercadopagoMovements
    = AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
