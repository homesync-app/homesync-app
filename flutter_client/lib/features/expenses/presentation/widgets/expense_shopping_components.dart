import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/shopping/data/shopping_predefined.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_categories.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';

class ExpenseShoppingIntegrationCard extends StatelessWidget {
  final bool isPremium;
  final int linkedItemsCount;
  final VoidCallback onTap;

  const ExpenseShoppingIntegrationCard({
    super.key,
    required this.isPremium,
    required this.linkedItemsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPremium ? 1.0 : 0.6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPremium
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPremium
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPremium
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPremium
                      ? Icons.shopping_cart_outlined
                      : Icons.lock_rounded,
                  color: isPremium ? AppColors.primary : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      linkedItemsCount == 0
                          ? 'Vincular con la lista'
                          : '$linkedItemsCount artÃ­culos vinculados',
                      style: TextStyle(
                        color: isPremium
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      isPremium
                          ? 'Marca artÃ­culos como comprados'
                          : 'FunciÃ³n Premium de HomeSync',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isPremium
                    ? Icons.add_circle_outline_rounded
                    : Icons.chevron_right_rounded,
                color: isPremium ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoppingItemsSelectorSheet extends ConsumerStatefulWidget {
  final Set<ShoppingItemModel> initialSelected;
  final ValueChanged<Set<ShoppingItemModel>> onItemsSelected;

  const ShoppingItemsSelectorSheet({
    super.key,
    required this.initialSelected,
    required this.onItemsSelected,
  });

  @override
  ConsumerState<ShoppingItemsSelectorSheet> createState() =>
      _ShoppingItemsSelectorSheetState();
}

class _ShoppingItemsSelectorSheetState
    extends ConsumerState<ShoppingItemsSelectorSheet> {
  String _searchQuery = '';
  final Set<ShoppingItemModel> _currentSelection = {};
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentSelection.addAll(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase().trim();
    final householdItems = ref.watch(shoppingItemsProvider).value ?? [];
    final pendingHouseholdItems =
        householdItems.where((item) => !item.completed).toList();

    final filteredPendingHouseholdItems = pendingHouseholdItems
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();

    final List<Map<String, String>> predefinedMatches = [];
    if (query.isNotEmpty) {
      ShoppingPredefined.itemsPerCategory.forEach((catId, catList) {
        final catName = ShoppingCategories.nameFor(catId).toLowerCase();
        final catMatchesQuery = catName.contains(query);

        for (final item in catList) {
          final itemName = item['name']!;
          if (itemName.toLowerCase().contains(query) || catMatchesQuery) {
            final existsInHousehold = pendingHouseholdItems
                .any((ai) => ai.name.toLowerCase() == itemName.toLowerCase());
            final existsInSelection = _currentSelection
                .any((cs) => cs.name.toLowerCase() == itemName.toLowerCase());

            if (!existsInHousehold &&
                !existsInSelection &&
                !predefinedMatches.any((pm) =>
                    pm['name']!.toLowerCase() == itemName.toLowerCase())) {
              predefinedMatches.add({...item, 'categoryId': catId});
            }
          }
        }
      });
    }

    final showAddOption = query.isNotEmpty &&
        !filteredPendingHouseholdItems
            .any((item) => item.name.toLowerCase() == query) &&
        !predefinedMatches
            .any((item) => item['name']!.toLowerCase() == query) &&
        !_currentSelection.any((item) => item.name.toLowerCase() == query);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    'ArtÃ­culos de la Lista',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      decoration: const InputDecoration(
                        hintText: 'Buscar o agregar producto...',
                        hintStyle:
                            TextStyle(color: AppColors.textMuted, fontSize: 14),
                        icon: Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onSubmitted: (val) async {
                        if (val.trim().isEmpty) return;
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _searchFocus.requestFocus();

                        await ref.read(shoppingItemsProvider.notifier).addItem(
                              name: val.trim(),
                              category: 'general',
                              emoji: 'ðŸ·ï¸',
                            );

                        final temp = ShoppingItemModel(
                          id: 'selection_sync_${val.trim()}',
                          name: val.trim(),
                          householdId: '',
                          createdAt: DateTime.now(),
                          emoji: 'ðŸ·ï¸',
                          category: 'general',
                        );
                        setState(() => _currentSelection.add(temp));
                        widget.onItemsSelected(_currentSelection);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      if (showAddOption)
                        ListTile(
                          leading:
                              const Text('âž•', style: TextStyle(fontSize: 24)),
                          title: Text(
                            'Agregar "$_searchQuery"',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: const Text(
                            'Producto personalizado',
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () async {
                            final queryToSave = _searchQuery.trim();
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _searchFocus.requestFocus();

                            await ref.read(shoppingItemsProvider.notifier).addItem(
                                  name: queryToSave,
                                  category: 'general',
                                  emoji: 'ðŸ·ï¸',
                                );

                            final temp = ShoppingItemModel(
                              id: 'selection_sync_$queryToSave',
                              name: queryToSave,
                              householdId: '',
                              createdAt: DateTime.now(),
                              emoji: 'ðŸ·ï¸',
                              category: 'general',
                            );
                            setState(() => _currentSelection.add(temp));
                            widget.onItemsSelected(_currentSelection);
                          },
                        ),
                      ...filteredPendingHouseholdItems.map((item) {
                        final isSelected = _currentSelection.contains(item);
                        return ListTile(
                          leading: Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                          onTap: () {
                            if (_searchQuery.isNotEmpty) {
                              _searchController.clear();
                              _searchFocus.requestFocus();
                            }
                            setState(() {
                              if (isSelected) {
                                _currentSelection.remove(item);
                              } else {
                                _currentSelection.add(item);
                              }
                              if (_searchQuery.isNotEmpty) {
                                _searchQuery = '';
                              }
                            });
                            widget.onItemsSelected(_currentSelection);
                          },
                        );
                      }),
                      if (predefinedMatches.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'Sugerencias globales',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        ...predefinedMatches.take(25).map((item) {
                          return ListTile(
                            leading: Text(
                              item['emoji']!,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              item['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            onTap: () async {
                              final name = item['name']!;
                              final cat = item['categoryId']!;
                              final emoji = item['emoji']!;

                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _searchFocus.requestFocus();

                              await ref.read(shoppingItemsProvider.notifier).addItem(
                                    name: name,
                                    category: cat,
                                    emoji: emoji,
                                  );

                              final temp = ShoppingItemModel(
                                id: 'selection_sync_$name',
                                name: name,
                                householdId: '',
                                createdAt: DateTime.now(),
                                emoji: emoji,
                                category: cat,
                              );
                              setState(() => _currentSelection.add(temp));
                              widget.onItemsSelected(_currentSelection);
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Listo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
