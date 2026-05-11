import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskTemplate {
  final String id;
  final String title;
  final String categoryId;
  final String difficulty;
  final int xpReward;
  final int coinReward;
  final String? icon;
  final bool isPopular;
  final String? translationKey;

  TaskTemplate({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.difficulty,
    required this.xpReward,
    required this.coinReward,
    this.icon,
    this.isPopular = false,
    this.translationKey,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    return TaskTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      categoryId: json['category_id'] as String,
      difficulty: json['difficulty'] as String,
      xpReward: json['xp_reward'] as int,
      coinReward: json['coin_reward'] as int,
      icon: json['icon'] as String?,
      isPopular: json['is_popular'] as bool? ?? false,
      translationKey: json['translation_key'] as String?,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int sortOrder;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class TemplateService {
  final SupabaseClient _client;

  TemplateService({required SupabaseClient supabaseClient})
      : _client = supabaseClient;

  Future<List<Category>> getCategories() async {
    final response =
        await _client.from('categories').select().order('sort_order');

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<TaskTemplate>> getTemplates({
    String? categoryId,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from('task_templates').select();

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final orderedQuery = query.order('sort_order');
    final response = await (offset != null && limit != null
        ? orderedQuery.range(offset, offset + limit - 1)
        : limit != null
            ? orderedQuery.limit(limit)
            : orderedQuery);

    return (response as List)
        .map((json) => TaskTemplate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String> _requireCurrentUserId() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }

    throw Exception('Usuario no autenticado');
  }

  Future<int> cloneTemplates(List<String> templateIds) async {
    final userId = await _requireCurrentUserId();

    final response = await _client.rpc(
      'clone_task_templates',
      params: {
        'p_user_id': userId,
        'p_template_ids': templateIds.isEmpty ? null : templateIds,
      },
    );

    return response as int;
  }

  Future<int> cloneAllTemplates() async {
    final userId = await _requireCurrentUserId();

    final response = await _client.rpc(
      'clone_task_templates',
      params: {
        'p_user_id': userId,
        'p_template_ids': null,
      },
    );

    return response as int;
  }
}
