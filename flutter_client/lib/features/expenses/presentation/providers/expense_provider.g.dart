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
    r'b1ad935b11d41d6703c0cf85af1f64d5cf4aaef9';

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
String _$monthlyProjectionHash() => r'a82e4c897b5abcd44ab1dc34cd7538a695ad3d90';

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
String _$expenseBalancesHash() => r'1726eaee36cfa3bf82470443b8253a4caa436147';

/// See also [ExpenseBalances].
@ProviderFor(ExpenseBalances)
final expenseBalancesProvider = AutoDisposeAsyncNotifierProvider<
    ExpenseBalances, List<HouseholdBalanceModel>>.internal(
  ExpenseBalances.new,
  name: r'expenseBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseBalances
    = AutoDisposeAsyncNotifier<List<HouseholdBalanceModel>>;
String _$expenseControllerHash() => r'fe922b49f6b34ce389139bf27fe411b7e2eab4c2';

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
    r'c40e1d1f25cda07611162b18534144e9e6a53ff7';

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
    r'ae93628fc23a05ebc6ffac5f375508a7877f029c';

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
