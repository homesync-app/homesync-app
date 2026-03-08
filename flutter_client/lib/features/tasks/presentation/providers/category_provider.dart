import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_provider.g.dart';

@riverpod
Future<List<CategoryModel>> categories(CategoriesRef ref) async {
  final client = ref.read(supabaseClientProvider);
  final response = await client
      .from('categories')
      .select('*')
      .order('sort_order', ascending: true);

  return (response as List).map((json) => CategoryModel.fromMap(json)).toList();
}

@riverpod
Map<String, CategoryModel> categoryMap(CategoryMapRef ref) {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.maybeWhen(
    data: (list) => {for (var c in list) c.id: c},
    orElse: () => {},
  );
}
