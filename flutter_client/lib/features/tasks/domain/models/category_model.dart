class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'General',
      icon: map['icon']?.toString() ?? '📦',
      color: map['color']?.toString() ?? '#94A3B8',
      sortOrder: map['sort_order'] ?? 0,
    );
  }
}
