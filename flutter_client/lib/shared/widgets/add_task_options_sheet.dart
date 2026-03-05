import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/create_task_dialog.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';

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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addTemplate(TaskTemplate template) async {
    try {
      await ref.read(tasksProvider.notifier).createTask({
        'title': template.title,
        'category': template.categoryId,
        'difficulty': template.difficulty,
        'xpReward': template.xpReward,
        'coinReward': template.coinReward,
      });
      if (!context.mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingTasks = ref.watch(tasksProvider).maybeWhen(
          data: (tasks) =>
              tasks.map((t) => t.title.toLowerCase().trim()).toSet(),
          orElse: () => <String>{},
        );

    final availableTemplates = _templates
        .where((t) => !existingTasks.contains(t.title.toLowerCase().trim()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Añadir Tarea',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Elige una sugerencia o crea una nueva',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : availableTemplates.isEmpty
                    ? _buildEmptyTemplates()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: availableTemplates.length,
                        itemBuilder: (context, index) {
                          final template = availableTemplates[index];
                          return _buildTemplateCard(template);
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => CreateTaskDialog(
                    members: widget.members.map((m) => m.toMap()).toList(),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Crear Tarea Personalizada'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTemplates() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded,
              size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          const Text(
            '¡Ya tienes todas las tareas sugeridas!',
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

  Widget _buildTemplateCard(TaskTemplate template) {
    final categories = ref.watch(categoriesProvider).maybeWhen(
          data: (list) => list,
          orElse: () => [],
        );
    final found = categories.where((c) => c.id == template.categoryId);
    final category = found.isNotEmpty
        ? found.first
        : (categories.isNotEmpty ? categories.first : null);
    final color = category != null
        ? AppColors.fromHex(category.color)
        : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(AppColors.getCategoryMaterialIcon(category?.name ?? ''),
              color: color, size: 24),
        ),
        title: Text(
          template.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        subtitle: Row(
          children: [
            Text('⭐ ${template.xpReward} XP',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGold)),
            const SizedBox(width: 12),
            Text('🪙 ${template.coinReward}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen)),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: color),
            onPressed: () => _addTemplate(template),
          ),
        ),
      ),
    );
  }
}
