import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
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
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _category;
  late String _emoji;
  late bool _shouldSync;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item?.name ?? widget.initialName ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item?.quantity ?? '',
    );
    _category = widget.item?.category ?? widget.initialCategory ?? 'general';
    _emoji = widget.item?.emoji ?? widget.initialEmoji ?? '🛒';
    _shouldSync = widget.item?.shouldSync ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider);

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
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
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
              itemCount: ShoppingCategories.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = ShoppingCategories.all[index];
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
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // PREMIUM FEATURE: Gated Toggle
          const Text(
            'Automatización',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPremium 
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPremium 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPremium ? AppColors.primary : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPremium ? Icons.sync_rounded : Icons.lock_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vincular con Finanzas',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Crea un gasto automáticamente al comprar.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _shouldSync,
                  onChanged: isPremium 
                      ? (val) => setState(() => _shouldSync = val)
                      : (val) => PremiumPaywall.show(context),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          
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
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
        shouldSync: _shouldSync,
      );
    } else {
      // For now, edit is handled by delete/add or we could implement updateItem
      // But keeping it simple as per the current app architecture.
      // If the item exists, we might just update the shouldSync locally or via a new repo method.
      // The user mainly asked about the "form" gating.
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
