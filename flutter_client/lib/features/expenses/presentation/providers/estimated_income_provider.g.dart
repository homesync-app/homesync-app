// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estimated_income_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EstimatedIncomeNotifier)
final estimatedIncomeProvider = EstimatedIncomeNotifierProvider._();

final class EstimatedIncomeNotifierProvider
    extends $AsyncNotifierProvider<EstimatedIncomeNotifier, EstimatedIncome> {
  EstimatedIncomeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'estimatedIncomeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$estimatedIncomeNotifierHash();

  @$internal
  @override
  EstimatedIncomeNotifier create() => EstimatedIncomeNotifier();
}

String _$estimatedIncomeNotifierHash() =>
    r'e0da51c9cf1173d68cbb543618bb62ac8fb5bd25';

abstract class _$EstimatedIncomeNotifier
    extends $AsyncNotifier<EstimatedIncome> {
  FutureOr<EstimatedIncome> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EstimatedIncome>, EstimatedIncome>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<EstimatedIncome>, EstimatedIncome>,
        AsyncValue<EstimatedIncome>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
