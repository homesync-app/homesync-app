// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_space_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(coupleSpaceRepository)
final coupleSpaceRepositoryProvider = CoupleSpaceRepositoryProvider._();

final class CoupleSpaceRepositoryProvider extends $FunctionalProvider<
    CoupleSpaceRepository,
    CoupleSpaceRepository,
    CoupleSpaceRepository> with $Provider<CoupleSpaceRepository> {
  CoupleSpaceRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'coupleSpaceRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$coupleSpaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<CoupleSpaceRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CoupleSpaceRepository create(Ref ref) {
    return coupleSpaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoupleSpaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoupleSpaceRepository>(value),
    );
  }
}

String _$coupleSpaceRepositoryHash() =>
    r'd7610b0c1e918168ba278626e9b95e8f411b8d71';

@ProviderFor(coupleConnectionSummary)
final coupleConnectionSummaryProvider = CoupleConnectionSummaryFamily._();

final class CoupleConnectionSummaryProvider extends $FunctionalProvider<
        AsyncValue<CoupleConnectionSummary>,
        CoupleConnectionSummary,
        FutureOr<CoupleConnectionSummary>>
    with
        $FutureModifier<CoupleConnectionSummary>,
        $FutureProvider<CoupleConnectionSummary> {
  CoupleConnectionSummaryProvider._(
      {required CoupleConnectionSummaryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'coupleConnectionSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$coupleConnectionSummaryHash();

  @override
  String toString() {
    return r'coupleConnectionSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CoupleConnectionSummary> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CoupleConnectionSummary> create(Ref ref) {
    final argument = this.argument as String;
    return coupleConnectionSummary(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CoupleConnectionSummaryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coupleConnectionSummaryHash() =>
    r'6846c119f4fa6b4ff37dc6a60cfadc40795f6b8e';

final class CoupleConnectionSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CoupleConnectionSummary>, String> {
  CoupleConnectionSummaryFamily._()
      : super(
          retry: null,
          name: r'coupleConnectionSummaryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CoupleConnectionSummaryProvider call(
    String householdId,
  ) =>
      CoupleConnectionSummaryProvider._(argument: householdId, from: this);

  @override
  String toString() => r'coupleConnectionSummaryProvider';
}

@ProviderFor(coupleProposals)
final coupleProposalsProvider = CoupleProposalsFamily._();

final class CoupleProposalsProvider extends $FunctionalProvider<
        AsyncValue<List<CoupleProposal>>,
        List<CoupleProposal>,
        Stream<List<CoupleProposal>>>
    with
        $FutureModifier<List<CoupleProposal>>,
        $StreamProvider<List<CoupleProposal>> {
  CoupleProposalsProvider._(
      {required CoupleProposalsFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'coupleProposalsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$coupleProposalsHash();

  @override
  String toString() {
    return r'coupleProposalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CoupleProposal>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<CoupleProposal>> create(Ref ref) {
    final argument = this.argument as String;
    return coupleProposals(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CoupleProposalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coupleProposalsHash() => r'd7eaefa5050d51024862b28710c4cb0053afc31a';

final class CoupleProposalsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CoupleProposal>>, String> {
  CoupleProposalsFamily._()
      : super(
          retry: null,
          name: r'coupleProposalsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  CoupleProposalsProvider call(
    String householdId,
  ) =>
      CoupleProposalsProvider._(argument: householdId, from: this);

  @override
  String toString() => r'coupleProposalsProvider';
}
