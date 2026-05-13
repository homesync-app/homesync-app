// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categories)
final categoriesProvider = CategoriesProvider._();

final class CategoriesProvider extends $FunctionalProvider<
        AsyncValue<List<CategoryModel>>,
        List<CategoryModel>,
        FutureOr<List<CategoryModel>>>
    with
        $FutureModifier<List<CategoryModel>>,
        $FutureProvider<List<CategoryModel>> {
  CategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<CategoryModel>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryModel>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'54924a3f8b05c98630da9d40349bbc270cb71fea';

@ProviderFor(categoryMap)
final categoryMapProvider = CategoryMapProvider._();

final class CategoryMapProvider extends $FunctionalProvider<
    Map<String, CategoryModel>,
    Map<String, CategoryModel>,
    Map<String, CategoryModel>> with $Provider<Map<String, CategoryModel>> {
  CategoryMapProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryMapProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryMapHash();

  @$internal
  @override
  $ProviderElement<Map<String, CategoryModel>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, CategoryModel> create(Ref ref) {
    return categoryMap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, CategoryModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, CategoryModel>>(value),
    );
  }
}

String _$categoryMapHash() => r'73989bf59b881c4efcfd4120b7363d72b1e1c4c0';
