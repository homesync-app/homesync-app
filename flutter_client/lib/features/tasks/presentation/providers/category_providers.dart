import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final client = ref.read(supabaseClientProvider);
  final response = await client
      .from('categories')
      .select('*')
      .order('sort_order', ascending: true);
  
  return (response as List)
      .map((json) => CategoryModel.fromMap(json))
      .toList();
});

final categoryMapProvider = Provider<AsyncValue<Map<String, CategoryModel>>>((ref) {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.whenData((list) {
    return {for (var c in list) c.id: c};
  });
});
