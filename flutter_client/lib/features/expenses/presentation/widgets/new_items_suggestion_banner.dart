import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:homesync_client/features/shopping/data/shopping_predefined.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';

/// Banner que aparece en el formulario de gasto cuando el OCR detectó productos
/// que no están en la lista de compras activa.
///
/// Usa [shoppingItemsProvider.notifier.addItem] para agregar items —
/// no baja al repositorio directamente.
class NewItemsSuggestionBanner extends ConsumerStatefulWidget {
  final List<String> items;
  final VoidCallback onDismiss;

  const NewItemsSuggestionBanner({
    super.key,
    required this.items,
    required this.onDismiss,
  });

  @override
  ConsumerState<NewItemsSuggestionBanner> createState() =>
      _NewItemsSuggestionBannerState();
}

class _NewItemsSuggestionBannerState
    extends ConsumerState<NewItemsSuggestionBanner> {
  late final Set<String> _selected;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.items);
  }

  Future<void> _addSelected() async {
    if (_selected.isEmpty || _isAdding) return;
    setState(() => _isAdding = true);

    try {
      final notifier = ref.read(shoppingItemsProvider.notifier);
      for (final rawName in _selected) {
        final cleanName = ReceiptMatcher.cleanName(rawName);
        if (cleanName.isEmpty) continue;

        // Buscar emoji y categoría en predefinidos para que el item quede bien
        final predefined = ShoppingPredefined.findByName(rawName);

        await notifier.addItem(
          name: cleanName,
          emoji: predefined?['emoji'] ?? '🛒',
          category: predefined?['category'] ?? 'general',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_selected.length} productos agregados a la lista'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ));
        widget.onDismiss();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al agregar: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.08),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🛒', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Productos nuevos detectados',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onDismiss,
                child: Icon(Icons.close,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '¿Los agregamos a la lista para la próxima?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.items.map((item) {
              final isSelected = _selected.contains(item);
              return FilterChip(
                label: Text(
                  ReceiptMatcher.cleanName(item),
                  style: const TextStyle(fontSize: 12),
                ),
                selected: isSelected,
                onSelected: _isAdding
                    ? null
                    : (val) => setState(() {
                          if (val) {
                            _selected.add(item);
                          } else {
                            _selected.remove(item);
                          }
                        }),
                selectedColor: AppColors.accentBlue.withOpacity(0.2),
                checkmarkColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isAdding ? null : widget.onDismiss,
                child: const Text('Ignorar'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed:
                    (_selected.isEmpty || _isAdding) ? null : _addSelected,
                child: _isAdding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Agregar ${_selected.length} a lista'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
