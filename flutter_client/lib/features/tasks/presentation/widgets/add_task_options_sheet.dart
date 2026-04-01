import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';

import 'create_task_dialog.dart';

class AddTaskOptionsSheet extends ConsumerStatefulWidget {
  final List<MemberModel> members;

  const AddTaskOptionsSheet({super.key, required this.members});

  static Future<bool?> show(BuildContext context, List<MemberModel> members) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskOptionsSheet(members: members),
    );
  }

  @override
  ConsumerState<AddTaskOptionsSheet> createState() =>
      _AddTaskOptionsSheetState();
}

class _AddTaskOptionsSheetState extends ConsumerState<AddTaskOptionsSheet> {
  List<TaskTemplate> _templates = [];
  bool _isLoading = true;
  final Set<String> _addingIds = {};
  final Set<String> _addedIds = {};
  String? _selectedCategory;

  List<CategoryModel> _categories = [];
  TemplateService get _templateService => ref.read(templateServiceProvider);

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    try {
      final templates = await _templateService.getTemplates();
      if (mounted) {
        setState(() {
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTemplate(TaskTemplate template) async {
    if (_addingIds.contains(template.title)) return;

    setState(() {
      _addingIds.add(template.title);
      _addedIds.add(template.title);
    });

    try {
      await ref.read(tasksProvider.notifier).createTask({
        'title': template.title,
        'category': template.categoryId,
        'difficulty': template.difficulty,
        'xpReward': template.xpReward,
        'coinReward': template.coinReward,
        'description': null,
        'assignedTo': null,
        'recurrenceType': null,
        'isTemplate': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('"${template.title}" anadida')),
            ],
          ),
          backgroundColor: AppColors.accentGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _addingIds.remove(template.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final dbCategoriesAsync = ref.watch(categoriesProvider);

    final dbCategories = dbCategoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <CategoryModel>[],
    );
    _categories = dbCategories;

    final currentTasks = tasksAsync.value ?? [];
    final activeKeys = currentTasks
        .where((task) => !task.isVerified)
        .map(
          (task) =>
              "${task.title.toLowerCase().trim()}|${(task.category ?? 'none').toLowerCase().trim()}",
        )
        .toSet();

    final availableTemplates = _templates.where((template) {
      final key =
          "${template.title.toLowerCase().trim()}|${template.categoryId.toLowerCase().trim()}";
      return !activeKeys.contains(key);
    }).toList();

    final activeCatIds = availableTemplates.map((template) => template.categoryId).toSet();
    final displayCategories =
        dbCategories.where((category) => activeCatIds.contains(category.id)).toList();

    final filtered = _selectedCategory == null
        ? availableTemplates
        : availableTemplates
            .where((template) => template.categoryId == _selectedCategory)
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: context.theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.14),
                    ),
                  ),
                  child: const Icon(
                    Icons.playlist_add_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nueva tarea',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, _addedIds.isNotEmpty),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (!_isLoading && displayCategories.isNotEmpty)
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryChip(null, 'Todas', null),
                  ...displayCategories.map(
                    (category) =>
                        _buildCategoryChip(category.id, category.name, category),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: (_isLoading || tasksAsync.isLoading)
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : filtered.isEmpty
                    ? _buildEmpty()
                    : _buildTemplateList(filtered),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: context.theme.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => CreateTaskDialog(
                          members:
                              widget.members.map((member) => member.toMap()).toList(),
                        ),
                      );
                      if (result == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Personalizada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
                if (_addedIds.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    label: Text('Listo (${_addedIds.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? id, String name, CategoryModel? category) {
    final isSelected = _selectedCategory == id;
    final color = category != null
        ? AppColors.fromHex(category.color)
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.divider.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.03 : 0.015),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              id == null
                  ? Icons.format_list_bulleted_rounded
                  : AppColors.getCategoryMaterialIcon(id),
              size: 16,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ya tienes todas las sugeridas',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea una tarea personalizada abajo.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(List<TaskTemplate> templates) {
    final grouped = <String, List<TaskTemplate>>{};
    for (final template in templates) {
      (grouped[template.categoryId] ??= []).add(template);
    }

    final orderedCatIds = _categories
        .map((category) => category.id)
        .where((id) => grouped.containsKey(id))
        .toList();
    for (final id in grouped.keys) {
      if (!orderedCatIds.contains(id)) orderedCatIds.add(id);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        for (final catId in orderedCatIds) ...[
          if (_selectedCategory == null) _buildSectionHeader(catId),
          ...grouped[catId]!.map(_buildTemplateCard),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String catId) {
    final category = _categories.firstWhere(
      (item) => item.id == catId,
      orElse: () => CategoryModel(
        id: catId,
        name: AppColors.categoryNames[catId] ?? catId,
        icon: 'box',
        color: '#94A3B8',
      ),
    );
    final color = AppColors.fromHex(category.color);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppColors.getCategoryMaterialIcon(category.id),
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: color.withValues(alpha: 0.18))),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(TaskTemplate template) {
    final isAdding = _addingIds.contains(template.title);
    final isAdded = _addedIds.contains(template.title);

    final category = _categories.firstWhere(
      (item) => item.id == template.categoryId,
      orElse: () => CategoryModel(
        id: template.categoryId,
        name: template.categoryId,
        icon: 'box',
        color: '#94A3B8',
      ),
    );
    final color =
        isAdded ? AppColors.accentGreen : AppColors.fromHex(category.color);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: isAdded ? 0.24 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            AppColors.getCategoryMaterialIcon(category.id),
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          template.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            decoration: isAdded ? TextDecoration.lineThrough : null,
            color: isAdded ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 13,
              color: isAdded ? AppColors.textMuted : AppColors.accentGold,
            ),
            const SizedBox(width: 3),
            Text(
              '${template.xpReward} XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAdded ? AppColors.textMuted : AppColors.accentGold,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.monetization_on_rounded,
              size: 13,
              color: isAdded ? AppColors.textMuted : AppColors.accentGreen,
            ),
            const SizedBox(width: 3),
            Text(
              '${template.coinReward}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAdded ? AppColors.textMuted : AppColors.accentGreen,
              ),
            ),
          ],
        ),
        trailing: isAdded
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.accentGreen,
                  size: 18,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: isAdding
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          color: color,
                        ),
                        onPressed: () => _addTemplate(template),
                      ),
              ),
      ),
    );
  }
}
