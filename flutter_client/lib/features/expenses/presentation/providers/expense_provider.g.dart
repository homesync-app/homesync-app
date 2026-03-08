// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseRepositoryHash() => r'224ce47b4a38579fc9e5508a4b3080f8ca97ba8e';

/// See also [expenseRepository].
@ProviderFor(expenseRepository)
final expenseRepositoryProvider = Provider<ExpenseRepository>.internal(
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
typedef ExpenseRepositoryRef = ProviderRef<ExpenseRepository>;
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
String _$saveExpenseUseCaseHash() =>
    r'8a89ce3d55fa2a496c4618888370a3074a78b699';

/// See also [saveExpenseUseCase].
@ProviderFor(saveExpenseUseCase)
final saveExpenseUseCaseProvider =
    AutoDisposeProvider<SaveExpenseUseCase>.internal(
  saveExpenseUseCase,
  name: r'saveExpenseUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$saveExpenseUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveExpenseUseCaseRef = AutoDisposeProviderRef<SaveExpenseUseCase>;
String _$deleteExpenseUseCaseHash() =>
    r'ebf8fa44afd87d1a7e32a28a9bb5bdc46e642e9a';

/// See also [deleteExpenseUseCase].
@ProviderFor(deleteExpenseUseCase)
final deleteExpenseUseCaseProvider =
    AutoDisposeProvider<DeleteExpenseUseCase>.internal(
  deleteExpenseUseCase,
  name: r'deleteExpenseUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteExpenseUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteExpenseUseCaseRef = AutoDisposeProviderRef<DeleteExpenseUseCase>;
String _$settleDebtUseCaseHash() => r'c8a8eb882d39ae8609a0626b67834c251711e1a7';

/// See also [settleDebtUseCase].
@ProviderFor(settleDebtUseCase)
final settleDebtUseCaseProvider =
    AutoDisposeProvider<SettleDebtUseCase>.internal(
  settleDebtUseCase,
  name: r'settleDebtUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settleDebtUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettleDebtUseCaseRef = AutoDisposeProviderRef<SettleDebtUseCase>;
String _$expensesAndBalancesHash() =>
    r'bace7b32ae1100d6233f93f6a650e931b104e258';

/// Provides the combined expenses and balances state stream
///
/// Copied from [expensesAndBalances].
@ProviderFor(expensesAndBalances)
final expensesAndBalancesProvider =
    StreamProvider<Map<String, dynamic>>.internal(
  expensesAndBalances,
  name: r'expensesAndBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expensesAndBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpensesAndBalancesRef = StreamProviderRef<Map<String, dynamic>>;
String _$personalFinanceSummaryHash() =>
    r'c13c2cdad67ca4059632d360e44eb842ee50f14d';

/// See also [personalFinanceSummary].
@ProviderFor(personalFinanceSummary)
final personalFinanceSummaryProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  personalFinanceSummary,
  name: r'personalFinanceSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personalFinanceSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonalFinanceSummaryRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$filteredExpensesHash() => r'845660b3072d322382039fa920892c125bdf2537';

/// See also [filteredExpenses].
@ProviderFor(filteredExpenses)
final filteredExpensesProvider =
    AutoDisposeFutureProvider<List<ExpenseModel>>.internal(
  filteredExpenses,
  name: r'filteredExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredExpensesRef = AutoDisposeFutureProviderRef<List<ExpenseModel>>;
String _$expenseBalancesHash() => r'2ea9f731b6c16a29db9c56550ac4e1d5e82bcc3f';

/// See also [expenseBalances].
@ProviderFor(expenseBalances)
final expenseBalancesProvider =
    AutoDisposeFutureProvider<List<HouseholdBalanceModel>>.internal(
  expenseBalances,
  name: r'expenseBalancesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseBalancesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseBalancesRef
    = AutoDisposeFutureProviderRef<List<HouseholdBalanceModel>>;
String _$expenseControllerHash() => r'05b7c24f7d8b4a7b8285c6259611814d38ff7ee0';

/// See also [ExpenseController].
@ProviderFor(ExpenseController)
final expenseControllerProvider =
    AsyncNotifierProvider<ExpenseController, List<ExpenseModel>>.internal(
  ExpenseController.new,
  name: r'expenseControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseController = AsyncNotifier<List<ExpenseModel>>;
String _$expenseFiltersNotifierHash() =>
    r'48a00c2ba2569a8cdc05d40e32c3dc98f73d42c2';

/// See also [ExpenseFiltersNotifier].
@ProviderFor(ExpenseFiltersNotifier)
final expenseFiltersNotifierProvider = AutoDisposeNotifierProvider<
    ExpenseFiltersNotifier, ExpenseFilters>.internal(
  ExpenseFiltersNotifier.new,
  name: r'expenseFiltersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseFiltersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExpenseFiltersNotifier = AutoDisposeNotifier<ExpenseFilters>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
