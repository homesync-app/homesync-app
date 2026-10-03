// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_plans_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(couplePlansRepository)
final couplePlansRepositoryProvider = CouplePlansRepositoryProvider._();

final class CouplePlansRepositoryProvider extends $FunctionalProvider<
    CouplePlansRepository,
    CouplePlansRepository,
    CouplePlansRepository> with $Provider<CouplePlansRepository> {
  CouplePlansRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'couplePlansRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$couplePlansRepositoryHash();

  @$internal
  @override
  $ProviderElement<CouplePlansRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CouplePlansRepository create(Ref ref) {
    return couplePlansRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CouplePlansRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CouplePlansRepository>(value),
    );
  }
}

String _$couplePlansRepositoryHash() =>
    r'9e9c2a1a81efcb601bb55b4e9039733801d3e0a5';

@ProviderFor(couplePlanProgress)
final couplePlanProgressProvider = CouplePlanProgressFamily._();

final class CouplePlanProgressProvider extends $FunctionalProvider<
        AsyncValue<List<CouplePlanProgress>>,
        List<CouplePlanProgress>,
        Stream<List<CouplePlanProgress>>>
    with
        $FutureModifier<List<CouplePlanProgress>>,
        $StreamProvider<List<CouplePlanProgress>> {
  CouplePlanProgressProvider._(
      {required CouplePlanProgressFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'couplePlanProgressProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$couplePlanProgressHash();

  @override
  String toString() {
    return r'couplePlanProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CouplePlanProgress>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<CouplePlanProgress>> create(Ref ref) {
    final argument = this.argument as String;
    return couplePlanProgress(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CouplePlanProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$couplePlanProgressHash() =>
    r'267360ddbd621cb669b1103dc93f3cf6edaf81dd';

final class CouplePlanProgressFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CouplePlanProgress>>, String> {
  CouplePlanProgressFamily._()
      : super(
          retry: null,
          name: r'couplePlanProgressProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CouplePlanProgressProvider call(
    String householdId,
  ) =>
      CouplePlanProgressProvider._(argument: householdId, from: this);

  @override
  String toString() => r'couplePlanProgressProvider';
}
