import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'create_task_dialog.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

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
  final TemplateService _templateService = TemplateService();
  List<TaskTemplate> _templates = [];
  bool _isLoading = true;
  final Set<String> _addingIds = {};
  final Set<String> _addedIds = {};
  String? _selectedCategory; // null = show all

  @override
  void initState() {
    super.initState();
    _fetchTemplates(); // only templates — categories come from categoriesProvider
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
    } catch (e) {
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
      // Task successfully added to server (and silentRefresh called in notifier)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('"${template.title}" añadida')),
          ]),
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
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _addingIds.remove(template.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final dbCategoriesAsync = ref.watch(categoriesProvider);

    // Categories from DB via Riverpod — single source of truth
    final dbCategories = dbCategoriesAsync.maybeWhen(
          data: (list) => list,
          orElse: () => <CategoryModel>[],
        );
    _categories = dbCategories; // expose to helpers

    // Templates - Filter out tasks that are already active in the household
    // We must wait for tasks to be loaded to accurately filter
    final currentTasks = tasksAsync.value ?? [];
    final activeKeys = currentTasks
        .where((t) => !t.isVerified) // verified means done/archived
        .map((t) => "${t.title.toLowerCase().trim()}|${(t.category ?? 'none').toLowerCase().trim()}")
        .toSet();

    final availableTemplates = _templates.where((t) {
      final key = "${t.title.toLowerCase().trim()}|${t.categoryId.toLowerCase().trim()}";
      return !activeKeys.contains(key);
    }).toList();

    // Which categories actually have available templates? (preserves DB sort order)
    final activeCatIds = availableTemplates.map((t) => t.categoryId).toSet();
    final displayCategories =
        dbCategories.where((c) => activeCatIds.contains(c.id)).toList();

    // Filter by selected category
    final filtered = _selectedCategory == null
        ? availableTemplates
        : availableTemplates
            .where((t) => t.categoryId == _selectedCategory)
            .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // ── Handle ───────────────────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Añadir Tarea',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    Text(
                      _addedIds.isEmpty
                          ? 'Elige sugerencias o crea una nueva'
                          : '${_addedIds.length} tarea${_addedIds.length > 1 ? 's' : ''} añadida${_addedIds.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: _addedIds.isEmpty
                            ? AppColors.textSecondary
                            : AppColors.accentGreen,
                        fontSize: 13,
                        fontWeight: _addedIds.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, _addedIds.isNotEmpty),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Category filter chips ─────────────────────────────────────
          if (!_isLoading && displayCategories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryChip(null, 'Todas', null),
                  ...displayCategories
                      .map((c) => _buildCategoryChip(c.id, c.name, c)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: (_isLoading || tasksAsync.isLoading)
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? _buildEmpty()
                    : _buildTemplateList(filtered),
          ),
          // ── Bottom actions ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                )
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
                              widget.members.map((m) => m.toMap()).toList(),
                        ),
                      );
                      if (result == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    label: const Text('Personalizada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
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
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
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

  Widget _buildCategoryChip(String? id, String name, CategoryModel? cat) {
    final isSelected = _selectedCategory == id;
    final color =
        cat != null ? AppColors.fromHex(cat.color) : AppColors.textSecondary;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              id == null
                  ? Icons.format_list_bulleted_rounded
                  // Use cat.id (canonical) for icon, not name
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
          Icon(Icons.auto_awesome_rounded,
              size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          const Text('¡Ya tienes todas las sugeridas!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Crea una tarea personalizada abajo.',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // Set in build() so helpers can access the provider categories without extra params
  List<CategoryModel> _categories = [];

  Widget _buildTemplateList(List<TaskTemplate> templates) {
    final grouped = <String, List<TaskTemplate>>{};
    for (final t in templates) {
      (grouped[t.categoryId] ??= []).add(t);
    }

    // Order by DB sort_order, then any extras
    final orderedCatIds = _categories
        .map((c) => c.id)
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
    final cat = _categories.firstWhere(
      (c) => c.id == catId,
      orElse: () => CategoryModel(
        id: catId,
        name: AppColors.categoryNames[catId] ?? catId,
        icon: '📦',
        color: '#94A3B8',
      ),
    );
    final color = AppColors.fromHex(cat.color);
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
                // Use cat.id (canonical key) for icon lookup
                Icon(AppColors.getCategoryMaterialIcon(cat.id),
                    size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  cat.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: color.withValues(alpha: 0.2))),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(TaskTemplate template) {
    final isAdding = _addingIds.contains(template.title);
    final isAdded = _addedIds.contains(template.title);

    final cat = _categories.firstWhere(
      (c) => c.id == template.categoryId,
      orElse: () => CategoryModel(
          id: template.categoryId,
          name: template.categoryId,
          icon: '📦',
          color: '#94A3B8'),
    );
    final color =
        isAdded ? AppColors.accentGreen : AppColors.fromHex(cat.color);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isAdded ? 0.05 : 0.04),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: color.withValues(alpha: isAdded ? 0.3 : 0.12)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          // Use cat.id for icon lookup (canonical key)
          child: Icon(AppColors.getCategoryMaterialIcon(cat.id),
              color: color, size: 22),
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
            Icon(Icons.star_rounded,
                size: 13,
                color: isAdded ? AppColors.textMuted : AppColors.accentGold),
            const SizedBox(width: 3),
            Text('${template.xpReward} XP',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isAdded ? AppColors.textMuted : AppColors.accentGold)),
            const SizedBox(width: 10),
            Icon(Icons.monetization_on_rounded,
                size: 13,
                color: isAdded ? AppColors.textMuted : AppColors.accentGreen),
            const SizedBox(width: 3),
            Text('${template.coinReward}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isAdded ? AppColors.textMuted : AppColors.accentGreen)),
          ],
        ),
        trailing: isAdded
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.accentGreen, size: 18),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.15), blurRadius: 6)
                  ],
                ),
                child: isAdding
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: color),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.add_circle_outline_rounded,
                            color: color),
                        onPressed: () => _addTemplate(template),
                      ),
              ),
      ),
    );
  }
}
