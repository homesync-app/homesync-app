import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class EditTaskSheet extends ConsumerStatefulWidget {
  final TaskModel task;

  const EditTaskSheet({
    super.key,
    required this.task,
  });

  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _xpController;
  late TextEditingController _coinController;
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _xpController =
        TextEditingController(text: widget.task.xpReward.toString());
    _coinController =
        TextEditingController(text: widget.task.coinReward.toString());
    _selectedCategory = widget.task.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _xpController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un nombre para la tarea')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(tasksProvider.notifier).editTask(widget.task.id, {
        'title': title,
        'category': _selectedCategory,
        'xp_reward': int.tryParse(_xpController.text) ?? 0,
        'coin_reward': int.tryParse(_coinController.text) ?? 0,
      });

      if (mounted) {
        Navigator.pop(context, true); // true indicates a refresh is needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar tarea?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(tasksProvider.notifier).deleteTask(widget.task);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final currentCategories = categoriesAsync.maybeWhen(
      data: (list) => list
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'icon': c.icon,
                'color': c.color,
              })
          .toList(),
      orElse: () => [],
    );

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Editar Tarea',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _deleteTask,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                tooltip: 'Eliminar tarea',
              ),
            ],
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Nombre de la tarea',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: currentCategories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                final colorStr = cat['color'] ?? '#94A3B8';
                final color = AppColors.fromHex(colorStr);

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected ? color : const Color(0xFFF1F5F9),
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Icon(
                              AppColors.getCategoryMaterialIcon(cat['name']),
                              color: isSelected
                                  ? color
                                  : color.withValues(alpha: 0.8),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Points
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _xpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Puntos de exp',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.star_rounded,
                        color: AppColors.accentGold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _coinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Coins',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.monetization_on_rounded,
                        color: AppColors.sage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Guardar Cambios',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
