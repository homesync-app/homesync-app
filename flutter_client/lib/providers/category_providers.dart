import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('categories')
      .select('*')
      .order('sort_order', ascending: true);
  
  return (response as List)
      .map((json) => CategoryModel.fromMap(json))
      .toList();
});
