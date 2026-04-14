import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import '../providers/shopping_provider.dart';
import '../../domain/models/shopping_model.dart';
import '../../domain/models/shopping_categories.dart';

class ShoppingItemSheet extends ConsumerStatefulWidget {
  final ShoppingItemModel? item;
  final String? initialName;
  final String? initialCategory;
  final String? initialEmoji;

  const ShoppingItemSheet({
    super.key,
    this.item,
    this.initialName,
    this.initialCategory,
    this.initialEmoji,
  });

  static void show(
    BuildContext context, {
    ShoppingItemModel? item,
    String? initialName,
    String? initialCategory,
    String? initialEmoji,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShoppingItemSheet(
        item: item,
        initialName: initialName,
        initialCategory: initialCategory,
        initialEmoji: initialEmoji,
      ),
    );
  }

  @override
  ConsumerState<ShoppingItemSheet> createState() => _ShoppingItemSheetState();
}

class _ShoppingItemSheetState extends ConsumerState<ShoppingItemSheet> {
  static final List<Map<String, dynamic>> _visibleCategories =
      ShoppingCategories.all.where((cat) => cat['id'] != 'general').toList();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _category;
  late String _emoji;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item?.name ?? widget.initialName ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item?.quantity ?? '',
    );
    final initialCategory = widget.item?.category ?? widget.initialCategory;
    final fallbackCategoryId = _visibleCategories.first['id'] as String;
    final fallbackEmoji = _visibleCategories.first['emoji'] as String;

    _category = initialCategory ?? fallbackCategoryId;
    _emoji = widget.item?.emoji ??
        widget.initialEmoji ??
        ShoppingCategories.emojiFor(_category);

    if (!ShoppingCategories.all.any((cat) => cat['id'] == _category)) {
      _category = fallbackCategoryId;
      _emoji = fallbackEmoji;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24,
        right: 24,
        top: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Nombre del producto',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
              if (widget.item != null)
                IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Categoría',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _visibleCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _visibleCategories[index];
                final isSelected = _category == cat['id'];
                return FilterChip(
                  label: Text(cat['name']),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _category = cat['id'];
                        _emoji = cat['emoji'];
                      });
                    }
                  },
                  backgroundColor: context.theme.scaffoldBackground,
                  selectedColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.item == null ? 'Agregar a la Lista' : 'Guardar Cambios',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;

    if (widget.item == null) {
      ref.read(shoppingItemsProvider.notifier).addItem(
            name: _nameController.text.trim(),
            category: _category,
            emoji: _emoji,
          );
    } else {
      ref.read(shoppingItemsProvider.notifier).updateItem(
            itemId: widget.item!.id,
            name: _nameController.text.trim(),
            category: _category,
            emoji: _emoji,
          );
    }

    Navigator.pop(context);
  }

  void _delete() {
    if (widget.item != null) {
      ref.read(shoppingItemsProvider.notifier).deleteItem(widget.item!.id);
      Navigator.pop(context);
    }
  }
}
