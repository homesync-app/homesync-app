// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savingsRepositoryHash() => r'57fe3e37cf7da8999c58163c88d392d0b766f7ea';

/// See also [savingsRepository].
@ProviderFor(savingsRepository)
final savingsRepositoryProvider =
    AutoDisposeProvider<SavingsRepository>.internal(
  savingsRepository,
  name: r'savingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SavingsRepositoryRef = AutoDisposeProviderRef<SavingsRepository>;
String _$getSavingsGoalsUseCaseHash() =>
    r'1cf72505da09853466d81397b5d3b4fe8d2f2d4a';

/// See also [getSavingsGoalsUseCase].
@ProviderFor(getSavingsGoalsUseCase)
final getSavingsGoalsUseCaseProvider =
    AutoDisposeProvider<GetSavingsGoalsUseCase>.internal(
  getSavingsGoalsUseCase,
  name: r'getSavingsGoalsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getSavingsGoalsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetSavingsGoalsUseCaseRef
    = AutoDisposeProviderRef<GetSavingsGoalsUseCase>;
String _$getGoalContributionsUseCaseHash() =>
    r'9815fa438f6c9e31d09cab669366768289fe5b88';

/// See also [getGoalContributionsUseCase].
@ProviderFor(getGoalContributionsUseCase)
final getGoalContributionsUseCaseProvider =
    AutoDisposeProvider<GetGoalContributionsUseCase>.internal(
  getGoalContributionsUseCase,
  name: r'getGoalContributionsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getGoalContributionsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetGoalContributionsUseCaseRef
    = AutoDisposeProviderRef<GetGoalContributionsUseCase>;
String _$createSavingsGoalUseCaseHash() =>
    r'495bff3773d58ed2b32ac555c6acf3d3b4e3b18a';

/// See also [createSavingsGoalUseCase].
@ProviderFor(createSavingsGoalUseCase)
final createSavingsGoalUseCaseProvider =
    AutoDisposeProvider<CreateSavingsGoalUseCase>.internal(
  createSavingsGoalUseCase,
  name: r'createSavingsGoalUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createSavingsGoalUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateSavingsGoalUseCaseRef
    = AutoDisposeProviderRef<CreateSavingsGoalUseCase>;
String _$addContributionUseCaseHash() =>
    r'0ca65f7a7dd1d9f3d09e3ac5405007ed729efb53';

/// See also [addContributionUseCase].
@ProviderFor(addContributionUseCase)
final addContributionUseCaseProvider =
    AutoDisposeProvider<AddContributionUseCase>.internal(
  addContributionUseCase,
  name: r'addContributionUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$addContributionUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AddContributionUseCaseRef
    = AutoDisposeProviderRef<AddContributionUseCase>;
String _$deleteSavingsGoalUseCaseHash() =>
    r'c44ade87f607a6b30597b619eeec87a877dc528c';

/// See also [deleteSavingsGoalUseCase].
@ProviderFor(deleteSavingsGoalUseCase)
final deleteSavingsGoalUseCaseProvider =
    AutoDisposeProvider<DeleteSavingsGoalUseCase>.internal(
  deleteSavingsGoalUseCase,
  name: r'deleteSavingsGoalUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteSavingsGoalUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteSavingsGoalUseCaseRef
    = AutoDisposeProviderRef<DeleteSavingsGoalUseCase>;
String _$goalContributionsHash() => r'02a3fd4adf704201e3f9dddec857cb35944d1146';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [goalContributions].
@ProviderFor(goalContributions)
const goalContributionsProvider = GoalContributionsFamily();

/// See also [goalContributions].
class GoalContributionsFamily
    extends Family<AsyncValue<List<SavingsContributionModel>>> {
  /// See also [goalContributions].
  const GoalContributionsFamily();

  /// See also [goalContributions].
  GoalContributionsProvider call(
    String goalId,
  ) {
    return GoalContributionsProvider(
      goalId,
    );
  }

  @override
  GoalContributionsProvider getProviderOverride(
    covariant GoalContributionsProvider provider,
  ) {
    return call(
      provider.goalId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'goalContributionsProvider';
}

/// See also [goalContributions].
class GoalContributionsProvider
    extends AutoDisposeFutureProvider<List<SavingsContributionModel>> {
  /// See also [goalContributions].
  GoalContributionsProvider(
    String goalId,
  ) : this._internal(
          (ref) => goalContributions(
            ref as GoalContributionsRef,
            goalId,
          ),
          from: goalContributionsProvider,
          name: r'goalContributionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$goalContributionsHash,
          dependencies: GoalContributionsFamily._dependencies,
          allTransitiveDependencies:
              GoalContributionsFamily._allTransitiveDependencies,
          goalId: goalId,
        );

  GoalContributionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.goalId,
  }) : super.internal();

  final String goalId;

  @override
  Override overrideWith(
    FutureOr<List<SavingsContributionModel>> Function(
            GoalContributionsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GoalContributionsProvider._internal(
        (ref) => create(ref as GoalContributionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        goalId: goalId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SavingsContributionModel>>
      createElement() {
    return _GoalContributionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalContributionsProvider && other.goalId == goalId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, goalId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GoalContributionsRef
    on AutoDisposeFutureProviderRef<List<SavingsContributionModel>> {
  /// The parameter `goalId` of this provider.
  String get goalId;
}

class _GoalContributionsProviderElement
    extends AutoDisposeFutureProviderElement<List<SavingsContributionModel>>
    with GoalContributionsRef {
  _GoalContributionsProviderElement(super.provider);

  @override
  String get goalId => (origin as GoalContributionsProvider).goalId;
}

String _$savingsGoalsHash() => r'5e4acc8f5724e00249c7cea1c2488afe021548be';

/// See also [SavingsGoals].
@ProviderFor(SavingsGoals)
final savingsGoalsProvider = AutoDisposeAsyncNotifierProvider<SavingsGoals,
    List<SavingsGoalModel>>.internal(
  SavingsGoals.new,
  name: r'savingsGoalsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$savingsGoalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SavingsGoals = AutoDisposeAsyncNotifier<List<SavingsGoalModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
