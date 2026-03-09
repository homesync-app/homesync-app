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
String _$personalFinanceSummaryHash() =>
    r'34100303376c4e3a3a6039b6b1bf3bd20875b6a5';

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
String _$expenseBalancesHash() => r'ff3cf4266841e1f70ce794b2910fbdbc6608cb21';

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
String _$expenseControllerHash() => r'db8f1922c9d6d8e6226b9133ab1a2e64425d66fd';

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
