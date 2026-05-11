import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class NewItemsSuggestionBanner extends ConsumerStatefulWidget {
  final List<String> items;
  final String householdId;
  final VoidCallback onDismiss;
  final void Function(List<ShoppingItemModel> added)? onItemsAdded;

  const NewItemsSuggestionBanner({
    super.key,
    required this.items,
    required this.householdId,
    required this.onDismiss,
    this.onItemsAdded,
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
      final addedItems = <ShoppingItemModel>[];

      for (final rawName in _selected) {
        final predefined = ReceiptMatcher.findPredefined(rawName);
        final displayName =
            predefined?.name ?? ReceiptMatcher.cleanName(rawName);
        if (displayName.isEmpty) continue;

        await notifier.addItem(
          name: displayName,
          emoji: predefined?.emoji ?? '🛒',
          category: predefined?.category ?? 'general',
        );

        addedItems.add(ShoppingItemModel(
          id: 'temp_${displayName.toLowerCase().replaceAll(' ', '_')}',
          name: displayName,
          emoji: predefined?.emoji ?? '🛒',
          category: predefined?.category ?? 'general',
          householdId: widget.householdId,
          createdAt: DateTime.now(),
        ),);
      }

      if (mounted) {
        final t = AppLocalizations.of(context);
        widget.onItemsAdded?.call(addedItems);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.expensesNewItemsAddedCount(_selected.length)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onDismiss();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonErrorWithDetails('$e'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.3),
        ),
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
                  t.expensesNewItemsDetectedTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onDismiss,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.expensesNewItemsDetectedSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.items.map((item) {
              final isSelected = _selected.contains(item);
              final predefined = ReceiptMatcher.findPredefined(item);
              final label = predefined != null
                  ? '${predefined.emoji} ${predefined.name}'
                  : ReceiptMatcher.cleanName(item);
              return FilterChip(
                label: Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                ),
                selected: isSelected,
                onSelected: _isAdding
                    ? null
                    : (value) {
                        setState(() {
                          if (value) {
                            _selected.add(item);
                          } else {
                            _selected.remove(item);
                          }
                        });
                      },
                selectedColor: AppColors.accentBlue.withValues(alpha: 0.2),
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
                child: Text(t.expensesNewItemsIgnore),
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
                    : Text(t.expensesNewItemsAddToList(_selected.length)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
